defmodule RDAP.VCard.Phone do
  @moduledoc """
  Represents a phone number in a vCard

  Phone numbers typically come with one or more "type" indicators such as home,
  mobile, work.
  """

  alias __MODULE__

  defstruct [:types, :number]

  @doc """
  Parse the attributes and text from a vCard element. Some cards will have a single
  type for the phone while others will have an array of types (e.g. home, mobile)

  Examples:
      iex> RDAP.VCard.Phone.parse(["tel", %{type: ["home", "mobile"]}, "text", "+18885551212"])
      %RDAP.VCard.Phone{types: ["home", "mobile"], number: "+18885551212"}

      iex> RDAP.VCard.Phone.parse(["tel", %{type: "work"}, "text", "+18885551212"])
      %RDAP.VCard.Phone{types: ["work"], number: "+18885551212"}

      iex> RDAP.VCard.Phone.parse(["tel", %{}, "text", "+18885551212"])
      %RDAP.VCard.Phone{number: "+18885551212"}
  """
  def parse(["tel", %{type: types}, "text", val]) when is_list(types) do
    %Phone{types: types, number: val}
  end
  def parse(["tel", %{type: type}, "text", val]) when is_binary(type) do
    %Phone{types: [type], number: val}
  end
  def parse(["tel", %{}, "text", val]) do
    %Phone{number: val}
  end
end
