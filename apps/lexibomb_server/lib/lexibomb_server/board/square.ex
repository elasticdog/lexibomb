defmodule LexibombServer.Board.Square do
  @moduledoc """
  """

  defstruct [
    adjacent_bombs: 0,
    bomb?: false,
    revealed?: false,
    tile: "",
  ]

  @type t :: %{
    adjacent_bombs: non_neg_integer,
    bomb?: boolean,
    revealed?: boolean,
    tile: String.t,
  }

  @adjacent_bomb_symbols { "·", "│", "╎", "┆", "┊", "†", "‡", "¤", "*" }
  @bomb_symbol "●"
  @inactive "█"

  @spec deactivate(t) :: t
  def deactivate(square) do
    %{square | revealed?: true, tile: @inactive}
  end

  @spec active?(t) :: boolean
  def active?(square) do
    square.tile !== @inactive
  end

  @spec inc_adjacent_bombs(t) :: t
  def inc_adjacent_bombs(square) do
    %{square | adjacent_bombs: square.adjacent_bombs + 1}
  end

  @spec reveal(t) :: t
  def reveal(square) do
    %{square | revealed?: true}
  end

  @spec place_bomb(t) :: t
  def place_bomb(square) do
    %{square | bomb?: true}
  end

  @doc false
  @spec __render_state__(t) :: String.t
  def __render_state__(square) do
    if square.revealed? do
      adjacent_bomb_count = elem(@adjacent_bomb_symbols, square.adjacent_bombs)
      tile = if square.tile === "", do: " ", else: square.tile
      bomb_status = if square.bomb?, do: @bomb_symbol, else: " "

      adjacent_bomb_count <> tile <> bomb_status
    else
      "   "
    end
  end
end


defimpl Inspect, for: LexibombServer.Board.Square do
  alias LexibombServer.Board.Square

  @spec inspect(Square.t, Keyword.t) :: String.t
  def inspect(square, _opts) do
    "#Square<[#{Square.__render_state__(square)}]>"
  end
end
