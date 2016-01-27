defmodule LexibombServer.Board do
  @moduledoc """
  """

  defstruct [:grid]

  alias LexibombServer.Board
  alias LexibombServer.Board.Square
  alias LexibombServer.Utils

  @default_size 15
  @bomb_count 22

  def new(size \\ @default_size) do
    board = %Board{grid: initialize_grid(size)}
    Agent.start_link(fn -> board end)
  end

  def initialize_grid(size) do
    border = 2

    empty_grid(size + border)
    |> deactivate_border
  end

  def empty_grid(size) do
    for row <- 0 .. (size - 1),
        col <- 0 .. (size - 1),
        into: %{},
        do: {{row, col}, %Square{}}
  end

  def deactivate_border(grid) do
    coords = Map.keys(grid)
    grid_size = size(grid)
    border_coords = Enum.filter(coords, &border_square?(&1, grid_size))

    Enum.reduce(border_coords, grid, &deactivate/2)
  end

  def size(grid) do
    grid
    |> map_size
    |> :math.sqrt
    |> round
  end

  def border_square?(coord, grid_size) do
    {row, col} = coord
    cond do
      row |> first_or_last?(grid_size) -> true
      col |> first_or_last?(grid_size) -> true
      true -> false
    end
  end

  def first_or_last?(index, size) do
    first = 0
    last = size - 1

    case index do
      ^first -> true
      ^last -> true
      _ -> false
    end
  end

  def deactivate(coord, grid) do
    grid |> Map.update!(coord, &Square.deactivate/1)
  end

  def get(pid) do
    Agent.get(pid, &(&1))
  end

  def debug(board) do
    grid_size = size(board.grid)
    border = 2

    header = draw_header(grid_size - border)
    top = Utils.draw_grid_line(grid_size, :top) |> Utils.to_padded_line(3)
    middle = draw_all_rows(board.grid)
    bottom = Utils.draw_grid_line(grid_size, :bottom) |> Utils.to_padded_line(3)

    header <> top <> middle <> bottom
  end

  def draw_header(size) do
    last_col = ?a + size - 1

    Enum.to_list(?a .. last_col)
    |> List.to_string
    |> String.graphemes
    |> Enum.join("   ")
    |> Utils.to_padded_line(9)
  end

  def draw_all_rows(grid) do
    grid_size = size(grid)
    grid_line =
      grid_size
      |> Utils.draw_grid_line(:middle)
      |> Utils.to_padded_line(3)

    grid
    |> Enum.sort_by(fn {coord, _} -> coord end)
    |> Stream.map(fn {_, square} -> inspect(square) end)
    |> Stream.chunk(grid_size)
    |> Stream.map(&Utils.draw_segments/1)
    |> label_lines(grid_size)
    |> Enum.join(grid_line)
  end

  def label_lines(rows, grid_size) do
    rows
    |> Stream.with_index
    |> Stream.map(fn {row, index} ->
         label? = !first_or_last?(index, grid_size)
         label = if label?, do: zero_pad(index, 2), else: "  "

         label <> Utils.to_padded_line(row, 1)
       end)
  end

  def zero_pad(n, len) when is_integer(n) do
    n |> to_string |> String.rjust(len, ?0)
  end

  def get_row_squares(grid, row) do
    grid
    |> Stream.filter(fn {coord, _} -> match?({^row, _} , coord) end)
    |> Enum.sort_by(fn {coord, _} -> coord end)
    |> Enum.map(fn {_, square} -> square end)
  end
end
