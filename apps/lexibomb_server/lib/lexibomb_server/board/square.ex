defmodule LexibombServer.Board.Square do
  @moduledoc """
  """

  defstruct [
    adjacent_bombs: 0,
    bomb?: false,
    revealed?: false,
    tile: "",
  ]

  @bomb_symbol "●"
  @adjacent_bomb_symbols { "◦", "│", "╎", "┆", "┊", "†", "‡", "¤", "*" }

  def draw(square) do
    if square.revealed? do
      "#{bomb_symbol(square)}#{square.tile}" |> String.ljust(3)
    else
      "   "
    end
  end

  defp bomb_symbol(square) do
    if square.bomb? do
      @bomb_symbol
    else
      @adjacent_bomb_symbols |> elem(square.adjacent_bombs)
    end
  end
end
