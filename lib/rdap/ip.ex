defmodule RDAP.IP do
  @moduledoc """
  Utilities for dealing with IP addresses such as detecting non-routable
  """

  @private_v4 [
    {{10, 0, 0, 0}, {10, 255, 255, 255}, 8},
    {{172, 16, 0, 0}, {172, 31, 255, 255}, 12},
    {{192, 168, 0, 0}, {192, 168, 255, 255}, 16}
  ]

  @link_local [
    {{169, 254, 0, 0}, {169, 254, 255, 255}, 16}
  ]

  @loopback [
    {{127, 0, 0, 0}, {127, 255, 255, 255}, 8},
  ]

  @doc """
  Determine if the IP is "special". Specials are:

  * Private subnets (usually for LANs behind NAT)
  * Link-local addresses
  * Loopback

  There are other cases we're not covering since they're not currently relevant.
  https://en.wikipedia.org/wiki/IPv4#Special-use_addresses

  Example:
      iex> RDAP.IP.special?("127.0.0.1")
      true

      iex> RDAP.IP.special?("10.65.49.15")
      true

      iex> RDAP.IP.special?("24.35.153.229")
      false
  """
  def special?(ip) when is_binary(ip) do
    ip |> InetCidr.parse_address! |> special?
  end
  def special?(ip) when is_tuple(ip) do
    private?(ip) || loopback?(ip) || link_local?(ip)
  end

  @doc """
  Determine if the given IP is a private address

  Example:
      iex> RDAP.IP.private?("192.168.1.1")
      true

      iex> RDAP.IP.private?("172.19.10.178")
      true

      iex> RDAP.IP.private?("10.98.54.3")
      true

      iex> RDAP.IP.private?("1.1.1.1")
      false
  """
  def private?(ip) when is_binary(ip) do
    ip |> InetCidr.parse_address! |> private?
  end
  def private?(ip) when is_tuple(ip) do
    @private_v4
    |> Enum.any?(fn block -> InetCidr.contains?(block, ip) end)
  end

  @doc """
  Determine if the given IP is a link-local address

  Example:
      iex> RDAP.IP.link_local?("169.254.1.1")
      true

      iex> RDAP.IP.link_local?("169.1.1.1")
      false
  """
  def link_local?(ip) when is_binary(ip) do
    ip |> InetCidr.parse_address! |> link_local?
  end
  def link_local?(ip) when is_tuple(ip) do
    @link_local
    |> Enum.any?(fn block -> InetCidr.contains?(block, ip) end)
  end

  @doc """
  Determine if the given IP is a loopback address

  Example:
      iex> RDAP.IP.loopback?("127.0.0.1")
      true

      iex> RDAP.IP.loopback?("128.1.1.1")
      false
  """
  def loopback?(ip) when is_binary(ip) do
    ip |> InetCidr.parse_address! |> loopback?
  end
  def loopback?(ip) when is_tuple(ip) do
    @loopback
    |> Enum.any?(fn block -> InetCidr.contains?(block, ip) end)
  end
end
