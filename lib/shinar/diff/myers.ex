defmodule Shinar.Diff.Myers do
  @moduledoc """
  Takes a list of tokens and generates a diff according to the Myers algorithm
  """

  @typedoc "A single edit-script move."
  @type op :: {:keep, term()} | {:delete, term()} | {:insert, term()}

  @doc """
  Returns the minimal edit script that transforms `original` into `corrected`.

  Keeps carry the element shared by both sequences; deletes carry the element
  removed from `original`; inserts carry the element added from `corrected`.
  """
  @spec call(list(term()), list(term()), (term(), term() -> boolean())) :: [op()]
  def call(list_a, list_b, equal? \\ &==/2)

  def call([], [], _equal?), do: []

  def call(list_a, list_b, equal?) do
    a_length = length(list_a)
    b_length = length(list_b)

    # Imagine a 2d list, what we want to do is traverse it "diagonally" until we find a difference
    {x_coord, y_coord, edit_operations} =
      extend_snake(0, 0, [], list_a, list_b, a_length, b_length, equal?)

    # Very rare that we use if expressions in Elixir, but it is what we want here
    if x_coord == a_length and y_coord == b_length do
      Enum.reverse(edit_operations)
    else
      search(list_a, list_b, a_length, b_length, equal?, 1, %{
        0 => %{x: x_coord, y: y_coord, ops: edit_operations}
      })
    end
  end

  # In the Myers diff algorithm, a snake is a diagonal run of items where each item matches the other
  # Extending the snake just means we add items to the list that we want to keep as they match
  # Edit operations can be either keep, delete or insert

  defp extend_snake(x, y, ops, _orig, _corr, n, m, _equal?) when x >= n or y >= m do
    {x, y, ops}
  end

  defp extend_snake(
         x_coord,
         y_coord,
         edit_operations,
         list_a,
         list_b,
         list_a_length,
         list_b_length,
         equal?
       ) do
    case equal?.(Enum.at(list_a, x_coord), Enum.at(list_b, y_coord)) do
      true ->
        # call the snake again, but with the item added to the list
        extend_snake(
          x_coord + 1,
          y_coord + 1,
          # cons operator prepends the first item to the list
          [{:keep, Enum.at(list_a, x_coord)} | edit_operations],
          list_a,
          list_b,
          list_a_length,
          list_b_length,
          equal?
        )

      false ->
        {x_coord, y_coord, edit_operations}
    end
  end

  defp search(list_a, list_b, a_length, b_length, equal?, edit_budget, best_path) do
    # Sweep the diagonals for this round of the edit budget.
    # Diagonals in a round share one parity, stepping by 2 from -edit_budget to edit_budget.
    # Each diagonal's furthest point is stored in the round's map, which becomes
    # the input for the next round.
    {round_path, result} =
      Enum.reduce_while(-edit_budget..edit_budget//2, {best_path, :not_found}, fn k, acc ->
        {round_path, _} = acc

        {x_coord, y_coord, edit_operations} =
          step(k, list_a, list_b, a_length, b_length, equal?, edit_budget, round_path)

        round_path =
          Map.put(round_path, k, %{x: x_coord, y: y_coord, ops: edit_operations})

        if x_coord == a_length and y_coord == b_length do
          {:halt, {round_path, Enum.reverse(edit_operations)}}
        else
          {:cont, {round_path, :not_found}}
        end
      end)

    case result do
      :not_found ->
        # No diagonal touched the far corner at this budget; try the next round.
        search(list_a, list_b, a_length, b_length, equal?, edit_budget + 1, round_path)

      edit_operations ->
        edit_operations
    end
  end

  # Advances one diagonal k for the current edit budget: picks the predecessor
  # that got furthest, commits a single insert or delete move, then extends the
  # snake of matching elements. Keeps are built in reverse, so the caller
  # reverses them once the far corner is reached.
  defp step(k, list_a, list_b, a_length, b_length, equal?, edit_budget, best_path) do
    predecessor_k =
      if k == -edit_budget or
           (k != edit_budget and best_path[k - 1].x < best_path[k + 1].x) do
        k + 1
      else
        k - 1
      end

    %{x: pred_x, y: pred_y, ops: predecessor_ops} = best_path[predecessor_k]

    if predecessor_k == k + 1 do
      # Insertion: consume one corrected element (down move).
      {x_coord, y_coord, edit_operations} =
        {pred_x, pred_y + 1, [{:insert, Enum.at(list_b, pred_y)} | predecessor_ops]}

      extend_snake(x_coord, y_coord, edit_operations, list_a, list_b, a_length, b_length, equal?)
    else
      # Deletion: consume one original element (right move).
      {x_coord, y_coord, edit_operations} =
        {pred_x + 1, pred_y, [{:delete, Enum.at(list_a, pred_x)} | predecessor_ops]}

      extend_snake(x_coord, y_coord, edit_operations, list_a, list_b, a_length, b_length, equal?)
    end
  end
end
