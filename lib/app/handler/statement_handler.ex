defmodule App.StatementHandler do
  @input_transaction_schema %{
    account_id: [required: true, type: :integer]
  }
  def get_statement(params) do
    case Tarams.cast(params, @input_transaction_schema) do
      {:ok, params} ->
        App.get_statement(params.account_id)
        |> handle_result()

      {:error, reason} ->
        {:error, :unprocessable_entity, reason}
    end
  end

  defp handle_result(nil), do: {:error, :not_found, "Account not found"}

  defp handle_result(account) do
    response = %{
      saldo: %{
        total: account.balance,
        data_extrato: DateTime.utc_now() |> DateTime.to_iso8601(),
        limite: account.available_limit
      },
      ultimas_transacoes:
        Enum.map(account.entries, fn e ->
          %{
            valor: abs(e.amount),
            tipo:
              if e.amount < 0 do
                "d"
              else
                "c"
              end,
            descricao: e.description,
            realizada_em: e.inserted_at
          }
        end)
    }

    {:ok, response}
  end
end
