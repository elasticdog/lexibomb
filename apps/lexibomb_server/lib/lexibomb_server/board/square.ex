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

  def deactivate(square) do
    %{square | revealed?: true, tile: @inactive}
  end

  def inactive?(square) do
    square.tile === @inactive
  end

  def reveal(square) do
    %{square | revealed?: true}
  end
end

defimpl Inspect, for: LexibombServer.Board.Square do
  @bomb_symbol "●"
  @adjacent_bomb_symbols { "◦", "│", "╎", "┆", "┊", "†", "‡", "¤", "*" }

  def inspect(square, _opts) do
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
