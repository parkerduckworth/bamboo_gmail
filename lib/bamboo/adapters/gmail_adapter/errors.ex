defmodule Bamboo.GmailAdapter.Errors do
  defmodule TokenError do
    @moduledoc false

    defexception [:message]

    def exception(message) do
      message = """
      Error retrieving access token

      More info:
      #{inspect(message)}
      """

      %TokenError{message: message}
    end
  end

  defmodule HTTPError do
    @moduledoc false

    defexception [:message]

    def exception(message) do
      message = """
      Error making HTTP request

      More info:
      #{inspect(message)}
      """

      %TokenError{message: message}
    end
  end

  defmodule ConfigError do
    @moduledoc false

    defexception [:message]

    def exception(field) do
      message = """
      Must provide `#{Keyword.get(field, :field)}` field in config.

      Example:

      config :gmail_adapter_test, GmailAdapterTestWeb.Mailer,
        adapter: Bamboo.GmailAdapter,
        sub: {:system, "SUB_ADDRESS"}
      """

      %ConfigError{message: message}
    end
  end
end
