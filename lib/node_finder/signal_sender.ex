alias NodeFinder.NodeInfo, as: NodeInfo

defmodule NodeFinder.SignalSender do
  use GenServer.Behaviour

  # Public API
  def start_link do
    :gen_server.start_link({ :local, :node_finder_signal_sender }, __MODULE__, [], [])
  end

  def send do
    :node_finder_signal_sender <- :send
    :ok
  end

  # Callbacks
  def init([]) do
    { :ok, :erlang.send_after(1, self, :send) }
  end

  def handle_info(:send, old_timer) do
    :erlang.cancel_timer(old_timer)
    send_signal
    { :ok, millis } = :application.get_env :sending_interval_milliseconds
    { :noreply, :erlang.send_after(millis, self, :send) }
  end

  defp send_signal do
    :error_logger.info_msg "Sending node info...\n"
    { :ok, addr } = :application.get_env :udp_multicast_address
    { :ok, port } = :application.get_env :udp_multicast_port
    { :ok, socket } = :gen_udp.open(0, [active: true, multicast_loop: true])
    :gen_udp.send(socket, addr, port, NodeInfo.encode)
    :gen_udp.close(socket)
  end
end
