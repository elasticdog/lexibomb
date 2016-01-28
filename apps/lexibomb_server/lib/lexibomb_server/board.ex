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
end


defimpl Inspect, for: LexibombServer.Board do
  alias LexibombServer.Utils

  import LexibombServer.Board, only: [
    first_or_last?: 2,
    size: 1,
  ]

  def inspect(board, _opts) do
    render(board.grid)
  end

  defp render(grid) do
    label_width = 3
    space_width = 4
    line_width =
      label_width + (size(grid) * space_width) + 1

    grid
    |> render_into_list
    |> Stream.map(&String.rjust(&1, line_width))
    |> Enum.join("\n")
  end

  defp render_into_list(grid) do
    size = size(grid)

    header = header(size - 2)
    top    = Utils.draw_grid_line(size, :top)
    middle = collect_rows(grid)
    bottom = Utils.draw_grid_line(size, :bottom)

    [header] ++ [top] ++ middle ++ [bottom]
  end

  defp header(size) do
    last_col = ?a + size - 1
    spacer = "   "
    offset = "      "

    Enum.to_list(?a .. last_col)
    |> List.to_string
    |> String.graphemes
    |> Enum.join(spacer)
    |> Kernel.<>(offset)
  end

  defp collect_rows(grid) do
    size = size(grid)
    grid_line = Utils.draw_grid_line(size, :middle)

    grid
    |> chunk_by_rows(size)
    |> Stream.map(&Utils.draw_segments/1)
    |> label_rows(size)
    |> Enum.intersperse(grid_line)
  end

  defp chunk_by_rows(grid, count) do
    grid
    |> Enum.sort_by(fn {coord, _} -> coord end)
    |> Stream.map(fn {_, square} -> inspect(square) end)
    |> Stream.chunk(count)
  end

  defp label_rows(rows, grid_size) do
    rows
    |> Stream.with_index
    |> Stream.map(fn {row, index} ->
         label? = !first_or_last?(index, grid_size)
         label = if label?, do: Utils.zero_pad(index, 2), else: "  "

         "#{label} #{row}"
       end)
  end
end
