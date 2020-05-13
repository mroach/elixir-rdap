defmodule RDAP do
  @moduledoc """
  Client for querying RDAP servers hosted by the major NICs.

  RDAP: Registration Data Access Protocol, is a replacement for WHOIS.
  """

  use Application
  require Logger
  alias RDAP.{Database, HTTP, IP, NIC}

  def start(_type, _args), do: RDAP.Supervisor.start_link()

  @doc """
  Same as `RDAP.query_ip/1` except first checks if an IP is special and if so, doesn't query.
  """
  def lookup_ip(ip) do
    case IP.special?(ip) do
      true -> {:error, :special_ip}
      _ -> query_ip(ip)
    end
  end

  @doc """
  Queries the appropriate RDAP server for the given IP.
  Uses the IANA-provided bootstrap to figure out the best NIC server
  to query.

  Returns `{:ok, %RDAP.Response{}}` on success or `{:error, reason}` on failure
  """
  def query_ip(ip) when is_tuple(ip) do
    ip
    |> Tuple.to_list()
    |> Enum.join(".")
    |> query_ip
  end

  def query_ip(ip) when is_binary(ip) do
    with %NIC{} = nic <- Database.find_nic_for(ip),
         server <- NIC.primary_server(nic) do
      Logger.debug(fn -> "RDAP server for #{ip} is #{server}" end)
      query_ip(ip, server)
    else
      err -> {:error, err}
    end
  end

  def query_ip(ip, query_base) do
    url = "#{query_base}ip/#{ip}"
    Logger.info(fn -> "RDAP query: GET #{url}" end)

    HTTP.get_and_parse(url)
  end
end
