defmodule LexibombServer.Play do
  @moduledoc """
  """

  defstruct [:start, :direction, :letters, :rack_leave]

  alias LexibombServer.Board
  alias LexibombServer.Board.Grid
  alias LexibombServer.Rack

  @type direction :: :across | :down
  @type t :: %{
    start: Board.coord,
    direction: direction,
    letters: [String.t],
    rack_leave: [String.t],
  }

  @doc """
  Returns the list of letters with each letter wrapped in a tuple alongside its
  coordinate.
  """
  @spec letters_with_coords(t) :: {:ok, [{String.t, Grid.coord}]} | {:error, :badarg}
  def letters_with_coords(play) do
    case Board.parse_coord(play.start) do
      {:ok, coord} ->
        {:ok, do_letters_with_coords([], coord, play.letters, play.direction)}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp do_letters_with_coords(acc, coord, [letter|letters], direction) do
    pair = {letter, coord}
    next_coord = next_coord(coord, direction)
    do_letters_with_coords([pair] ++ acc, next_coord, letters, direction)
  end

  defp do_letters_with_coords(acc, _, [], _), do: Enum.reverse(acc)

  @spec next_coord(Grid.coord, direction) :: Grid.coord
  defp next_coord(coord, direction)
  defp next_coord({row, col}, :across), do: {row, col + 1}
  defp next_coord({row, col}, :down), do: {row + 1, col}
end
