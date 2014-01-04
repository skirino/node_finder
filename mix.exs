defmodule NodeFinder.Mixfile do
  use Mix.Project

  def project do
    [
      app:     :node_finder,
      version: "0.0.1",
      elixir:  "~> 0.12.0",
      deps:    deps,
    ]
  end

  def application do
    [
      mod: { NodeFinder, [] },
      env: [ # Default settings: can be overridden by runtime environment variables
        send_signal:                   true,
        receive_signal:                true,
        udp_multicast_address:         { 239, 255, 0, 1 },
        udp_multicast_port:            60900,
        sending_interval_milliseconds: 5 * 60 * 1000,
      ],
    ]
  end

  defp deps do
    []
  end
end
