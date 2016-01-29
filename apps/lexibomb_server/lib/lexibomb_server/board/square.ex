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

  @adjacent_bomb_symbols { "·", "│", "╎", "┆", "┊", "†", "‡", "¤", "*" }
  @bomb_symbol "●"
  @inactive "█"

  @spec deactivate(Square.t) :: Square.t
  def deactivate(square) do
    %{square | revealed?: true, tile: @inactive}
  end

  @spec active?(Square.t) :: boolean
  def active?(square) do
    square.tile !== @inactive
  end

  @spec reveal(Square.t) :: Square.t
  def reveal(square) do
    %{square | revealed?: true}
  end

  @spec place_bomb(Square.t) :: Square.t
  def place_bomb(square) do
    %{square | bomb?: true}
  end

  @doc false
  @spec __render_state__(Square.t) :: String.t
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
  alias LexibombServer.Utils

  @spec inspect(Square.t, Keyword.t) :: String.t
  def inspect(square, _opts) do
    square =
      Square.__render_state__(square)
      |> Utils.draw_in_box
      |> Utils.indent(2)

    """
    #Square>
    #{square}
    >
    """
  end
end
