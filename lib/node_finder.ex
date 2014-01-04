defmodule NodeFinder do
  use Application.Behaviour

  def start(_type, _args) do
    override_env :send_signal
    override_env :receive_signal
    override_env :udp_multicast_address
    override_env :udp_multicast_port
    override_env :sending_interval_milliseconds
    NodeFinder.Supervisor.start_link
  end

  defp override_env(key) do
    maybe_value_str = System.get_env String.upcase(atom_to_binary(key))
    if maybe_value_str do
      { value, _ } = Code.eval_string(maybe_value_str)
      :application.set_env :node_finder, key, value
    end
  end
end
