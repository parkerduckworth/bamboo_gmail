defmodule Bamboo.GmailAdapter do
  @moduledoc """
  Documentation for Bamboo.GmailAdapter
  """

  @behaviour Bamboo.Adapter

  def deliver(email, config) do
    IO.inspect email, label: "email"
    IO.inspect config, label: "config"
    IO.inspect get_access_token(), label: "access token"
  end

  def handle_config(config) do
    IO.inspect config, label: "config"
    config
  end

  def supports_attachments?, do: true

  defp get_access_token do
    {:ok, token} = Goth.Token.for_scope("https://www.googleapis.com/auth/gmail.compose")
    token
  end
end
