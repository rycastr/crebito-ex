defmodule App do
  import Ecto.Query

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
    case lookup_account(account_id) do
      nil ->
        {:error, :not_found, %{message: "Account not found"}}

      account ->
        latest_entries = lookup_latest_entries(account_id)
        {:ok, {account, latest_entries}}
    end
  end

  defp lookup_account(account_id) do
    from(a in "accounts",
      where: a.id == ^account_id,
      select: [:balance, :available_limit]
    )
    |> Repo.one()
  end

  defp lookup_latest_entries(account_id) do
    from(e in "entries",
      where: e.account_id == ^account_id,
      limit: 10,
      order_by: [desc: e.inserted_at],
      select: [:amount, :description, :inserted_at]
    )
    |> Repo.all()
  end

  def get_statement_v2(account_id) do
    statement =
      from(
        s in fragment(
          "SELECT balance, available_limit, latest_entries FROM lookup_statement(?)",
          ^account_id
        ),
        select: [:balance, :available_limit, :latest_entries]
      )
      |> Repo.one()

    case statement do
      nil -> {:error, :not_found, %{message: "Account not found"}}
      statement -> {:ok, statement}
    end
  end
end
