defmodule Shinar.Diff.Tokenizer.Token do
  @moduledoc """
  A single piece of original text produced by `Shinar.Diff.Tokenizer`.

  The lexical class is one of `:word`, `:ws`, or `:punct`; `text` preserves the
  original characters verbatim, so the token stream round-trips the input exactly.
  """

  @typedoc "The lexical class of a token."
  @type type :: :word | :punct | :ws

  @typedoc "A single piece of the original text."
  @type t :: %__MODULE__{type: type(), text: String.t()}

  @enforce_keys [:type, :text]
  defstruct type: nil, text: nil
end
