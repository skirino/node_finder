defmodule NodeFinder.ConnectionWatcher do
  use GenServer.Behaviour

  # Public API
  def start_link do
    :gen_server.start_link({ :local, :node_finder_connection_watcher }, __MODULE__, [], [])
  end

  def add_nodeup_handler(f) do
    :node_finder_connection_watcher <- { :add_handler, :nodeup, f }
  end
  def add_nodedown_handler(f) do
    :node_finder_connection_watcher <- { :add_handler, :nodedown, f }
  end

  # Callbacks
  def init([]) do
    :net_kernel.monitor_nodes(true, [node_type: :all])
    { :ok, [nodeup: [&nodeup_printer/1], nodedown: [&nodedown_printer/1]] }
  end

  def handle_info({ :add_handler, key, f }, state) do
    handlers = Keyword.get(state, key, [])
    { :noreply, Keyword.put(state, key, [f | handlers]) }
  end
  def handle_info({ key, node, _infos }, state) do
    handlers = Keyword.get(state, key, [])
    Enum.each(handlers, fn(f) -> f.(node) end)
    { :noreply, state }
  end

  def nodeup_printer(node) do
    :error_logger.info_msg "[#{__MODULE__}] nodeup: #{node}"
  end
  def nodedown_printer(node) do
    :error_logger.info_msg "[#{__MODULE__}] nodedown: #{node}"
  end
end
