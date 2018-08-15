defmodule RDAP.VCard.Address do
  @moduledoc """
  Physical address from a vCard
  """

  alias __MODULE__

  defstruct [:type, :lines, :formatted]

  @doc """
  Parses an address from a vCard element.

  Often addresses come pre-formatted under the "label" attribute. These will
  go into the `formatted` attribute. In many cases it would be possible to simply
  split on newline and use this instead of the address lines. However the responses
  aren't uniform enough. Many lack addressee, some don't split the city and postcode,
  many omit at least one element.

  Examples:
      iex> RDAP.VCard.Address.parse(["adr", %{label: "88 Lucky Ave\\nChinatown\\nXX\\n00000\\nUSA"}, "text", [""]])
      %RDAP.VCard.Address{formatted: "88 Lucky Ave\\nChinatown\\nXX\\n00000\\nUSA", lines: [""]}

      iex> RDAP.VCard.Address.parse(["adr", %{type: "work"}, "text", ["CandyCorp", "123 Pumpkin St", "Candyland", "XX", "00000", "USA"]])
      %RDAP.VCard.Address{type: "work", lines: ["CandyCorp", "123 Pumpkin St", "Candyland", "XX", "00000", "USA"]}
  """
  def parse(["adr", attrs, "text", lines]) do
    %Address{}
    |> Map.put(:type, Map.get(attrs, :type))
    |> Map.put(:formatted, Map.get(attrs, :label))
    |> Map.put(:lines, lines)
  end

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
