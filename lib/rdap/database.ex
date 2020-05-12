defmodule RDAP.Database do
  @moduledoc """
  Creates and manages a server for the RDAP database read from a JSON file
  """

  use GenServer
  require Logger
  alias RDAP.NIC

  def start_link(path) do
    GenServer.start_link(__MODULE__, path, name: __MODULE__)
  end

  @doc """
  Finds the RDAP.NIC that is responsible for the given IP
  """
  def find_nic_for(ip) do
    GenServer.call(__MODULE__, {:find_nic_for, ip})
  end

  @doc """
  Gets all registered NICs
  """
  def all do
    GenServer.call(__MODULE__, {:all})
  end

  @impl true
  def init(path) do
    read_bootstrap(path)
  end

  @impl true
  def handle_call({:find_nic_for, ip}, _, state) do
    answer =
      case Enum.find(state, fn nic -> NIC.handles_ip?(nic, ip) end) do
        %NIC{} = nic -> nic
        _ -> nil
      end

    {:reply, answer, state}
  end

  def handle_call({:all}, _, state) do
    {:reply, state, state}
  end

  @doc """
  Reads an IANA bootstrap file from disk and loads it into structs

  Example:
      iex> RDAP.Database.read_bootstrap("/bogus")
      {:error, :enoent}
  """
  def read_bootstrap(path) do
    Logger.info(fn -> "Loading bootstrap from #{path}" end)

    with {:ok, str} <- File.read(path),
         {:ok, data} <- Poison.decode(str) do
      {:ok, load_iana(data)}
    else
      err -> err
    end
  end

  @doc """
  Maps data from an IANA-style RDAP bootstrap into NIC configs

  Examples:
      iex> data = %{ "services" => [ [["8.0.0.0/8"], ["http://rdap.example.net"]] ] }
      ...> RDAP.Database.load_iana(data)
      [
        %RDAP.NIC{ blocks: [{{8,0,0,0},{8,255,255,255},8}], endpoints: ["http://rdap.example.net/"] }
      ]
  """
  def load_iana(data) do
    data
    |> Map.get("services")
    |> Enum.map(fn service ->
      %NIC{
        blocks: service |> Enum.at(0) |> Enum.map(&InetCidr.parse/1),
        endpoints: service |> Enum.at(1) |> Enum.map(&normalize_endpoint/1)
      }
    end)
  end

  defp normalize_endpoint(endpoint) do
    if String.ends_with?(endpoint, "/"), do: endpoint, else: "#{endpoint}/"
  end
end
