defmodule Infra.StatementHandler do
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

  defp handle_result(result) do
    with {:ok, {account, latest_entries}} <- result do
      now = DateTime.utc_now() |> DateTime.to_iso8601()

      {:ok,
       %{
         "saldo" => %{
           "total" => account.balance,
           "data_extrato" => now,
           "limite" => account.available_limit
         },
         "ultimas_transacoes" => parse_entries(latest_entries)
       }}
    end
  end

  defp parse_entries(entries) do
    Enum.map(entries, fn entry ->
      {type, amount} = parse_amount(entry.amount)

      %{
        "valor" => amount,
        "tipo" => type,
        "descricao" => entry.description,
        "realizada_em" => entry.inserted_at
      }
    end)
  end

  defp parse_amount(amount) do
    if amount < 0 do
      {"d", abs(amount)}
    else
      {"c", amount}
    end
  end
end
