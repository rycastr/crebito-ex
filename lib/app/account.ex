defmodule App.Account do
  alias App.Entry
  use Ecto.Schema

  schema "accounts" do
    field :balance, :integer
    field :available_limit, :integer
    has_many :entries, Entry
  end
end
