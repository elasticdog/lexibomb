defmodule LexibombServer.Board.Grid do
  @moduledoc """
  Acts as the glue between the high-level board interface and the low-level
  square states.

  The grid module is responsible for establishing and manipulating the
  underlying data structure of a board's coordinate system. The squares within
  a grid are referred to using 0-based indexes for both the rows and columns.
  These squares are stored within a `MapSet` using a `{row, col}` tuple as the
  key.

  An extra border of inactive squares is added to the a board's size in order
  to simplify functions that would otherwise have to perform complicated
  boundary checks. This border means that a 15 x 15 sized board, will utilize
  a 17 x 17 grid underneath.
  """

  alias LexibombServer.Board.Square
  alias LexibombServer.Utils

  @type row :: non_neg_integer
  @type col :: non_neg_integer
  @type coord :: {row, col}
  @type t :: %{coord => Square.t}

  @border 2

  @doc """
  Initializes a new grid of squares with a deactivated border.
  """
  @spec init(pos_integer) :: t
  def init(size) do
    empty_grid(size + @border) |> deactivate_border
  end

  @doc """
  Returns the size of the game board.

  This does *not* include the additional rows/cols of the deactivated border.
  """
  @spec board_size(t) :: pos_integer
  def board_size(grid) do
    size(grid) - @border
  end

  @doc """
  Returns the size of the grid.

  This *does* include the additional rows/cols of the deactivated border.
  """
  @spec size(t) :: pos_integer
  def size(grid) do
    grid
    |> map_size
    |> :math.sqrt
    |> round
  end

  @doc """
  Places a bomb on the grid square at the given coordinate.
  """
  @spec place_bomb(t, coord) :: t
  def place_bomb(grid, coord) do
    square = Map.get(grid, coord)

    if square.bomb? do
      grid
    else
      grid
      |> Map.update!(coord, &Square.place_bomb/1)
      |> inc_adjacent_bombs(adjacent_coords(coord))
    end
  end

  @doc """
  Places a bomb on each of the grid squares at the given coordinates.
  """
  @spec place_bombs(t, [coord]) :: t
  def place_bombs(grid, coords) do
    Enum.reduce(coords, grid, fn(coord, grid) ->
      place_bomb(grid, coord)
    end)
  end

  @doc """
  Places a tile on the grid square at the given coordinate.

  This triggers a cascading reveal.
  """
  @spec place_tile(t, coord, String.t) :: t
  def place_tile(grid, coord, tile) do
    Map.update!(grid, coord, fn square ->
      Square.place_tile(square, tile)
    end)
    |> cascading_reveal(coord)
  end

  @doc """
  Reveal the square at the given coordinate; if no bombs are adjacent,
  recursively reveal all adjacent squares.
  """
  @spec cascading_reveal(t, coord) :: t
  def cascading_reveal(grid, coord) do
    square = Map.get(grid, coord)

    if Square.no_adjacent_bombs?(square) do
      adjacent_coords(coord) |> Enum.reduce(grid, &do_cascading_reveal/2)
    else
      reveal(grid, coord)
    end
  end

  defp do_cascading_reveal(coord, grid) do
    square = Map.get(grid, coord)

    if Square.revealed?(square) do
      # stopping criterion
      grid
    else
      reveal(grid, coord) |> cascading_reveal(coord)
    end
  end

  @doc """
  Reveals the grid square at the given coordinate.
  """
  @spec reveal(t, coord) :: t
  def reveal(grid, coord) do
    Map.update!(grid, coord, fn square ->
      Square.reveal(square)
    end)
  end

  @doc """
  Returns a map containing just the active squares on the given `grid`.
  """
  @spec active_squares(t) :: t
  def active_squares(grid) do
    grid
    |> Stream.filter(fn {_, square} -> Square.active?(square) end)
    |> Map.new
  end

  @doc """
  Returns `true` if the given coordinate points to an anchor square.
  """
  @spec anchor_square?(t, coord) :: boolean
  def anchor_square?(grid, coord) do
    cond do
      Map.get(grid, coord) |> Square.played? ->
        false
      any_cardinals_played?(grid, coord) ->
        true
      true ->
        false
    end
  end

  @doc"""
  Returns `true` if any of the squares located in the cardinal directions from
  the given coordinate have a tile played on them.
  """
  @spec any_cardinals_played?(t, coord) :: boolean
  def any_cardinals_played?(grid, coord) do
    coord
    |> cardinal_coords
    |> Enum.any?(fn coord ->
         Map.get(grid, coord) |> Square.played?
       end)
  end

  @doc"""
  Returns the four adjacent coordinates that are in the cardinal directions
  (N, E, S, W) from the given `coord`.
  """
  @spec cardinal_coords(coord) :: [coord]
  def cardinal_coords({row, col}) do
    [
      {row - 1, col},
      {row + 1, col},
      {row, col - 1},
      {row, col + 1},
    ]
  end

  @spec valid_coord?(t, coord) :: boolean
  def valid_coord?(grid, coord) do
    grid
    |> active_squares
    |> Map.has_key?(coord)
  end

  # Creates an empty grid of squares in the dimension given by `size`.
  @spec empty_grid(pos_integer) :: t
  defp empty_grid(size) do
    for row <- 0 .. (size - 1),
        col <- 0 .. (size - 1),
        into: %{},
        do: {{row, col}, %Square{}}
  end

  # Deactivates the grid square at the given coordinate.
  @spec deactivate(coord, t) :: t
  defp deactivate(coord, grid) do
    Map.update!(grid, coord, &Square.deactivate/1)
  end

  # Deactivates all of the squares in the first and last rows/cols of the grid.
  @spec deactivate_border(t) :: t
  defp deactivate_border(grid) do
    coords = Map.keys(grid)
    grid_size = size(grid)
    border_coords = Enum.filter(coords, &border_square?(&1, grid_size))

    Enum.reduce(border_coords, grid, &deactivate/2)
  end

  # Validates whether the given coordinate is along the border of a `grid_size`
  # sized grid.
  @spec border_square?(coord, pos_integer) :: boolean
  defp border_square?(coord, grid_size) do
    {row, col} = coord
    cond do
      row |> Utils.first_or_last?(grid_size) -> true
      col |> Utils.first_or_last?(grid_size) -> true
      true -> false
    end
  end

  # Increments the adjacent bombs count for each the squares adjacent to the
  # given coordinate.
  @spec inc_adjacent_bombs(t, [coord]) :: t
  defp inc_adjacent_bombs(grid, [head|tail]) do
    grid
    |> Map.update!(head, &Square.inc_adjacent_bombs/1)
    |> inc_adjacent_bombs(tail)
  end
  defp inc_adjacent_bombs(grid, []), do: grid

  # Returns the coordinates of the squares adjacent to the given coordinate.
  @spec adjacent_coords(coord) :: [coord]
  defp adjacent_coords({row, col}) do
    for r <- (row - 1)..(row + 1),
        c <- (col - 1)..(col + 1),
        {r, c} != {row, col},
        do: {r, c}
  end

  # Reveal all the squares on a `grid` for debugging.
  @doc false
  @spec __reveal__(t) :: t
  def __reveal__(grid) do
    Enum.into(grid, %{}, fn {coord, square} ->
       {coord, Square.reveal(square)}
    end)
  end
end
