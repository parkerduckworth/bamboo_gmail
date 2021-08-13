defmodule Bamboo.GmailAdapter do
  @moduledoc """
  Sends email using the Gmail API with OAuth2 authentication

  There are a few preconditions that must be met before this adapter can be used to send email:
  1. Admin access to a GSuite account
  2. Implement [server-side authorization](https://developers.google.com/gmail/api/auth/web-server)
  3. Grant the service account domain-wide authority
  4. Authorize API client with required scopes

  Some application settings must be configured. See the [example section](#module-example-config) below.

  ---

  ## Configuration

  | Setting | Description | Required? |
  | ---------- | ---------- | ---------- |
  | `adapter` | Bamboo adapter in use (`Bamboo.GmailAdapter`). | Yes |
  | `sub` | Email address the service account is impersonating (address the email is sent from).  If impersonation is not needed, then `nil` (it is likely needed). | Yes |
  |`sandbox` | Development mode that does not send email.  Details of the API call are instead output to the elixir console. | No |
  | `json` | Google auth crendentials must be provided in JSON format to the `:goth` app.  These are generated in the [Google Developers Console](https://console.developers.google.com/). | Yes |


  #### Note:

  *Secrets such as the service account sub, and the auth credentials should not
  be commited to version control.*

  Instead, pass in via environment variables using a tuple:
      {:system, "SUB_ADDRESS"}

  Or read in from a file:
      "creds.json" |> File.read!

  ---

  ## Example Config

      config :app_name, GmailAdapterTestWeb.Mailer,
        adapter: Bamboo.GmailAdapter,
        sub: {:system, "SUB_ADDRESS"},
        sandbox: false

      # Google auth credentials must be provided to the `goth` app
      config :goth, json: {:system, "GCP_CREDENTIALS"}
  """

  import Bamboo.GmailAdapter.RFC2822, only: [render: 1]
  alias Bamboo.GmailAdapter.Errors.{ConfigError, TokenError, HTTPError}

  @gmail_auth_scope "https://www.googleapis.com/auth/gmail.send"
  @gmail_send_url "https://www.googleapis.com/gmail/v1/users/me/messages/send"
  @behaviour Bamboo.Adapter

  def deliver(email, config) do
    handle_dispatch(email, config)
  end

  def handle_config(config) do
    validate_config_fields(config)
  end

  def supports_attachments?, do: true

  defp handle_dispatch(email, config = %{sandbox: true}) do
    log_to_sandbox(config, label: "config")
    log_to_sandbox(email, label: "email")

    build_message(email)
    |> render()
    |> log_to_sandbox(label: "MIME message")
    |> Base.url_encode64()
    |> log_to_sandbox(label: "base64url encoded message")

    get_sub(config)
    |> get_access_token()
    |> log_to_sandbox(label: "access token")
  end

  defp handle_dispatch(email, config) do
    message = build_message(email)

    get_sub(config)
    |> get_access_token()
    |> build_request(message)
  end

  defp build_message(email) do
    Mail.build_multipart()
    |> put_to(email)
    |> put_cc(email)
    |> put_bcc(email)
    |> put_from(email)
    |> put_subject(email)
    |> put_html_body(email)
    |> put_text_body(email)
    |> put_attachments(email)
  end

  defp put_to(message, %{to: recipients}) do
    recipients = Enum.map(recipients, fn {_, email} -> email end)
    Mail.put_to(message, recipients)
  end

  defp put_cc(message, %{cc: recipients}) do
    recipients = Enum.map(recipients, fn {_, email} -> email end)
    Mail.put_cc(message, recipients)
  end

  defp put_bcc(message, %{bcc: recipients}) do
    recipients = Enum.map(recipients, fn {_, email} -> email end)
    Mail.put_bcc(message, recipients)
  end

  defp put_from(message, %{from: {_, sender}}) do
    Mail.put_from(message, sender)
  end

  defp put_subject(message, %{subject: subject}) do
    Mail.put_subject(message, subject)
  end

  defp put_html_body(message, %{html_body: nil}), do: message

  defp put_html_body(message, %{html_body: html_body}) do
    Mail.put_html(message, html_body)
  end

  defp put_text_body(message, %{text_body: nil}), do: message

  defp put_text_body(message, %{text_body: text_body}) do
    Mail.put_text(message, text_body)
  end

  defp put_attachments(message, %{attachments: attachments}) do
    put_attachments_helper(message, attachments)
  end

  defp put_attachments_helper(message, [head | tail]) do
    put_attachments_helper(message, head)
    |> put_attachments_helper(tail)
  end

  defp put_attachments_helper(message, %Bamboo.Attachment{filename: filename, data: data}) do
    attachment =
      Mail.Message.build_attachment({filename, data})
      |> Mail.Message.put_header(:content_type, "application/octet-stream")
      |> Mail.Message.put_header(:content_length, byte_size(data))

    Mail.Message.put_part(message, attachment)
  end

  defp put_attachments_helper(message, _no_attachments) do
    message
  end

  defp build_request(token, message) do
    header = build_request_header(token)

    render(message)
    |> Base.url_encode64()
    |> build_request_body()
    |> send_request(header, @gmail_send_url)
  end

  defp send_request(body, header, url) do
    case HTTPoison.post(url, body, header) do
      {:ok, response} -> response
      {:error, error} -> handle_error(:http, error)
    end
  end

  # Right now `sub` is the only required field.
  # TODO: Generalize this function
  defp validate_config_fields(config = %{sub: _}), do: config

  defp validate_config_fields(_no_match) do
    handle_error(:conf, "sub")
  end

  defp get_sub(%{sub: sub}) do
    case sub do
      {:system, s} -> validate_env_var(s)
      _ -> sub
    end
  end

  defp validate_env_var(env_var) do
    case var = System.get_env(env_var) do
      nil -> handle_error(:env, "Environment variable '#{env_var}' not found")
      _ -> var
    end
  end

  defp get_access_token(sub) do
    case Goth.Token.for_scope(@gmail_auth_scope, sub) do
      {:ok, token} -> Map.get(token, :token)
      {:error, error} -> handle_error(:auth, error)
    end
  end

  defp handle_error(scope, error) do
    case scope do
      :auth -> {:error, {TokenError, %{message: error}}}
      :http -> {:error, {HTTPError, %{message: error}}}
      :conf -> {:error, {ConfigError, %{field: error}}}
      :env -> {:error, {ArgumentError, %{message: error}}}
    end
  end

  defp build_request_header(token) do
    [Authorization: "Bearer #{token}", "Content-Type": "application/json"]
  end

  defp build_request_body(message) do
    "{\"raw\": \"#{message}\"}"
  end

  defp log_to_sandbox(entity, label: label) do
    IO.puts("[sandbox] <#{label}> #{inspect(entity)}\n")
    entity
  end
end
