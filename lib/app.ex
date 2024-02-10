defmodule App do
  import Ecto.Query
  alias App.Entry
  alias App.Account
  alias App.Repo

  def perform_transaction(account_id, amount, description) do
    tx_id = Ecto.UUID.bingenerate()

    try do
      result =
        from(
          r in fragment(
            "SELECT new_balance, available_limit FROM perform_transaction(?, ?, ?, ?)",
            ^tx_id,
            ^account_id,
            ^amount,
            ^description
          )
        )
        |> select([:new_balance, :available_limit])
        |> Repo.one()

      {:ok, result}
    rescue
      e in Postgrex.Error ->
        case e.postgres do
          %{pg_code: "TRX01"} ->
            {:error, :not_found, %{message: "Account not found"}}

          %{pg_code: "TRX02"} ->
            {:error, :unprocessable_entity, %{message: "Insufficient balance"}}
        end
    end
  end

  def get_statement(account_id) do
    from(a in Account,
      left_join: e in Entry,
      on: e.account_id == a.id,
      where: a.id == ^account_id,
      limit: 10,
      order_by: [desc: e.inserted_at],
      preload: [entries: e]
    )
    |> Repo.one()
  end
end
