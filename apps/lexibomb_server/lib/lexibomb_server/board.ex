defmodule LexibombServer.Board do
  @moduledoc """
  """

  defstruct [:grid]

  alias LexibombServer.Board
  alias LexibombServer.Board.Square

  @default_size 15
  @bomb_count 22

  def new(size \\ @default_size) do
    border = 2
    grid =
      empty_grid(size + border)
      |> deactivate_border

    Agent.start_link(fn -> %Board{grid: grid} end)
  end

  def empty_grid(size) do
    for row <- 0 .. (size - 1),
        col <- 0 .. (size - 1),
        into: %{},
        do: {{row, col}, %Square{}}
  end

  def deactivate_border(grid) do
    coords = Map.keys(grid)
    size = size(grid)
    border_coords = Enum.filter(coords, &border_square?(&1, size))

    Enum.reduce(border_coords, grid, &deactivate/2)
  end

  def size(grid) do
    grid
    |> map_size
    |> :math.sqrt
    |> round
  end

  def border_square?(coord, size) do
    first = 0
    last = size - 1

    case coord do
      {^first, _} -> true
      {_, ^first} -> true
      {^last, _} -> true
      {_, ^last} -> true
      _ -> false
    end
  end

  def deactivate(coord, grid) do
    grid |> Map.update!(coord, &Square.deactivate/1)
  end

  def get(pid) do
    Agent.get(pid, &(&1))
  end

  def debug(device \\ :stdio, board) do
    size = size(board)
    border = 2

    header = draw_header(size - border)
    top = draw_grid_line(size, :top)
    middle = draw_all_rows(board)
    bottom = draw_grid_line(size, :bottom)

    board = header <> top <> middle <> bottom
    IO.write(device, board)
  end

  defp draw_header(size) do
    last_label = ?a + size - 1
    header =
      Enum.to_list(?a .. last_label)
      |> List.to_string
      |> String.graphemes
      |> Enum.join("   ")
    "         " <> header <> "\n"
  end

  defp draw_grid_line(size, :top), do: do_draw_grid_line(size, "┌", "┬", "┐")
  defp draw_grid_line(size, :middle), do: do_draw_grid_line(size, "├", "┼", "┤")
  defp draw_grid_line(size, :bottom), do: do_draw_grid_line(size, "└", "┴", "┘")

  defp do_draw_grid_line(size, first, inner, last) do
    separators = for _ <- 0..size-2, do: inner
    separators = [first] ++ separators ++ [last]
    grid_line = Enum.join(separators, "───")
    "   " <> grid_line <> "\n"
  end

  defp draw_all_rows(board) do
    size = size(board)
    grid_line = draw_grid_line(size, :middle)
    rows = for row <- 0..size-1, do: draw_row(board, row)
    rows |> Enum.join(grid_line)
  end

  defp draw_row(board, row) do
    first_row = 0
    last_row = size(board) - 1
    label =
      case row do
        ^first_row -> "  "
        ^last_row -> "  "
        _ -> zero_pad(row, 2)
      end

    row =
      get_row(board, row)
      |> Enum.map(&Square.draw/1)
      |> Enum.join("│")

    label <> " │" <> row <> "│\n"
  end

  defp zero_pad(n, length) do
    n |> to_string |> String.rjust(length, ?0)
  end

  defp get_row(board, row) do
    size = size(board)
    offset =
      case row do
        0 -> 0
        _ -> row * size
      end
    Enum.slice(board, offset, size)
  end
end
