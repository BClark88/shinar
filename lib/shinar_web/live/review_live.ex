defmodule ShinarWeb.ReviewLive do
  use ShinarWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    form = to_form(%{"original_text" => "", "english_hint" => ""})
    {:ok, assign(socket, form: form)}
  end

  @impl true
  def handle_event("submit", %{"original_text" => original_text}, socket) do
    if String.trim(original_text) == "" do
      {:noreply,
       put_flash(socket, :error, "Please write something in the language you're learning.")}
    else
      {:noreply, put_flash(socket, :info, "Received. Corrections are coming in a later step.")}
    end
  end
end
