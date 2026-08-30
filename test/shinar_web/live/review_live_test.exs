defmodule ShinarWeb.ReviewLiveTest do
  use ShinarWeb.LiveViewCase

  test "landing page renders the correction form", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#correction-form")
    assert has_element?(view, "#correction-form button")
  end

  test "submitting blank text shows an error flash", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("#correction-form")
    |> render_submit(%{"original_text" => "", "english_hint" => ""})

    assert has_element?(
             view,
             "#flash-error",
             "Please write something in the language you're learning."
           )
  end

  test "submitting text returns the corrected text", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    Req.Test.stub(Shinar.LLM.Client, fn conn ->
      Req.Test.json(conn, %{
        "choices" => [
          %{
            "message" => %{
              "content" => ~s({"corrected_text": "Hola, ¿qué tal?"})
            }
          }
        ]
      })
    end)

    Req.Test.allow(Shinar.LLM.Client, self(), view.pid)

    view
    |> element("#correction-form")
    |> render_submit(%{"original_text" => "Hola que tal", "english_hint" => "Hello how are you"})

    assert has_element?(view, "#correction-result", "Hola, ¿qué tal?")
  end
end
