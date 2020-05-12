defmodule RDAP.EntityTest do
  use ExUnit.Case
  doctest RDAP.Entity

  alias RDAP.{Entity}

  test "handles no usable data" do
    assert Entity.parse(%{}) == %Entity{}
  end

  test "captures a handle" do
    assert Entity.parse(%{handle: "XYZ"}) == %Entity{handle: "XYZ"}
  end

  test "captures an entity with a vcard" do
    sample = %{
      roles: ["technical"],
      vcardArray: [
        "vcard",
        [
          ["fn", %{}, "text", "Test"]
        ]
      ]
    }

    parsed = Entity.parse(sample)
    assert parsed.vcard.formatted_name == "Test"
    assert parsed.roles == ["technical"]
  end

  test "handles a real ARIN response" do
    entity =
      File.read!("test/fixtures/rdap_responses/ripe/de-vodafone-cable.json")
      |> Jason.decode!(keys: :atoms)
      |> Map.get(:entities)
      |> Enum.at(0)
      |> Entity.parse()

    assert entity.handle == "AR13599-RIPE"
    assert entity.vcard.formatted_name == "Kabel Deutschland Abuse"

    assert entity.vcard.address.formatted ==
             "Vodafone Kabel Deutschland GmbH\nBetastrasse 6-8\n85774 Unterfoehring\nDE"
  end
end
