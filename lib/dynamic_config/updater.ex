defmodule DynamicConfig.Updater do

  require Logger
  use GenServer

  alias DynamicConfig.CouchDB, as: Source



  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    Process.send_after(__MODULE__, {:update}, 1000)
    {:ok, %{}}
  end

  # callbacks

  def handle_info({:update}, state) do
    state1 = case update_config() do
      :ok ->
        Map.put(state, :last_updated, DateTime.utc_now)
      {:error, error} ->
        s2 = Map.put(state, :last_updated, DateTime.utc_now)
        Map.put(s2, :error, error)
    end
    interval = Application.get_env(__MODULE__, :interval, 60_000)
    Process.send_after(__MODULE__, {:update}, interval)
    {:noreply, state1}
  end


  defp update_config do
    key = Application.get_env(:dynamic_config, :update, Application.get_application(__MODULE__))
    case Source.get_config(key) do
      {:ok, config} ->
        case config["_rev"] == Application.get_env(key, "_rev") do
          true -> 
            Logger.debug("no need to update, already have the latest version: #{config["_rev"]}")
            :ok
          false ->
            Logger.debug("need to update, have a new version: #{config["_rev"]}")
            config
            |> Enum.each(fn({k, v}) -> Application.put_env(key, k, v, [:persistent]) end)
            :ok
        end 
      error -> 
        Logger.error("Had errors updating the config for #{key}: #{inspect error}")
        {:error, error}
    end
  end
end
