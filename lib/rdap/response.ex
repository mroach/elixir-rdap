defmodule RDAP.Response do
  @moduledoc """
  Wrapper for an RDAP response.

  See: https://tools.ietf.org/html/rfc7483
  """

  alias __MODULE__
  alias RDAP.Entity

  defstruct raw_response: nil,
            entities: []

  def from_json(json) when is_map(json) do
    %Response{raw_response: json, entities: Entity.parse(json)}
  end
end
