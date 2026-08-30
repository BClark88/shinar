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

  test "submitting text accepts it and shows an info flash", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("#correction-form")
    |> render_submit(%{"original_text" => "Hola que tal", "english_hint" => "Hello how are you"})

    assert has_element?(view, "#flash-info", "Received. Corrections are coming in a later step.")
  end
end
