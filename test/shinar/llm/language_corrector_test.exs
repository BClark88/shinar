defmodule Shinar.LLM.LanguageCorrectorTest do
  use ExUnit.Case, async: true

  alias Shinar.LLM.LanguageCorrector
  alias Shinar.LLM.LanguageCorrector.Result

  test "returns the correction wrapped in a Result struct" do
    content = ~s({"corrected_text": "¿Qué tal mi chabón?"})

    Req.Test.stub(Shinar.LLM.Client, fn conn ->
      Req.Test.json(conn, %{
        "choices" => [%{"message" => %{"content" => content}}]
      })
    end)

    assert {:ok,
            %Result{
              original_text: "Hola mi chaboncito",
              original_translation: "What's up broski?",
              corrected_text: "¿Qué tal mi chabón?"
            }} = LanguageCorrector.call("Hola mi chaboncito", "What's up broski?")
  end

  test "forwards the LLM error" do
    Req.Test.stub(Shinar.LLM.Client, fn conn ->
      conn
      |> Plug.Conn.put_status(500)
      |> Req.Test.json(%{"error" => %{"message" => "boom"}})
    end)

    assert {:error, {:http_error, 500, %{"error" => %{"message" => "boom"}}}} =
             LanguageCorrector.call("Hola mi chaboncito")
  end
end
