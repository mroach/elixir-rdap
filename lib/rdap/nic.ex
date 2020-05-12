defmodule RDAP.NIC do
  @moduledoc """
  A NIC (Network Information Center) is an entity responsible for the allocation of
  internet names and numbers in a region. Current NICs are:

  * ARIN - US + Canada
  * RIPE - Europe and Middle East
  * LACNIC - Latin America and Caribbean
  * APNIC - Asia Pacific
  * AFRINIC - Africa

  Each NIC here will hold the CIDR blocks it is responsible for as well as the
  RDAP endpoints available. Typically each NIC has just one endpoint but two entires:
  one for HTTPS and one for HTTP.
  """

  defstruct [:blocks, :endpoints]

  @type t :: %__MODULE__{blocks: List.t(), endpoints: List.t()}

  @doc """
  Determines if the NIC is responsible for the given IP address

  Examples:
      iex> nic = %RDAP.NIC{blocks: [{{31,0,0,0}, {31,255,255,255}, 8}]}
      ...> RDAP.NIC.handles_ip?(nic, "31.7.23.1")
      true

      iex> nic = %RDAP.NIC{blocks: [{{31,0,0,0}, {31,255,255,255}, 8}]}
      ...> RDAP.NIC.handles_ip?(nic, {31,7,23,1})
      true

      iex> nic = %RDAP.NIC{blocks: [{{31,0,0,0}, {31,255,255,255}, 8}]}
      ...> RDAP.NIC.handles_ip?(nic, {8,8,8,8})
      false
  """
  def handles_ip?(%RDAP.NIC{} = nic, ip) when is_binary(ip) do
    handles_ip?(nic, InetCidr.parse_address!(ip))
  end

  def handles_ip?(%RDAP.NIC{} = nic, ip) when is_tuple(ip) do
    nic.blocks
    |> Enum.any?(fn cidr -> InetCidr.contains?(cidr, ip) end)
  end

  @doc """
  Return the primary server for the NIC with the required scheme. Default is https

  Examples:
      iex> nic = %RDAP.NIC{endpoints: ["https://rdap.example.net", "http://rdap.example.net"]}
      ...> RDAP.NIC.primary_server(nic)
      "https://rdap.example.net"

      iex> nic = %RDAP.NIC{endpoints: ["http://rdap.example.net"]}
      ...> RDAP.NIC.primary_server(nic, "https")
      nil
  """
  def primary_server(%RDAP.NIC{endpoints: endpoints} = _, scheme \\ "https") do
    endpoints
    |> Enum.find(fn str -> String.starts_with?(str, "#{scheme}://") end)
  end
end
