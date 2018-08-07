defmodule RDAP.Supervisor do
  @moduledoc """
  Supervisor for RDAP. Loads the database and keeps it running
  """
  use Supervisor

  def start_link(default \\ []) do
    Supervisor.start_link(__MODULE__, default, name: __MODULE__)
  end

  def init(_default) do
    children = [
      {RDAP.Database, Application.get_env(:rdap, :ipv4_relpath)}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
