defmodule RDAP.DatabaseTest do
  use ExUnit.Case
  alias RDAP.Database
  doctest RDAP.Database

  test "can read bootstrap data" do
    {:ok, result} = Database.read_bootstrap("priv/iana/ipv4.json")
    assert is_list(result)
  end

  test "doesn't fail when file doesn't exist" do
    assert Database.read_bootstrap("/bogus") == {:error, :enoent}
  end

  describe "Database.find_nic_for/1" do
    test "can find RDAP servers for ARIN string IP" do
      result = Database.find_nic_for("8.8.8.8")
      assert Enum.member?(result.endpoints, "http://rdap.arin.net/registry/")
    end

    test "can find RDAP servers for ARIN tuple IP" do
      result = Database.find_nic_for({8, 8, 8, 8})
      assert Enum.member?(result.endpoints, "http://rdap.arin.net/registry/")
    end

    test "does not find an RDAP server for reserved IP" do
      result = Database.find_nic_for("254.0.0.0")
      assert result == nil
    end
  end
end
