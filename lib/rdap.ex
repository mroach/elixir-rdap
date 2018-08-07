defmodule RDAP do
  @moduledoc """
  Client for querying RDAP servers hosted by the major NICs.

  RDAP: Registration Data Access Protocol, is a replacement for WHOIS.
  """

  use Application
  require Logger
  alias RDAP.{Database, NIC}

  def start(_type, _args), do: RDAP.Supervisor.start_link()

  def lookup_ip(ip) do
    with %NIC{} = nic <- Database.find_nic_for(ip),
         server       <- NIC.primary_server(nic)
    do
      Logger.debug fn -> "RDAP server for #{ip} is #{server}" end
      lookup_ip(ip, server)
    else
      err -> {:error, err}
    end
  end

  def lookup_ip(ip, query_base) do
    url = "#{query_base}/ip/#{ip}"
    Logger.debug fn -> "RDAP query: GET #{url}" end

    with %HTTPotion.Response{body: body, status_code: 200} <- HTTPotion.get(url),
         {:ok, json} <- Poison.decode(body)
    do
      {:ok, json}
    else
      err -> {:error, err}
    end
  end
end
