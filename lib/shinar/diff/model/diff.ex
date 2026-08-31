defmodule Shinar.Diff.Model.Diff do
  @moduledoc """
  The result of diffing an original text against its corrected version.

  `original` and `corrected` hold the full token sequences that produced the
  diff; `segments` is the compressed run of `Shinar.Diff.Model.Segment` structs
  used for rendering.
  """

  alias Shinar.Diff.Model.Segment

  @typedoc "A diff of an original and corrected token sequence."
  @type t :: %__MODULE__{
          original: [Segment.token()],
          corrected: [Segment.token()],
          segments: [Segment.t()]
        }

  @enforce_keys [:original, :corrected, :segments]
  defstruct original: nil, corrected: nil, segments: nil
end