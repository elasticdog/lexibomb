defmodule LexibombServer.Board.Square do
  @moduledoc """
  """

  defstruct [
    adjacent_bombs: 0,
    bomb?: false,
    revealed?: false,
    tile: "",
  ]

  alias LexibombServer.Board.Square

  @type t :: %{
    adjacent_bombs: non_neg_integer,
    bomb?: boolean,
    revealed?: boolean,
    tile: String.t,
  }

  @inactive "█"

  @spec deactivate(Square.t) :: Square.t
  def deactivate(square) do
    %{square | revealed?: true, tile: @inactive}
  end

  @spec inactive?(Square.t) :: boolean
  def inactive?(square) do
    square.tile === @inactive
  end

  @spec reveal(Square.t) :: Square.t
  def reveal(square) do
    %{square | revealed?: true}
  end

  @spec place_bomb(Square.t) :: Square.t
  def place_bomb(square) do
    %{square | bomb?: true}
  end
end


defimpl Inspect, for: LexibombServer.Board.Square do
  alias LexibombServer.Board.Square

  @bomb_symbol "●"
  @adjacent_bomb_symbols { "·", "│", "╎", "┆", "┊", "†", "‡", "¤", "*" }

  @spec inspect(Square.t, Keyword.t) :: String.t
  def inspect(square, _opts) do
    if square.revealed? do
      "#{bomb_symbol(square)}#{square.tile}" |> String.ljust(3)
    else
      "   "
    end
  end

  @spec bomb_symbol(Square.t) :: String.t
  defp bomb_symbol(square) do
    if square.bomb? do
      @bomb_symbol
    else
      @adjacent_bomb_symbols |> elem(square.adjacent_bombs)
    end
  end
end
