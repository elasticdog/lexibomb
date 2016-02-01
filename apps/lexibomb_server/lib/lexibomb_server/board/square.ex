defmodule LexibombServer.Board.Square do
  @moduledoc """
  Manages the low-level state data associated with an individual board square.

  A square can either be hidden or revealed, which indicates whether its state
  data should be available externally. Placing a tile on a square automatically
  sets it to the revealed state.
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

  @doc """
  Returns a copy of `square` in the inactive state.
  """
  @spec deactivate(t) :: t
  def deactivate(square) do
    %{square | revealed?: true, tile: @inactive}
  end

  @doc """
  Returns `true` if the square is active.
  """
  @spec active?(t) :: boolean
  def active?(square) do
    square.tile !== @inactive
  end

  @doc """
  Returns a copy of `square` with an incremented adjacent bomb count.
  """
  @spec inc_adjacent_bombs(t) :: t
  def inc_adjacent_bombs(square) do
    %{square | adjacent_bombs: square.adjacent_bombs + 1}
  end

  @doc """
  Returns a copy of `square` in the revealed state.
  """
  @spec reveal(t) :: t
  def reveal(square) do
    %{square | revealed?: true}
  end

  @doc """
  Returns a copy of `square` with a bomb placed on it.
  """
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
