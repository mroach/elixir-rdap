defmodule RDAP.HTTP do
  @moduledoc """
  Simple wrapper around HTTPoison to handle HTTP-related logic.
  A few key points for RDAP:

  HTTP 303 is used, at least by ARIN, when a requested IP is being managed by another NIC.
  For example 144.178.9.74 is owned by Apple, so falls under ARIN, but it's used by
  Apple in Europe so when you query ARIN you get 303'd over to RIPE.

  RDAP responses use the content type `application/rdap+json` which we'll use to
  automatically decode the response. Other types are ignored.
  """
  require Logger
  alias RDAP.Response

  @follow_redirects [301, 302, 303, 307, 308]
  @rdap_types ~w[application/rdap+json]

  def get(url) do
    case HTTPoison.get(url) do
      {:ok, response} -> handle_response(response)
      other -> {:error, other}
    end
  end

  def handle_response(%HTTPoison.Response{status_code: code} = resp)
      when code in @follow_redirects do
    next_location = get_header(resp, "Location")
    Logger.info(fn -> "Following HTTP #{code} to #{next_location}" end)
    get(next_location)
  end

  def handle_response(%HTTPoison.Response{body: body, status_code: 200} = resp) do
    type = get_header(resp, "Content-Type")
    parse_body(body, type)
  end

  def handle_response(%HTTPoison.Response{status_code: code} = _) do
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

  @doc """
  Find a response header by name

  Example:
      iex> %HTTPoison.Response{headers: [{"Location", "http://other.com"}] }
      ...> |> RDAP.HTTP.get_header("Location")
      "http://other.com"
  """
  def get_header(%HTTPoison.Response{headers: headers} = _, header) do
    Enum.find_value(headers, fn
      {^header, loc} -> loc
      _ -> nil
    end)
  end
end
