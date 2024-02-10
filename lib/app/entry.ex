defmodule App.Entry do
  alias App.Account
  use Ecto.Schema

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type :integer

  schema "entries" do
    belongs_to(:account, Account)
    field(:amount, :integer)
    field(:description, :string)
    field(:inserted_at, :utc_datetime)
  end
end
