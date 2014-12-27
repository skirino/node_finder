alias NodeFinder.NodeInfo, as: NodeInfo

defmodule NodeFinder.SignalReceiver do
  require Logger
  use GenServer

  # Public API
  def start_link do
    :gen_server.start_link(__MODULE__, [], [])
  end

  # Callbacks
  def init([]) do
    { :ok, addr } = :application.get_env :udp_multicast_address
    { :ok, port } = :application.get_env :udp_multicast_port
    opts = [
      :binary,
      { :active, true },
      { :add_membership, { addr, { 0, 0, 0, 0 } } },
    ]
    { :ok, socket } = :gen_udp.open(port, opts)
    { :ok, socket }
  end

  def terminate(_reason, orig_socket) do
    :gen_udp.close(orig_socket)
    :ok
  end

  def handle_info({ :udp, _socket, _ip, _port, packet }, orig_socket) do
    { :ok, node_str } = NodeInfo.decode(packet)
    connect_if_not_yet(String.to_atom(node_str))
    { :noreply, orig_socket }
  end

  defp connect_if_not_yet(node) do
    if node != Node.self && !Enum.member?(Node.list, node) do
      Logger.info("[#{__MODULE__}] Trying to connect to '#{node}'...")
      if !Node.connect(node) do
        Logger.info("[#{__MODULE__}] Failed to establish connection to '#{node}'.")
      end
    end
  end
end
