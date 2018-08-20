defmodule RDAP.Entity do
  @moduledoc """
  Wrapper for entity objects in RDAP responses.

  Entities may have sub-entities.
  With ARIN there's often the "registrant" as the root entity and sub entities
  that are the contacts associated with the registrant.
  """

  alias __MODULE__
  alias RDAP.{VCard}

  defstruct handle: nil, roles: [], vcard: nil, entities: []

  def parse(%{} = val) do
    %Entity{}
    |> Map.put(:handle, find_handle(val))
    |> Map.put(:roles, find_roles(val))
    |> Map.put(:vcard, find_vcard(val))
    |> Map.put(:entities, find_entities(val))
  end

  @doc """
  Finds the vcard in an entity structure

  Example:
      iex> ent = %{
      ...>   roles: ["technical"],
      ...>   vcardArray: ["vcard", [
      ...>     ["fn", %{}, "text", "Test"]
      ...>   ]]
      ...> }
      ...> RDAP.Entity.find_vcard(ent)
      %RDAP.VCard{formatted_name: "Test", raw_data: [["fn", %{}, "text", "Test"]]}
  """
  def find_vcard(%{vcardArray: ["vcard", vals]}), do: VCard.parse(vals)
  def find_vcard(%{}), do: nil

  def find_handle(%{handle: handle}), do: handle
  def find_handle(_), do: nil

  def find_roles(%{roles: roles}) when is_list(roles), do: roles
  def find_roles(_), do: []

  def find_entities(%{entities: entities}) do
    Enum.map(entities, &parse/1)
  end
  def find_entities(_), do: []
end
