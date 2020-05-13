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
        rdap_response(%{"hello" => "world"})

      %{url: "http://rdap/1.2.3.4"} ->
        File.read!("test/fixtures/rdap_responses/ripe/de-versatel.json")
        |> rdap_response()
    end)

    :ok
  end

  defp rdap_response(data) when is_map(data) do
    data |> json() |> Tesla.put_header("content-type", "application/rdap+json")
  end

  defp rdap_response(data) when is_binary(data) do
    data |> Jason.decode!() |> rdap_response()
  end

  @tag capture_log: true
  test "follows 303 redirect" do
    assert {:ok, %{raw_response: %{hello: "world"}}} =
             HTTP.get_and_parse("http://redirect-me.com/")
  end

  @tag capture_log: true
  test "recognising rdap content type" do
    assert {:ok, %RDAP.Response{}} = HTTP.get_and_parse("http://rdap/1.2.3.4")
  end

  @tag capture_log: true
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
