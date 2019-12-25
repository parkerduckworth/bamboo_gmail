defmodule Bamboo.GmailAdapter do
  @moduledoc """
  Documentation for Bamboo.GmailAdapter
  """

  @behaviour Bamboo.Adapter

  @gmail_auth_scope "https://www.googleapis.com/auth/gmail.send"
  @gmail_send_endpoint "https://www.googleapis.com/gmail/v1/users/me/messages/send"

  def deliver(email, config) do
    IO.inspect email, label: "email"
    IO.inspect config, label: "config"
    
    # TODO: Make functions out of these
    recipients = format_to(Map.get(email, :to))
    sender = format_from(Map.get(email, :from))
    subject = Map.get(email, :subject)
    html = Map.get(email, :html_body)
    text = Map.get(email, :text_body)

    # TODO: Make functions out of these
    message = Mail.build_multipart
    |> Mail.put_to(recipients)
    |> Mail.put_from(sender)
    |> Mail.put_subject(subject)
    |> Mail.put_html(html)
    |> Mail.put_text(text)
    |> Mail.Renderers.RFC2822.render
    |> IO.inspect(label: "MIME msg")
    |> Base.url_encode64 
    |> IO.inspect(label: "base64url")

    get_sub(config)
    |> get_access_token
    |> make_request(message)
    |> IO.inspect(label: "response")

  end

  # TODO: Place in pipeline? Check what SMTP does here
  def handle_config(config) do
    config
  end

  # TODO: Handle attachments
  def supports_attachments?, do: true

  # TODO: Refactor
  defp format_from({nil, email}), do: email
  defp format_to([nil: email]), do: email

  defp make_request(token, message) do
    headers = build_request_headers(token)
    body = build_request_body(message)

    # TODO: Error handlingm case statement?
    {:ok, response} = HTTPoison.post(@gmail_send_endpoint, body, headers)
    response
  end

  # TODO: Allow other methods of providing `sub` (file, etc.)
  defp get_sub(%{sub: {:system, sub}}) do
    System.get_env(sub)
  end

  defp get_sub(_no_match) do
    # TODO: Custom error type
    raise ErlangError
  end

  defp get_access_token(sub) do
    # TODO: Error handling
    {:ok, token} = Goth.Token.for_scope(@gmail_auth_scope, sub)
    IO.inspect token, label: "GothToken"
    Map.get(token, :token)
  end

  defp build_request_headers(token) do
    ["Authorization": "Bearer #{token}", "Content-Type": "application/json"]
  end

  defp build_request_body(message) do
    "{\"raw\": \"#{message}\"}"
  end
end
