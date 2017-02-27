defmodule DynamicConfig do

  require Logger
  use GenServer

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
    state1 = Map.put(state, :status, update_config())
    interval = Application.get_env(__MODULE__, :interval, 60_000)
    Process.send_after(__MODULE__, {:update}, interval)
    {:noreply, state1}
  end


  @spec update_config() :: {Atom.t, Map.t}
  defp update_config do
    case Application.get_env(:dynamic_config, :targets, []) do
      [] ->
        Logger.info("Could not find any dynamic config update targets - giving up")
        {:ok, %{}}
      targets ->
        result = targets 
        |> Enum.map(fn(x) -> process_update(x) end)
        |> Enum.reduce(%{}, fn(x, acc) -> process_result(acc, x) end)
        {:ok, result}
    end
  end

  @spec process_result(map, tuple) :: Map.t
  defp process_result(map, {:ok, line}) do
    [key] = Map.keys(line)
    Map.put(map, key, %{last_updated: DateTime.utc_now})
  end
  @spec process_result(map, tuple) :: Map.t
  defp process_result(map, {:error, line}) do
    [key] = Map.keys(line)
    s2 = Map.put(map, key,  %{last_updated: DateTime.utc_now})
    Map.put(s2, :error, %{key => line.key})
  end

  @spec process_update(map) :: {Atom.t, Map.t}
  defp process_update(line) do
    case line.backend.get_config(line.source) do
      {:ok, config} ->
        needs_update?(line.target, config)
      error ->
        Logger.error("Had errors updating the config for #{line.target}: #{inspect error}")
        {:error, %{line.target => error}}
    end
  end

  @spec needs_update?(atom, map) :: {Atom.t, Map.t}
  defp needs_update?(key, config) do
      case config["_rev"] == Application.get_env(key, "_rev") do
        true ->
          Logger.debug("no need to update, already have the latest version: #{config["_rev"]}")
          {:ok, %{key => config}}
        false ->
          Logger.debug("need to update, have a new version: #{config["_rev"]}")
          config
          |> Enum.each(fn({k, v}) -> Application.put_env(key, k, v, [:persistent]) end)
          {:ok, %{key => config}}
      end
  end

end
