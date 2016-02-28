defmodule LexibombServer.Play do
  @moduledoc """
  """

  defstruct [:start, :direction, :letters, :rack_leave]

  alias LexibombServer.Board
  alias LexibombServer.Board.Grid
  alias LexibombServer.Board.Square
  alias LexibombServer.Rack

  @type cardinal_direction :: :n | :e | :s | :w
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

  @spec next_coord(Grid.coord, cardinal_direction | direction) :: Grid.coord
  defp next_coord(coord, direction)
  defp next_coord(coord, :across), do: next_coord(coord, :e)
  defp next_coord(coord, :down), do: next_coord(coord, :s)
  defp next_coord({row, col}, :n), do: {row - 1, col}
  defp next_coord({row, col}, :e), do: {row, col + 1}
  defp next_coord({row, col}, :s), do: {row + 1, col}
  defp next_coord({row, col}, :w), do: {row, col - 1}

  @doc """
  Returns the word that intersects `coord` in the perpendicular direction to
  the given `direction`.

  Uses '.' for the one square that is missing a letter.
  """
  @spec crossword(Grid.t, Grid.coord, direction) :: String.t
  def crossword(grid, coord, direction) do
    dir = perpendicular(direction)
    {first_r, first_c} = scan_letters(grid, coord, opposite(dir))
    {last_r, last_c} = scan_letters(grid, coord, dir)

    coords =
      for row <- first_r..last_r,
          col <- first_c..last_c,
          do: {row, col}

    coords_to_letters(grid, coords)
  end

  # Returns the word made up of the tiles on the given coordinates.
  #
  # Uses '.' for any missing letters.
  @spec coords_to_letters(Grid.t, [Grid.coord]) :: String.t
  defp coords_to_letters(grid, coords) do
    coords
    |> Enum.map(&coord_to_letter(grid, &1))
    |> Enum.join
  end

  # Returns the letter of the tile on the given coordinate.
  #
  # Uses '.' for a missing letter.
  @spec coord_to_letter(Grid.t, Grid.coord) :: String.t
  defp coord_to_letter(grid, coord) do
    square = Map.get(grid, coord)

    case square.tile do
      "" -> "."
      _ -> square.tile
    end
  end

  # Returns the cardinal direction that is perpendicular to the given
  # `direction`.
  @spec perpendicular(direction) :: :e | :s
  defp perpendicular(direction) do
    case direction do
      :across -> :s
      :down -> :e
    end
  end

  @doc """
  Returns the cardinal direction that is opposite to the given `direction`.
  """
  @spec opposite(cardinal_direction) :: cardinal_direction
  def opposite(direction) do
    case direction do
      :n -> :s
      :e -> :w
      :s -> :n
      :w -> :e
    end
  end

  # Returns the coordinate of the last square starting from `coord` and going
  # in `direction` that is a letter.
  @spec scan_letters(Grid.t, Grid.coord, cardinal_direction | direction) :: Grid.coord
  def scan_letters(grid, coord, direction) do
    next_coord = next_coord(coord, direction)
    next_square = Map.get(grid, next_coord)

    if Square.played?(next_square) do
      scan_letters(grid, next_coord, direction)
    else
      coord
    end
  end

  # Returns the coordinate of the last square starting from `coord` and going
  # in `direction` that is not an anchor (nor off the board).
  @spec scan_to_anchor(Grid.t, Grid.coord, cardinal_direction | direction) :: Grid.coord
  def scan_to_anchor(grid, coord, direction) do
    next_coord = next_coord(coord, direction)

    cond do
      Grid.anchor_square?(grid, next_coord) ->
        coord
      not Grid.valid_coord?(grid, next_coord) ->
        coord
      true ->
        scan_to_anchor(grid, next_coord, direction)
    end
  end
end
