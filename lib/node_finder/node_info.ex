defmodule NodeFinder.NodeInfo do
  def encode do
    node_str = Atom.to_string(node)
    message = "node_finder" <> <<now_seconds::64, node_str::binary>>
    encrypt(message)
  end

  def decode(bin) do
    case decrypt(bin) do
      <<"node_finder", now_seconds::64, node_str::binary>> ->
        if within_allowed_time_window(now_seconds) do
          { :ok, node_str }
        else
          { :error, "NodeInfo already expired." }
        end
      _ -> { :error, "Failed to decode received NodeInfo." }
    end
  end

  defp now_seconds do
    :calendar.datetime_to_gregorian_seconds(:calendar.universal_time)
  end
  defp within_allowed_time_window(t) do
    abs(now_seconds - t) < 300
  end

  defp encrypt(plain) do
    { _new_state, cipher_str } = :crypto.stream_encrypt(encryption_initial_state, plain)
    cipher_str
  end
  defp decrypt(encrypted) do
    { _new_state, plain_str } = :crypto.stream_decrypt(encryption_initial_state, encrypted)
    plain_str
  end
  defp encryption_initial_state do
    :crypto.stream_init(:rc4, encryption_key)
  end
  defp encryption_key do
    Atom.to_string(Node.get_cookie) <> "3c7c4940b6"
  end
end
