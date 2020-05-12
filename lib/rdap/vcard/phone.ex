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

      iex> RDAP.VCard.Phone.parse(["tel", %{}, "uri", "tel:+18885551212"])
      %RDAP.VCard.Phone{number: "+18885551212"}
  """
  def parse(["tel", %{type: type_or_types}, _, number]) do
    %Phone{}
    |> put_number(number)
    |> put_types(type_or_types)
  end

  def parse(["tel", %{}, _, val]) do
    %Phone{}
    |> put_number(val)
  end

  def put_number(%Phone{} = phone, value) do
    phone
    |> Map.put(:number, clean_phone(value))
  end

  def put_types(%Phone{} = phone, types) when is_list(types) do
    phone
    |> Map.put(:types, types)
  end

  def put_types(%Phone{} = phone, type) do
    phone
    |> put_types([type])
  end

  def clean_phone(val) do
    val
    |> String.replace("tel:", "")
  end
end
