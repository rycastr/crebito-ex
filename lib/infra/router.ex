defmodule Infra.Router do
  use Plug.Router

  alias Infra.StatementHandlerV2
  alias Infra.TransactionHandler

  plug(Plug.Parsers,
    parsers: [:urlencoded, :json],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  get "/clientes/:account_id/extrato" do
    StatementHandlerV2.get_statement(conn.params)
    |> do_response(conn)
  end

  post "/clientes/:account_id/transacoes" do
    TransactionHandler.create_transaction(conn.params)
    |> do_response(conn)
  end

  match _ do
    conn
    |> put_status(:not_found)
    |> json(%{message: "not found"})
  end

  defp do_response({:error, code, response}, conn), do: do_response({code, response}, conn)

  defp do_response({code, response}, conn) do
    conn
    |> put_status(code)
    |> json(response)
  end

  defp json(conn, data) do
    response = Jason.encode_to_iodata!(data)

    conn
    |> ensure_resp_content_type("application/json")
    |> send_resp(conn.status || :ok, response)
  end

  defp ensure_resp_content_type(%Plug.Conn{resp_headers: resp_headers} = conn, content_type) do
    if List.keyfind(resp_headers, "content-type", 0) do
      conn
    else
      content_type = content_type <> "; charset=utf-8"
      %Plug.Conn{conn | resp_headers: [{"content-type", content_type} | resp_headers]}
    end
  end
end
