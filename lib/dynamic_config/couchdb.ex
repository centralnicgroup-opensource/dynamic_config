defmodule DynamicConfig.CouchDB do
  
  @db Application.get_env(:dynamic_config, :config_db, "config")

  require Logger

  @moduledoc ~S"""
  The CouchDB backend reads configuration from a CouchDB document and
  returns it without any processing. This means we end up with the
  document revision in the application config, this is handy as we can
  test against it to see if we need to update the config.
  """

  @spec get_config(atom) :: {Atom.t, Map.t}
  def get_config(key) do
    Logger.debug("Looking up config for #{inspect key} on #{@db}")
    Couchex.Client.get(@db, Atom.to_string(key))
  end
end
