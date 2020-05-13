defmodule RDAP.HTTP do
  @moduledoc """
  HTTP client for accessing RDAP services.

  A few key points for RDAP:

  HTTP 303 is used, at least by ARIN, when a requested IP is being managed by another NIC.
  For example 144.178.9.74 is owned by Apple, so falls under ARIN, but it's used by
  Apple in Europe so when you query ARIN you get 303'd over to RIPE.

  RDAP responses use the content type `application/rdap+json` which we'll use to
  automatically decode the response. Other types are ignored.
  """
  require Logger
  alias RDAP.Response

  use Tesla

  @rdap_types ~w[application/rdap+json]

  plug Tesla.Middleware.Logger
  plug Tesla.Middleware.FollowRedirects, max_redirects: 3
  plug Tesla.Middleware.Headers, [{"accept", Enum.join(@rdap_types, ", ")}]
  plug Tesla.Middleware.JSON, decode_content_types: @rdap_types

  def get(url) do
    case get(url) do
      {:ok, response} -> handle_response(response)
      other -> {:error, other}
    end
  end

  def handle_response(%Tesla.Env{body: body, status: 200} = resp) do
    type = Tesla.get_header(resp, "content-type")
    parse_body(body, type)
  end

  def handle_response(%Tesla.Env{status: code} = _) do
    {:error, "Not handling HTTP #{code} responses"}
  end

  def parse_body(body, type) when type in @rdap_types do
    # The Jason docs generally advises against using atoms as keys because
    # they're never garbage collected. However, we know there are only a couple dozen
    # keys that ever appear in RDAP responses, so this isn't a real worry.
    case Jason.decode(body, keys: :atoms) do
      {:ok, json} ->
        {:ok, Response.from_json(json)}

      other ->
        {:error, other}
    end
  end

  def parse_body(_body, type) do
    {:error, "Unsupported response type '#{type}'"}
  end
end
