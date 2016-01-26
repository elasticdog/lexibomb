defmodule LexibombServer.Board.Square do
  @moduledoc """
  """

  defstruct [
    adjacent_bombs: 0,
    bomb?: false,
    revealed?: false,
    tile: "",
  ]

  @inactive "#"
  @bomb_symbol "●"
  @adjacent_bomb_symbols { "◦", "│", "╎", "┆", "┊", "†", "‡", "¤", "*" }

  def deactivate(square) do
    %{square | revealed?: true, tile: @inactive}
  end

  defp inactive?(square) do
    square.tile === @inactive
  end

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
