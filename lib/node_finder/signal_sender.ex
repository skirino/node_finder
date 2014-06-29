alias NodeFinder.NodeInfo, as: NodeInfo

defmodule NodeFinder.SignalSender do
  use GenServer

  # Public API
  def start_link do
    :gen_server.start_link({ :local, :node_finder_signal_sender }, __MODULE__, [], [])
  end

  def send do
    send :node_finder_signal_sender, :send
    :ok
  end

  # Callbacks
  def init([]) do
    { :ok, :erlang.send_after(1, self, :send) }
  end

  def handle_info(:send, old_timer) do
    _ = :erlang.cancel_timer(old_timer)
    :ok = send_signal
    { :ok, millis } = :application.get_env :sending_interval_milliseconds
    { :noreply, :erlang.send_after(millis, self, :send) }
  end

  defp send_signal do
    :error_logger.info_msg '[~s] Number of connected nodes: ~B. Broadcasting node info...', [__MODULE__, Enum.count(Node.list)]
    { :ok, addr } = :application.get_env :udp_multicast_address
    { :ok, port } = :application.get_env :udp_multicast_port
    { :ok, socket } = :gen_udp.open(0, [active: true, multicast_loop: true])
    :ok = :gen_udp.send(socket, addr, port, NodeInfo.encode)
    :gen_udp.close(socket)
  end
end
