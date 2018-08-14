defmodule RDAP.VCard do
  @moduledoc """
  Reads a vCard from an RDAP response. Note these use the [jCard](https://tools.ietf.org/html/rfc7095) format
  within the JSON response
  """

  alias __MODULE__
  alias RDAP.VCard.{Phone}

  defstruct [:raw_data]

  @doc """
  Find the email in the vCard

  Example:
      iex> %RDAP.VCard{raw_data: [ ["email", %{}, "text", "i@example.org"], ["fn", {}, "text", "Fancy Corp"] ]}
      ...> |> RDAP.VCard.email
      "i@example.org"
  """
  def email(%VCard{} = card), do: card |> find_field("email") |> text_value

  @doc """
  Card type. Usually one of: application, individual, group, location, organization

  Example:
      iex> %RDAP.VCard{raw_data: [ ["kind", %{}, "text", "individual"] ]}
      ...> |> RDAP.VCard.kind
      "individual"
  """
  def kind(%VCard{} = card), do: card |> find_field("kind") |> text_value

  @doc """
  Find the formatted name "fn" field from the vCard

  Example:
      iex> %RDAP.VCard{raw_data: [ ["email", %{}, "text", "i@example.org"], ["fn", {}, "text", "Fancy Corp"] ]}
      ...> |> RDAP.VCard.formatted_name
      "Fancy Corp"
  """
  def formatted_name(%VCard{} = card), do: card |> find_field("fn") |> text_value

  @doc """
  Gets the phone number.

  Example:
      iex> %RDAP.VCard{raw_data: [ ["email", %{}, "text", "i@example.org"], ["tel", %{type: "work"}, "text", "+1-888-555-1212"] ]}
      ...> |> RDAP.VCard.phone
      %RDAP.VCard.Phone{types: ["work"], number: "+1-888-555-1212"}

      iex> %RDAP.VCard{raw_data: [ ["email", %{}, "text", "i@example.org"] ]}
      ...> |> RDAP.VCard.phone
      nil
  """
  def phone(%VCard{} = card) do
    case find_field(card, "tel") do
      nil -> nil
      val -> Phone.parse(val)
    end
  end

  @doc """
  Finds the address in the vCard. Some addresses use the "label" attribute to provide
  the formatted address. If this is available, we'll use that.
  If not, we'll use the array of values [Addressee, Street, City, State, Postcode, Country]
  TODO: Structure to include the "type" attribute (e.g. work, home)

  Example:
      iex> %RDAP.VCard{raw_data: [ ["adr", %{label: "123 Pumpkin St\\nCandyland\\nXX\\n00000\\nUSA"}, "text", [""] ] ]}
      ...> |> RDAP.VCard.address
      ["123 Pumpkin St", "Candyland", "XX", "00000", "USA"]

      iex> %RDAP.VCard{raw_data: [ ["adr", %{type: "work"}, "text", ["CandyCorp", "123 Pumpkin St", "Candyland", "XX", "00000", "USA"] ] ]}
      ...> |> RDAP.VCard.address
      ["CandyCorp", "123 Pumpkin St", "Candyland", "XX", "00000", "USA"]
  """
  def address(%VCard{} = card) do
    case find_field(card, "adr") do
      [_, %{label: label}, "text" | _] -> String.split(label, "\n")
      [_, _, "text", lines] -> lines
      _ -> nil
    end
  end

  @doc """
  Finds a vCard field by name

  Example:
      iex> %RDAP.VCard{raw_data: [ ["email", %{}, "text", "i@example.org"], ["fn", {}, "text", "Fancy Corp"] ]}
      ...> |> RDAP.VCard.find_field("fn")
      ["fn", {}, "text", "Fancy Corp"]
  """
  def find_field(%VCard{raw_data: data} = _, field_name) do
    Enum.find(data, fn el -> Enum.at(el, 0) == field_name end)
  end

  @doc """
  For values where you know there's only one text value, this returns that.
  If there's any tail to the list, it's ignored.

  Example:
      iex> RDAP.VCard.text_value(["categories", %{}, "text", "net", "it"])
      "net"
  """
  def text_value([_, _, "text", val | _] = _), do: val
  def text_value(_), do: nil
end
