defmodule Bamboo.GmailAdapter.Errors do
  use ExUnit.Case

  alias Bamboo.GmailAdapter.Errors.{ConfigError, HTTPError, TokenError}

  test "invalid configuration raises ConfigError" do
    exception = %ConfigError{message: "test"}
    assert is_binary(String.Chars.to_string(exception))

    exception = %TokenError{message: "test"}
    assert is_binary(String.Chars.to_string(exception))

    exception = %HTTPError{message: "test"}
    assert is_binary(String.Chars.to_string(exception))
  end
end
