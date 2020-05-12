defmodule RDAP.HTTPTest do
  use ExUnit.Case
  alias RDAP.{HTTP}
  import Mock

  doctest RDAP.HTTP

  test "follows 303 redirect" do
    next_location = "http://example.org"

    see_other_response = %HTTPoison.Response{
      status_code: 303,
      headers: [
        {"Location", next_location}
      ]
    }

    with_mock HTTPoison, get: fn ^next_location -> "OK" end do
      HTTP.handle_response(see_other_response)
      assert_called(HTTPoison.get(next_location))
    end
  end

  test "recognising rdap content type" do
    rdap_http_response = %HTTPoison.Response{
      status_code: 200,
      body: File.read!("test/fixtures/rdap_responses/ripe/de-versatel.json"),
      headers: [
        {"Content-Type", "application/rdap+json"}
      ]
    }

    assert {:ok, %RDAP.Response{}} = HTTP.handle_response(rdap_http_response)
  end

  test "unrecognised response type" do
    resp = %HTTPoison.Response{
      status_code: 200,
      body: "OK",
      headers: [
        {"Content-Type", "text/plain"}
      ]
    }

    assert {:error, "Unsupported response type 'text/plain'"} = HTTP.handle_response(resp)
  end
end
