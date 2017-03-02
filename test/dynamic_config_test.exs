defmodule DynamicConfigTest do
  use ExUnit.Case
  doctest DynamicConfig

  test "config loaded" do
    Process.sleep(1_000) # we need to wait for the document to be read
    conf = Application.get_env(:nsearch3, "ets_cache")
    assert conf == true
  end
end
