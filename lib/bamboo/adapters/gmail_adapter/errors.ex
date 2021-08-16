defmodule Bamboo.GmailAdapter.Errors do
  for exception_struct <- [__MODULE__.ConfigError, __MODULE__.TokenError, __MODULE__.HTTPError] do
    defimpl String.Chars, for: exception_struct do
      def to_string(exception) do
        """
        #{Map.fetch!(exception, :__struct__)}:
        #{exception.message}
        """
      end
    end
  end

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

    def build_error(fields) do
      exception(fields)
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

    def build_error(fields) do
      exception(fields)
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

    def build_error(fields) do
      exception(fields)
    end
  end
end
