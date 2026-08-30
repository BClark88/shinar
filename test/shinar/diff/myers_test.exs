defmodule Shinar.Diff.MyersTest do
  use ExUnit.Case, async: true

  alias Shinar.Diff.Myers

  @fixtures [
    {["a", "b", "c"], ["a", "b", "c"]},
    {[], ["a", "b"]},
    {["a", "b"], []},
    {["a", "b"], ["a", "x", "b"]},
    {["a", "x", "b"], ["a", "b"]},
    {["a", "b"], ["a", "c"]},
    {["a", "b", "c", "d"], ["a", "x", "c", "e"]},
    {["one", " two"], ["one", " two", " three"]},
    {["the", " quick", " brown", " fox"], ["a", " quick", " fox"]},
    {["Guten", " Morgen"], ["Buenos", " días"]},
    {["Hola", " que", " tal?"], ["Hola,", "¿qué", " tal?"]}
  ]

  describe "identical sequences" do
    test "collapses to all keeps in order" do
      assert Myers.call(["a"], ["a"]) == [{:keep, "a"}]
      assert Myers.call([1, 2, 3], [1, 2, 3]) == [{:keep, 1}, {:keep, 2}, {:keep, 3}]
    end
  end

  describe "empty sequences" do
    test "two empty sequences yield an empty script" do
      assert Myers.call([], []) == []
    end

    test "an empty original is pure insertion" do
      assert Myers.call([], ["a", "b"]) == [{:insert, "a"}, {:insert, "b"}]
    end

    test "an empty corrected is pure deletion" do
      assert Myers.call(["a", "b"], []) == [{:delete, "a"}, {:delete, "b"}]
    end
  end

  describe "single edits" do
    test "a pure insertion keeps the surrounding elements" do
      assert Myers.call(["a", "b"], ["a", "x", "b"]) == [
               {:keep, "a"},
               {:insert, "x"},
               {:keep, "b"}
             ]
    end

    test "a pure deletion keeps the surrounding elements" do
      assert Myers.call(["a", "x", "b"], ["a", "b"]) == [
               {:keep, "a"},
               {:delete, "x"},
               {:keep, "b"}
             ]
    end

    test "a replacement renders as a delete followed by an insert" do
      assert Myers.call(["a", "b"], ["a", "c"]) == [
               {:keep, "a"},
               {:delete, "b"},
               {:insert, "c"}
             ]
    end
  end

  describe "multi-edit fixtures" do
    test "an insertion and a deletion in the same script stay ordered" do
      assert Myers.call(["a", "b", "c", "d"], ["a", "x", "c", "e"]) == [
               {:keep, "a"},
               {:delete, "b"},
               {:insert, "x"},
               {:keep, "c"},
               {:delete, "d"},
               {:insert, "e"}
             ]
    end
  end

  describe "custom equality" do
    test "an equal? predicate drives which elements count as shared" do
      imply = fn x, y -> String.downcase(x) == String.downcase(y) end

      assert Myers.call(["Hello", "world"], ["hello", "world", "!"], imply) == [
               {:keep, "Hello"},
               {:keep, "world"},
               {:insert, "!"}
             ]
    end
  end

  describe "reconstruction invariant" do
    test "applying the script to a reproduces a and b in both directions" do
      for {a, b} <- @fixtures do
        assert apply_script(Myers.call(a, b)) == {a, b}
      end
    end
  end

  describe "minimality" do
    test "the edit count matches the LCS oracle on fixtures and random pairs" do
      pairs = @fixtures ++ random_pairs(500, max_len: 8, alphabet: ~w(a b c x y))

      for {a, b} <- pairs do
        ops = Myers.call(a, b)

        edit_count =
          Enum.count(ops, &match?({:delete, _}, &1)) + Enum.count(ops, &match?({:insert, _}, &1))

        assert edit_count == length(a) + length(b) - 2 * lcs_length(a, b)
      end
    end
  end

  defp apply_script(ops) do
    {out_a, out_b} =
      Enum.reduce(ops, {[], []}, fn
        {:keep, el}, {as, bs} -> {[el | as], [el | bs]}
        {:delete, el}, {as, bs} -> {[el | as], bs}
        {:insert, el}, {as, bs} -> {as, [el | bs]}
      end)

    {Enum.reverse(out_a), Enum.reverse(out_b)}
  end

  defp random_pairs(count, max_len: max_len, alphabet: alphabet) do
    for _ <- 1..count do
      a = for _ <- 1..:rand.uniform(max_len), do: Enum.random(alphabet)
      b = for _ <- 1..:rand.uniform(max_len), do: Enum.random(alphabet)
      {a, b}
    end
  end

  defp lcs_length([], _), do: 0
  defp lcs_length(_, []), do: 0

  defp lcs_length(a, b) do
    m = length(b)

    last_row =
      Enum.reduce(a, List.duplicate(0, m + 1), fn x, prev ->
        {row, _} =
          Enum.reduce(Enum.to_list(0..(m - 1)), {List.duplicate(0, m + 1), 0}, fn j,
                                                                                  {row, up_left} ->
            y = Enum.at(b, j)
            idx = j + 1
            val = if x == y, do: up_left + 1, else: max(Enum.at(row, j), Enum.at(prev, idx))
            {List.replace_at(row, idx, val), Enum.at(prev, idx)}
          end)

        row
      end)

    Enum.at(last_row, m)
  end
end
