defmodule LexibombServer.Board do
  @moduledoc """
  """

  alias LexibombServer.Board.Square

  @default_size 15
  @bomb_count 22

  def new(size \\ @default_size) do
    empty_board(size)
  end

  def empty_board(size) do
    border = 2
    total_squares = (size + border) * (size + border)
    for _ <- 1..total_squares, do: %Square{}
  end

  def debug(device \\ :stdio, board) do
    size = size_of_raw(board)
    border = 2

    header = draw_header(size - border)
    top = draw_grid_line(size, :top)
    middle = draw_all_rows(board)
    bottom = draw_grid_line(size, :bottom)

    board = header <> top <> middle <> bottom
    IO.write(device, board)
  end

  def size_of(board) do
    border = 2
    board
    |> size_of_raw
    |> Kernel.'-'(border)
  end

  defp size_of_raw(board) do
    board
    |> length
    |> :math.sqrt
    |> round
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
    size = size_of_raw(board)
    grid_line = draw_grid_line(size, :middle)
    rows = for row <- 0..size-1, do: draw_row(board, row)
    rows |> Enum.join(grid_line)
  end

  defp draw_row(board, row) do
    first_row = 0
    last_row = size_of_raw(board) - 1
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
    size = size_of_raw(board)
    offset =
      case row do
        0 -> 0
        _ -> (row * size) - 1
      end
    Enum.slice(board, offset, size)
  end
end
