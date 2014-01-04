defmodule NodeFinder.NodeInfo do
  def encode do
    node_str = atom_to_binary(node)
    message = <<now_seconds::64, node_str::binary>>
    <<calc_hmac(message)::binary, message::binary>>
  end

  def decode(bin) do
    <<hash::[size(20), binary], t::64, node_str::binary>> = bin
    if calc_hmac(<<t::64, node_str::binary>>) == hash && within_allowed_time_window(t) do
      { :ok, node_str }
    else
      { :error, "Failed to decode NodeInfo!" }
    end
  end

  defp now_seconds do
    :calendar.datetime_to_gregorian_seconds(:calendar.universal_time)
  end
  defp within_allowed_time_window(t) do
    abs(now_seconds - t) < 300
  end

  defp calc_hmac(message) do
    :crypto.hmac(:sha, hmac_key, message)
  end
  defp hmac_key do
    atom_to_binary(Node.get_cookie) <> hmac_salt
  end
  defp hmac_salt do
    "3c7c4940b6"
  end
end
