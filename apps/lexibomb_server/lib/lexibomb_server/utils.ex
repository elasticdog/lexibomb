defmodule LexibombServer.Utils do
  @moduledoc """
  Helper utilities used throughout LexibombServer.
  """

  def draw_grid_line(size, :top),    do: do_draw_grid_line(size, "┌", "┬", "┐")
  def draw_grid_line(size, :middle), do: do_draw_grid_line(size, "├", "┼", "┤")
  def draw_grid_line(size, :bottom), do: do_draw_grid_line(size, "└", "┴", "┘")

  defp do_draw_grid_line(1, first, _, last) do
    Enum.join([first, "───", last])
  end

  defp do_draw_grid_line(size, first, inner, last) do
    middle = for _ <- 0..size-2, do: inner
    separators = [first] ++ middle ++ [last]
    Enum.join(separators, "───")
  end

  def pad_line(line, pad \\ 0) do
    String.duplicate(" ", pad) <> line <> "\n"
  end

  def draw_segments(strings, sep \\ "│") do
    sep <> Enum.join(strings, sep) <> sep
  end

  def zero_pad(n, len) when is_integer(n) do
    n |> to_string |> String.rjust(len, ?0)
  end
end
