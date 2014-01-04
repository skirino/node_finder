alias NodeFinder.NodeInfo, as: NInfo

defmodule NodeFinder.NodeInfoTest do
  use ExUnit.Case

  test "encode and decode NodeInfo" do
    binary = NInfo.encode
    { :ok, node_str } = NInfo.decode(binary)
    assert node_str == atom_to_binary(node)
  end
end
