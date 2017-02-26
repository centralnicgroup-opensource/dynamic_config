defmodule DynamicConfig.Updater do

  require Logger
  alias DynamicConfig.CouchDB, as: Source
  
  def update do
    key = Application.get_env(__MODULE__, :update, Application.get_application(__MODULE__))
    case Source.get_config(key) do
      {:ok, config} ->
        case config["_rev"] == Application.get_env(key, "_rev") do
          true -> 
            Logger.debug("no need to update, already have the latest version: #{config["_rev"]}")
          false ->
            Logger.debug("need to update, have a new version: #{config["_rev"]}")
            config
            |> Enum.each(fn({k, v}) -> Application.put_env(key, k, v, [:persistent]) end)
        end 
      error -> error
    end
  end
end
