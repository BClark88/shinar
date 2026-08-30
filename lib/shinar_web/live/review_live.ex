defmodule ShinarWeb.ReviewLive do
  use ShinarWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    form = to_form(%{"original_text" => "", "english_hint" => ""})
    {:ok, assign(socket, form: form, corrected_text: nil)}
  end

  @impl true
  def handle_event(
        "submit",
        %{"original_text" => original_text, "english_hint" => english_hint},
        socket
      ) do
    if String.trim(original_text) == "" do
      {:noreply,
       put_flash(socket, :error, "Please write something in the language you're learning.")}
    else
      case LLM.LanguageCorrector.call(original_text, english_hint) do
        {:ok, %LLM.LanguageCorrector.Result{corrected_text: corrected}} ->
          {:noreply, assign(socket, corrected_text: corrected)}

        {:error, reason} ->
          {:noreply, put_flash(socket, :error, "Couldn't get a correction: #{inspect(reason)}")}
      end
    end
  end
end
