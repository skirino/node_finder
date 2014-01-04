alias NodeFinder.NodeInfo, as: NodeInfo

defmodule NodeFinder.SignalSender do
  use GenServer.Behaviour

  def start_link do
    :gen_server.start_link(__MODULE__, [], [])
  end

  def init([]) do
    { :ok, t } = :timer.send_after(1, self, :send)
    { :ok, t }
  end

  def handle_info(:send, _old_timer) do
    send_signal
    { :ok, millis } = :application.get_env :sending_interval_milliseconds
    { :ok, t } = :timer.send_after(millis, self, :send)
    { :noreply, t }
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
