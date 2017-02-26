defmodule DynamicConfig.CouchDB do
  
  @db Application.get_env(:dynamic_config, :config_db, "config")

  require Logger

  def get_config(key) do
    Logger.debug("Looking up config for #{inspect key} on #{@db}")
    Couchex.Client.get(@db, Atom.to_string(key))
  end
end
