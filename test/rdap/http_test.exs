defmodule RDAP.HTTPTest do
  use ExUnit.Case
  import Tesla.Mock

  alias RDAP.HTTP

  doctest RDAP.HTTP

  setup do
    mock(fn
      %{url: "http://redirect-me.com/"} ->
        %Tesla.Env{status: 303, headers: [{"location", "http://next-location.com/"}]}

      %{url: "http://next-location.com/"} ->
        json(%{"hello" => "world"})
    end)

    :ok
  end

  test "follows 303 redirect" do
    assert {:ok, %{body: %{"hello" => "world"}}} = HTTP.get("http://redirect-me.com/")
  end

  test "recognising rdap content type" do
    resp = %Tesla.Env{
      status: 200,
      body: File.read!("test/fixtures/rdap_responses/ripe/de-versatel.json"),
      headers: [
        {"content-type", "application/rdap+json"}
      ]
    }

    assert {:ok, %RDAP.Response{}} = HTTP.handle_response(resp)
  end

  test "unrecognised response type" do
    resp = %Tesla.Env{
      status: 200,
      body: "OK",
      headers: [
        {"content-type", "text/plain"}
      ]
    }

    assert {:error, "Unsupported response type 'text/plain'"} = HTTP.handle_response(resp)
  end
end
