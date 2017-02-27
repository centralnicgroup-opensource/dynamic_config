defmodule DynamicConfig do

  require Logger
  use GenServer

  alias DynamicConfig.CouchDB, as: Source

  @moduledoc ~S"""
  This is a GenServer that cals itself every n milliseconds to
  update the configuration of an application. The only real call of
  importance is the `update_config()` call that does all the heavy
  lifting, the rest is mostely boilerplate.
  """

  @spec start_link() :: {Atom.t, Pid.t}
  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec init(list) :: {Atom.t, Map.t}
  def init(_args) do
    Process.send(__MODULE__, {:update}, [])
    {:ok, %{}}
  end

  # callbacks

  @spec handle_info(tuple, map) :: {Atom.t, Map.t}
  def handle_info({:update}, state) do
    state1 = case update_config() do
      {:ok, _map} ->
        Map.put(state, :last_updated, DateTime.utc_now)
      {:error, error} ->
        s2 = Map.put(state, :last_updated, DateTime.utc_now)
        Map.put(s2, :error, error)
    end
    interval = Application.get_env(__MODULE__, :interval, 60_000)
    Process.send_after(__MODULE__, {:update}, interval)
    {:noreply, state1}
  end


  @spec update_config() :: {Atom.t, Map.t}
  defp update_config do
    key = Application.get_env(:dynamic_config, :update, Application.get_application(__MODULE__))
    case Source.get_config(key) do
      {:ok, config} ->
        needs_update?(key, config)
      error -> 
        Logger.error("Had errors updating the config for #{key}: #{inspect error}")
        {:error, error}
    end
  end

  @spec needs_update?(atom, map) :: {Atom.t, Map.t}
  defp needs_update?(key, config) do
      case config["_rev"] == Application.get_env(key, "_rev") do
        true ->
          Logger.debug("no need to update, already have the latest version: #{config["_rev"]}")
          {:ok, config}
        false ->
          Logger.debug("need to update, have a new version: #{config["_rev"]}")
          config
          |> Enum.each(fn({k, v}) -> Application.put_env(key, k, v, [:persistent]) end)
          {:ok, config}
      end
  end

end
