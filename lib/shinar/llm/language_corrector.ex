defmodule LLM.LanguageCorrector do
  @moduledoc """
  Corrects learner-written text via an LLM.

  `original_text` is the text the learner wrote, `original_translation` (optional) is the
  meaning the learner was trying to convey, used as context for the correction.
  """

  @doc """
  Returns `{:ok, %LLM.LanguageCorrector.Result{}}` with the original text and
  the corrected text, or `{:error, reason}` when the call fails.
  """
  def call(original_text, original_translation \\ "") do
    prompt = build_prompt(original_text, original_translation)

    case LLM.Client.call(prompt) do
      {:ok, response} -> {:ok, build_result(original_text, response)}
      {:error, reason} -> {:error, reason}
    end
  end

  defp build_prompt(original_text, original_translation) do
    # In Elixir `if` is an expression, not a a control flow, so we can't gate string building
    # behing if statements (e.g. prompt += original_translation if original_translation.present
    # So we have to do things a bit differently
    [
      "You are a language tutor. The following text was written by a learner of the language it is written in.",
      "Original text:\n\"\"\"\n#{original_text}\n\"\"\"",
      translation_context(original_translation),
      "Correct the text in place, keeping the learner's voice where the grammar allows. Return the corrected text in full."
    ]
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("\n\n")
  end

  defp translation_context(original_translation) do
    case String.trim(original_translation) do
      "" ->
        ""

      translation ->
        "For context, the learner wanted to say this in their native language: \"#{translation}\"."
    end
  end

  defp build_result(original_text, response) do
    %LLM.LanguageCorrector.Result{
      original_text: original_text,
      original_translation: nil,
      corrected_text: Map.get(response, "corrected_text")
    }
  end
end
