defmodule Shinar.Diff.TokenizerTest do
  use ExUnit.Case, async: true

  alias Shinar.Diff.Tokenizer

  @fixtures [
    "Hello",
    "Qué",
    "café2024",
    "two  spaces",
    "a  \n b",
    "   ",
    "Hello world!",
    "what?!",
    "one—two",
    "...",
    "don't",
    "¿Qué tal?"
  ]

  describe "empty input" do
    test "returns no tokens" do
      assert Tokenizer.call("") == []
    end

    test "rejoining no tokens reproduces the empty string" do
      assert Tokenizer.call("") |> Enum.map_join(& &1.text) == ""
    end
  end

  describe "words" do
    test "a single word is one token" do
      assert Tokenizer.call("Hello") == [%Tokenizer.Token{type: :word, text: "Hello"}]
    end

    test "accents stay inside the word" do
      assert Tokenizer.call("Qué") == [%Tokenizer.Token{type: :word, text: "Qué"}]
    end

    test "letters and digits share one word run" do
      assert Tokenizer.call("café2024") == [%Tokenizer.Token{type: :word, text: "café2024"}]
    end
  end

  describe "whitespace" do
    test "a space run is preserved verbatim as a single token" do
      assert Tokenizer.call("two  spaces") == [
               %Tokenizer.Token{type: :word, text: "two"},
               %Tokenizer.Token{type: :ws, text: "  "},
               %Tokenizer.Token{type: :word, text: "spaces"}
             ]
    end

    test "mixed whitespace runs are preserved verbatim" do
      assert Tokenizer.call("a  \n b") == [
               %Tokenizer.Token{type: :word, text: "a"},
               %Tokenizer.Token{type: :ws, text: "  \n "},
               %Tokenizer.Token{type: :word, text: "b"}
             ]
    end

    test "a whitespace-only input yields a single ws token" do
      assert Tokenizer.call("   ") == [%Tokenizer.Token{type: :ws, text: "   "}]
    end
  end

  describe "punctuation" do
    test "each punctuation character gets its own token" do
      assert Tokenizer.call("Hello world!") == [
               %Tokenizer.Token{type: :word, text: "Hello"},
               %Tokenizer.Token{type: :ws, text: " "},
               %Tokenizer.Token{type: :word, text: "world"},
               %Tokenizer.Token{type: :punct, text: "!"}
             ]
    end

    test "a punctuation run is a single token" do
      assert Tokenizer.call("what?!") == [
               %Tokenizer.Token{type: :word, text: "what"},
               %Tokenizer.Token{type: :punct, text: "?!"}
             ]
    end

    test "an em-dash is a single punct token between words" do
      assert Tokenizer.call("one—two") == [
               %Tokenizer.Token{type: :word, text: "one"},
               %Tokenizer.Token{type: :punct, text: "—"},
               %Tokenizer.Token{type: :word, text: "two"}
             ]
    end

    test "a repeated-character punctuation run is a single token" do
      assert Tokenizer.call("...") == [
               %Tokenizer.Token{type: :punct, text: "..."}
             ]
    end
  end

  describe "contractions" do
    test "an apostrophe is a punct token between words" do
      assert Tokenizer.call("don't") == [
               %Tokenizer.Token{type: :word, text: "don"},
               %Tokenizer.Token{type: :punct, text: "'"},
               %Tokenizer.Token{type: :word, text: "t"}
             ]
    end
  end

  describe "Spanish" do
    test "inverted opening marks are punct tokens" do
      assert Tokenizer.call("¿Qué tal?") == [
               %Tokenizer.Token{type: :punct, text: "¿"},
               %Tokenizer.Token{type: :word, text: "Qué"},
               %Tokenizer.Token{type: :ws, text: " "},
               %Tokenizer.Token{type: :word, text: "tal"},
               %Tokenizer.Token{type: :punct, text: "?"}
             ]
    end
  end

  describe "reconstruction invariant" do
    test "joining the token text reproduces every fixture" do
      for input <- @fixtures do
        assert input |> Tokenizer.call() |> Enum.map_join(& &1.text) == input
      end
    end

    test "tokenizing the rejoin produces the same tokens" do
      for input <- @fixtures do
        tokens = Tokenizer.call(input)
        rejoined = Enum.map_join(tokens, & &1.text)
        assert Tokenizer.call(rejoined) == tokens
      end
    end
  end
end
