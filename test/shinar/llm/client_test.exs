defmodule LLM.ClientTest do
  use ExUnit.Case, async: true

  alias LLM.Client

  test "200 response returns the decoded response map" do
    content = ~s({"corrected_text": "¿Qué tal mi chabóncito?"})

    Req.Test.stub(LLM.Client, fn conn ->
      Req.Test.json(conn, %{
        "choices" => [
          %{
            "finish_reason" => "stop",
            "index" => 0,
            "message" => %{"role" => "assistant", "content" => content}
          }
        ],
        "created" => 1_788_081_726,
        "id" => "chatcmpl-584",
        "model" => "codestral:22b",
        "object" => "chat.completion",
        "system_fingerprint" => "fp_ollama",
        "usage" => %{"completion_tokens" => 81, "prompt_tokens" => 87, "total_tokens" => 168}
      })
    end)

    assert {:ok, decoded} = Client.call("Hola mi chaboncito")

    assert decoded == %{"corrected_text" => "¿Qué tal mi chabóncito?"}
  end

  test "non-200 response returns {:error, {:http_error, status, body}}" do
    Req.Test.stub(LLM.Client, fn conn ->
      conn
      |> Plug.Conn.put_status(404)
      |> Req.Test.json(%{"error" => %{"message" => "model not found"}})
    end)

    assert {:error, {:http_error, 404, %{"error" => %{"message" => "model not found"}}}} =
             Client.call("Hola mi chaboncito")
  end

  test "transport error returns {:error, %Req.TransportError{}}" do
    Req.Test.stub(LLM.Client, fn conn -> Req.Test.transport_error(conn, :timeout) end)

    assert {:error, %Req.TransportError{reason: :timeout}} = Client.call("Hola mi chaboncito")
  end
end
