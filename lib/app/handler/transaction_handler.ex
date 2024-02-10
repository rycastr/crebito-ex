defmodule App.TransactionHandler do
  @input_transaction_schema %{
    account_id: [required: true, type: :integer],
    valor: [required: true, type: :integer],
    descricao: [required: true, type: :string, length: [min: 1, max: 10]],
    tipo: [required: true, type: :string, in: ["c", "d"]]
  }
  def create_transaction(params) do
    case Tarams.cast(params, @input_transaction_schema) do
      {:ok, params} ->
        App.perform_transaction(
          params.account_id,
          parse_amount(params.tipo, params.valor),
          params.descricao
        )
        |> handle_result()

      {:error, reason} ->
        {:error, :unprocessable_entity, reason}
    end
  end

  defp handle_result({:ok, data}) do
    {:ok,
     %{
       "limite" => data.available_limit,
       "saldo" => data.new_balance
     }}
  end

  defp handle_result(result), do: result

  defp parse_amount("c", amount), do: amount
  defp parse_amount("d", amount), do: -amount
end
