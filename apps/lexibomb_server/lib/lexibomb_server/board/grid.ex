defmodule LexibombServer.Board.Grid do
  @moduledoc """
  """

  alias LexibombServer.Board.Grid
  alias LexibombServer.Board.Square
  alias LexibombServer.Utils

  @type row :: non_neg_integer
  @type col :: non_neg_integer
  @type coord :: {row, col}
  @type t :: %{coord => Square.t}

  @spec initialize(pos_integer) :: Grid.t
  def initialize(size) do
    border = 2

    empty_grid(size + border)
    |> deactivate_border
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

  @spec set_bomb(Grid.t, coord) :: Grid.t
  def set_bomb(grid, coord) do
    Map.update!(grid, coord, &Square.set_bomb/1)
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
