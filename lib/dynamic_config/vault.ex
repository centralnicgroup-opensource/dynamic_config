defmodule DynamicConfig.Vault do

  require Logger

  @moduledoc ~S"""
  The Vault backend reads configuration from a Vault key and
  returns it without any processing. As `vaultiex` caches the result we
  can just poll every time and will only hit the actual store once the
  key expired in the vaultex cache. We will also expose the `request_id`
  as the `cache_id`.
  """

  @spec get_config(atom) :: {Atom.t, Map.t}
  def get_config(key) do
    Logger.debug("Looking up config for #{key} in vault")
    case Vaultex.Client.read(key) do
      {:ok, []} ->
        {:error, :no_data}
      {:ok, res} ->
        Logger.debug("Got some data: #{inspect res}")
        data = res["data"]
               |> Map.put(:cache_id, res["request_id"])
        {:ok, data}
      error -> error
    end
  end
end
