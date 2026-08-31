defmodule Shinar.Diff.Model.Edit do
  @moduledoc """
  A single correction anchored to the token spans it affects.

  Reserved for future use: Phase 1b will anchor per-correction comments onto
  computed edits. `original` holds the removed tokens and `corrected` the added
  tokens for an `:insert` or `:delete`.
  """

  alias Shinar.Diff.Model.Segment

  @typedoc "What happened: `:delete` or `:insert`."
  @type type :: :delete | :insert

  @typedoc "A single anchored edit with its before/after tokens."
  @type t :: %__MODULE__{
          type: type(),
          original: [Segment.token()],
          corrected: [Segment.token()]
        }

  @enforce_keys [:type, :original, :corrected]
  defstruct type: nil, original: nil, corrected: nil
end