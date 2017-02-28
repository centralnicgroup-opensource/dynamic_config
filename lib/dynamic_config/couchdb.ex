defmodule DynamicConfig.CouchDB do

  @db Application.get_env(:dynamic_config, :config_db, "config")

  require Logger

  @moduledoc ~S"""
  The CouchDB backend reads configuration from a CouchDB document and
  returns it withsome sanitisation. We end up with the document revision
  in the application config under the `:cahe_id` key, this is handy as
  we can test against it to see if we need to update the config.
  """

  @spec get_config(atom) :: {Atom.t, Map.t}
  def get_config(key) do
    Logger.debug("Looking up config for #{key} on #{@db}")
    case Couchex.Client.get(@db, key) do
      {:ok, doc} ->
        doc1 = doc
        |> Map.put(:cache_id, doc["_rev"])
        |> Map.delete("_rev")
        |> Map.delete("_id")
        {:ok, doc1}
      error -> error
    end
  end
end
