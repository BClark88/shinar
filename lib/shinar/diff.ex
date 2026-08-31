defmodule Shinar.Diff do
  alias Shinar.Diff.Tokenizer
  alias Shinar.Diff.Myers

  @moduledoc """
  Tokenizes two input strings and then builds a myers style diff
  """

  def call(text_a, text_b) do
    # tokenize the text
    tokenized_text_a = Tokenizer.call(text_a)
    tokenized_text_b = Tokenizer.call(text_b)

    # get the diff
    diff = Myers.call(tokenized_text_a, tokenized_text_b)
  end
end
