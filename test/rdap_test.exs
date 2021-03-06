defmodule RDAPTest do
  use ExUnit.Case
  alias RDAP.Response

  doctest RDAP

  @doc """
  The json files are real responses captured via cURL. Parse each one to
  make sure there are no errors. Obviously it's not a thorough test but it should
  help to ensure that responses can at least be parsed without dying
  """
  test "all real-world responses can be parsed" do
    for sample_file <- Path.wildcard("test/fixtures/rdap_responses/**/*.json") do
      json = sample_file |> File.read!() |> Jason.decode!(keys: :atoms)
      assert %Response{} = Response.from_json(json)
    end
  end

  test "detects special IPs" do
    assert {:error, :special_ip} = RDAP.lookup_ip("127.0.0.1")
    assert {:error, :special_ip} = RDAP.lookup_ip("192.168.1.12")
  end
end
