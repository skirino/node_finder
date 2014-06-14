defmodule NodeFinder.Supervisor do
  use Supervisor

  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = Enum.filter([
        child_worker(:send_signal,      NodeFinder.SignalSender),
        child_worker(:receive_signal,   NodeFinder.SignalReceiver),
        child_worker(:watch_connection, NodeFinder.ConnectionWatcher),
      ], fn(w) -> w end)
    supervise(children, strategy: :one_for_one)
  end

  defp run_child?(key) do
    { :ok, value } = :application.get_env key
    value
  end
  defp child_worker(key, mod) do
    if run_child?(key) do
      worker(mod, [])
    else
      :nil
    end
  end
end
