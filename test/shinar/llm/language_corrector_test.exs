defmodule LLM.LanguageCorrectorTest do
  use ExUnit.Case, async: true

  alias LLM.LanguageCorrector
  alias LLM.LanguageCorrector.Result

  test "returns the correction wrapped in a Result struct" do
    content = ~s({"corrected_text": "¿Qué tal mi chabóncito?"})

    Req.Test.stub(LLM.Client, fn conn ->
      Req.Test.json(conn, %{
        "choices" => [%{"message" => %{"content" => content}}]
      })
    end)

    assert {:ok,
            %Result{
              original_text: "Hola mi chaboncito",
              original_translation: nil,
              corrected_text: "¿Qué tal mi chabóncito?"
            }} = LanguageCorrector.call("Hola mi chaboncito", "Hello my little friend")
  end

  test "forwards the LLM error" do
    Req.Test.stub(LLM.Client, fn conn ->
      conn
      |> Plug.Conn.put_status(500)
      |> Req.Test.json(%{"error" => %{"message" => "boom"}})
    end)

    assert {:error, {:http_error, 500, %{"error" => %{"message" => "boom"}}}} =
             LanguageCorrector.call("Hola mi chaboncito")
  end
end
