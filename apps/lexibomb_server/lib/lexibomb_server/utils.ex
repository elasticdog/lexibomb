defmodule LexibombServer.Utils do
  @moduledoc """
  Helper utilities used throughout LexibombServer.
  """

  @spec draw_grid_line(pos_integer, :top | :middle | :bottom) :: String.t
  def draw_grid_line(size, :top),    do: do_draw_grid_line(size, "┌", "┬", "┐")
  def draw_grid_line(size, :middle), do: do_draw_grid_line(size, "├", "┼", "┤")
  def draw_grid_line(size, :bottom), do: do_draw_grid_line(size, "└", "┴", "┘")

  @spec do_draw_grid_line(pos_integer, String.t, String.t, String.t) :: String.t

  defp do_draw_grid_line(1, first, _, last) do
    Enum.join([first, "───", last])
  end

  defp do_draw_grid_line(size, first, inner, last) do
    middle = for _ <- 0..size-2, do: inner
    separators = [first] ++ middle ++ [last]
    Enum.join(separators, "───")
  end

  @spec draw_segments([String.t], String.t) :: String.t
  def draw_segments(strings, sep \\ "│") do
    sep <> Enum.join(strings, sep) <> sep
  end

  @spec first_or_last?(non_neg_integer, non_neg_integer) :: boolean
  def first_or_last?(index, size) do
    first = 0
    last = size - 1

    case index do
      ^first -> true
      ^last -> true
      _ -> false
    end
  end

  @spec zero_pad(non_neg_integer, non_neg_integer) :: String.t
  def zero_pad(n, len) when is_integer(n) do
    n |> to_string |> String.rjust(len, ?0)
  end
end
