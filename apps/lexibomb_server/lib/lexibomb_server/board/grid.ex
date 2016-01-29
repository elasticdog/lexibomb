defmodule LexibombServer.Board.Grid do
  @moduledoc """
  """

  alias LexibombServer.Board.{Grid, Square}
  alias LexibombServer.Utils

  @type row :: non_neg_integer
  @type col :: non_neg_integer
  @type coord :: {row, col}
  @type t :: %{coord => Square.t}

  @border 2

  @spec initialize(pos_integer) :: Grid.t
  def initialize(size) do
    empty_grid(size + @border) |> deactivate_border
  end

  @spec empty_grid(pos_integer) :: Grid.t
  def empty_grid(size) do
    for row <- 0 .. (size - 1),
        col <- 0 .. (size - 1),
        into: %{},
        do: {{row, col}, %Square{}}
  end

  @spec deactivate_border(Grid.t) :: Grid.t
  def deactivate_border(grid) do
    coords = Map.keys(grid)
    grid_size = size(grid)
    border_coords = Enum.filter(coords, &border_square?(&1, grid_size))

    Enum.reduce(border_coords, grid, &deactivate/2)
  end

  @spec board_size(Grid.t) :: pos_integer
  def board_size(grid) do
    size(grid) - @border
  end

  @spec size(Grid.t) :: pos_integer
  def size(grid) do
    grid
    |> map_size
    |> :math.sqrt
    |> round
  end

  @spec border_square?(coord, pos_integer) :: boolean
  def border_square?(coord, grid_size) do
    {row, col} = coord
    cond do
      row |> Utils.first_or_last?(grid_size) -> true
      col |> Utils.first_or_last?(grid_size) -> true
      true -> false
    end
  end

  @spec deactivate(coord, Grid.t) :: Grid.t
  def deactivate(coord, grid) do
    Map.update!(grid, coord, &Square.deactivate/1)
  end

  @spec place_bomb(Grid.t, coord) :: Grid.t
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

  @spec inc_adjacent_bombs(Grid.t, [coord]) :: Grid.t
  def inc_adjacent_bombs(grid, [head|tail]) do
    grid
    |> Map.update!(head, &Square.inc_adjacent_bombs/1)
    |> inc_adjacent_bombs(tail)
  end
  def inc_adjacent_bombs(grid, []), do: grid

  @spec adjacent_coords(coord) :: [coord]
  def adjacent_coords({row, col}) do
    [{row-1, col-1},
     {row-1, col  },
     {row-1, col+1},
     {row,   col-1},
     {row,   col+1},
     {row+1, col-1},
     {row+1, col  },
     {row+1, col+1}]
  end

  # Reveal all the squares on a `grid` for debugging.
  @doc false
  @spec __reveal__(Grid.t) :: Grid.t
  def __reveal__(grid) do
    Enum.into(grid, %{}, fn {coord, square} ->
       {coord, Square.reveal(square)}
    end)
  end
end
