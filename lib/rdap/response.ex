defmodule RDAP.Response do
  @moduledoc """
  Wrapper for an RDAP response
  """

  alias __MODULE__

  defstruct [
    :raw_response
  ]

  def from_json(json) when is_map(json) do
    %Response{raw_response: json}
  end
end
