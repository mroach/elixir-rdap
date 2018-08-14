defmodule RDAP.VCard.Address do
  @moduledoc """
  Physical address from a vCard
  """

  alias __MODULE__

  defstruct [:type, :lines]

  @doc """
  Parses an address from a vCard element.

  Often addresses come pre-formatted under the "label" attribute.
  When these are present, they're split into lines and used as the address.

  Examples:
      iex> RDAP.VCard.Address.parse(["adr", %{label: "123 Pumpkin St\\nCandyland\\nXX\\n00000\\nUSA"}, "text", [""]])
      %RDAP.VCard.Address{lines: ["123 Pumpkin St", "Candyland", "XX", "00000", "USA"]}

      iex> RDAP.VCard.Address.parse(["adr", %{type: "work"}, "text", ["CandyCorp", "123 Pumpkin St", "Candyland", "XX", "00000", "USA"]])
      %RDAP.VCard.Address{type: "work", lines: ["CandyCorp", "123 Pumpkin St", "Candyland", "XX", "00000", "USA"]}
  """
  def parse(["adr", attrs, "text", lines]) do
    %Address{type: Map.get(attrs, :type), lines: extract_address(attrs, lines)}
  end

  def extract_address(%{label: formatted}, _) do
    String.split(formatted, "\n")
  end
  def extract_address(_, lines), do: lines

  @doc """
  Example:
      iex> %RDAP.VCard.Address{lines: ["CandyCorp", "123 Pumpkin St", "Candyland", "XX", "00000", "USA"]}
      ...> |> RDAP.VCard.Address.addressee
      "CandyCorp"
  """
  def addressee(%Address{lines: lines}), do: Enum.at(lines, 0)

  @doc """
  Example:
      iex> %RDAP.VCard.Address{lines: ["CandyCorp", "123 Pumpkin St", "Candyland", "XX", "00000", "USA"]}
      ...> |> RDAP.VCard.Address.street
      "123 Pumpkin St"
  """
  def street(%Address{lines: lines}), do: Enum.at(lines, 1)

  @doc """
  Example:
      iex> %RDAP.VCard.Address{lines: ["CandyCorp", "123 Pumpkin St", "Candyland", "XX", "00000", "USA"]}
      ...> |> RDAP.VCard.Address.city
      "Candyland"
  """
  def city(%Address{lines: lines}), do: Enum.at(lines, 2)

  @doc """
  Example:
      iex> %RDAP.VCard.Address{lines: ["CandyCorp", "123 Pumpkin St", "Candyland", "XX", "00000", "USA"]}
      ...> |> RDAP.VCard.Address.state_province
      "XX"
  """
  def state_province(%Address{lines: lines}), do: Enum.at(lines, 3)

  @doc """
  Example:
      iex> %RDAP.VCard.Address{lines: ["CandyCorp", "123 Pumpkin St", "Candyland", "XX", "00000", "USA"]}
      ...> |> RDAP.VCard.Address.postcode
      "00000"
  """
  def postcode(%Address{lines: lines}), do: Enum.at(lines, 4)

  @doc """
  Example:
      iex> %RDAP.VCard.Address{lines: ["CandyCorp", "123 Pumpkin St", "Candyland", "XX", "00000", "USA"]}
      ...> |> RDAP.VCard.Address.country
      "USA"
  """
  def country(%Address{lines: lines}), do: Enum.at(lines, 5)
end
