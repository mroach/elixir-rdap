defmodule RDAP do
  @moduledoc """
  Client for querying RDAP servers hosted by the major NICs.

  RDAP: Registration Data Access Protocol, is a replacement for WHOIS.
  """

  use Application
  require Logger
  alias RDAP.{Database, NIC, Response}

  @follow_redirects [301, 302, 303, 307, 308]

  def start(_type, _args), do: RDAP.Supervisor.start_link()

  def lookup_ip(ip) when is_tuple(ip) do
    ip
    |> Tuple.to_list
    |> Enum.join(".")
    |> lookup_ip
  end
  def lookup_ip(ip) when is_binary(ip) do
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
    url = "#{query_base}ip/#{ip}"
    Logger.info fn -> "RDAP query: GET #{url}" end

    query(url)
  end

  def query(url) do
    with {:ok, response} <- HTTPoison.get(url) do
      handle_response(response)
    else
      err -> {:error, err}
    end
  end

  def handle_response(%HTTPoison.Response{status_code: code} = resp) when code in(@follow_redirects) do
    next_location = get_header(resp, "Location")
    Logger.info fn -> "Following HTTP #{code} to #{next_location}" end
    query(next_location)
  end
  def handle_response(%HTTPoison.Response{body: body, status_code: 200} = _) do
    # The Poison docs generally advises against using atoms as keys because
    # they're never garbage collected. However, we know there are only a couple dozen
    # keys that ever appear in RDAP responses, so this isn't a real worry.
    with {:ok, json} <- Poison.decode(body, keys: :atoms)
    do
      {:ok, Response.from_json(json)}
    else
      err -> {:error, err}
    end
  end

  @doc """
  Find a response header by name

  Example:
      iex> %HTTPoison.Response{headers: [{"Location", "http://other.com"}] }
      ...> |> RDAP.get_header("Location")
      "http://other.com"
  """
  def get_header(%HTTPoison.Response{headers: headers} = _, header) do
    Enum.find_value(headers, fn
      {^header, loc} -> loc
      _ -> nil
    end)
  end
end
