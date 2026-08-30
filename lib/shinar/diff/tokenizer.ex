defmodule Shinar.Diff.Tokenizer do
  @moduledoc """
  Splits text into a flat sequence of `Shinar.Diff.Tokenizer.Token` structs.

  Words run as letters and digits, whitespace runs are kept verbatim as a single
  token, and a run of any other characters becomes a single `:punct` token.

  Backbone invariant: joining all token text (`Enum.map_join(tokens, & &1.text)`)
  reproduces the original string exactly. The diff engine downstream relies on it.
  """

  alias __MODULE__.Token

  @doc """
  Returns the sequence of tokens for `text`. An empty string yields `[]`.
  """
  @spec call(String.t()) :: [Token.t()]
  def call(text) do
    text
    |> String.codepoints()
    |> Enum.chunk_while({nil, []}, &chunk_fun/2, &after_fun/1)
    |> Enum.map(&build_token/1)
  end

  @spec chunk_fun(String.t(), {Token.type() | nil, [String.t()]}) ::
          {:cont, {Token.type(), [String.t()]}}
          | {:cont, {Token.type(), [String.t()]}, {Token.type(), [String.t()]}}
  defp chunk_fun(char, {nil, []}) do
    {:cont, {classify(char), [char]}}
  end

  defp chunk_fun(char, {type, chars}) do
    case classify(char) do
      ^type ->
        {:cont, {type, [char | chars]}}

      new_type ->
        {:cont, {type, chars}, {new_type, [char]}}
    end
  end

  @spec after_fun({Token.type() | nil, [String.t()]}) ::
          {:cont, {Token.type() | nil, [String.t()]}}
          | {:cont, {Token.type(), [String.t()]}, {Token.type() | nil, [String.t()]}}
  defp after_fun({nil, []}) do
    {:cont, {nil, []}}
  end

  defp after_fun({type, chars}) do
    {:cont, {type, chars}, {nil, []}}
  end

  @spec classify(String.t()) :: Token.type()
  defp classify(char) do
    cond do
      String.match?(char, ~r/[\p{L}\p{N}]/u) -> :word
      String.trim(char) == "" -> :ws
      true -> :punct
    end
  end

  @spec build_token({Token.type(), [String.t()]}) :: Token.t()
  defp build_token({type, chars}) do
    %Token{type: type, text: chars |> Enum.reverse() |> Enum.join()}
  end
end
