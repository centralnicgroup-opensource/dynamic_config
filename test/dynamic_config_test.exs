defmodule DynamicConfigTest do
  use ExUnit.Case
  doctest DynamicConfig

  test "config loaded" do
    Process.sleep(1_000) # we need to wait for the document to be read
    conf = Application.get_env(:nsearch3, "_id")
    assert conf == "nsearch3"
  end
end
