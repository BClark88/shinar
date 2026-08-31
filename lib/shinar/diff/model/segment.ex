defmodule Shinar.Diff.Model.Segment do
  @moduledoc """
  A contiguous run of `Shinar.Diff.Tokenizer.Token` atoms of one diff kind.

  Segments are compressed from a Myers edit trace: `:equal` runs are tokens kept
  by both sides, `:delete` runs were removed from the original, and `:insert`
  runs were added in the corrected text.
  """

  alias Shinar.Diff.Tokenizer.Token

  @typedoc "What happened to this run of tokens."
  @type type :: :equal | :delete | :insert

  @typedoc "A single token atom."
  @type token :: Token.t()

  @typedoc "A contiguous run of tokens of one diff kind."
  @type t :: %__MODULE__{type: type(), tokens: [token()]}

  @enforce_keys [:type, :tokens]
  defstruct type: nil, tokens: nil
end