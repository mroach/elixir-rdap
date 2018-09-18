defmodule RDAPTest do
  use ExUnit.Case
  alias RDAP.{Response}
  import Mock

  doctest RDAP

  @doc """
  The json files are real responses captured via cURL. Parse each one to
  make sure there are no errors. Obviously it's not a thorough test but it should
  help to ensure that responses can at least be parsed without dying
  """
  test "all real-world responses can be parsed" do
    for sample_file <- Path.wildcard("test/fixtures/rdap_responses/**/*.json") do
      json = sample_file |> File.read! |> Poison.decode!(keys: :atoms)
      assert %Response{} = Response.from_json(json)
    end
  end

  test "follows 303 redirect" do
    next_location = "http://example.org"
    see_other_response = %HTTPoison.Response{
      status_code: 303,
      headers: [
        {"Location", next_location}
      ]
    }

    with_mock HTTPoison, [get: fn(^next_location) -> "OK" end] do
      RDAP.handle_response(see_other_response)
      assert_called HTTPoison.get(next_location)
    end
  end
end
