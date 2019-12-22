defmodule BambooGmailTest do
  use ExUnit.Case
  doctest BambooGmail

  test "greets the world" do
    assert BambooGmail.hello() == :world
  end
end
