defmodule LLM.LanguageCorrector.Result do
  @moduledoc """
  The outcome of a correction request.

  Built only by `LLM.LanguageCorrector`; treat as opaque data elsewhere.
  """

  @enforce_keys [:original_text, :original_translation, :corrected_text]
  defstruct [:original_text, :original_translation, :corrected_text]

  @type t() :: %__MODULE__{
          original_text: String.t(),
          original_translation: String.t() | nil,
          corrected_text: String.t() | nil
        }
end
