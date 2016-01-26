defmodule LexibombServer.Tile do
  @moduledoc """
  Provides functions related to dealing with single tiles.

  A tile is represented as a single-character string, like `"W"`. A blank tile,
  while on a player's rack, is represented as the underscore character, `"_"`.
  Once a blank tile is played on the board, it is used to represent a specific
  letter in a word, but does not earn points. To distinguish between scoring
  and non-scoring tiles, uppercase and lowercase letters are used respectively.

  For example, `~W(E E L R T T _)` is a rack that contains a blank tile;
  and `~W(L E T T E R s)` is a word played on the board that uses the blank to
  stand for the letter _S_.
  """

  @letter_points %{
    "A" => 1,
    "B" => 3,
    "C" => 3,
    "D" => 2,
    "E" => 1,
    "F" => 4,
    "G" => 2,
    "H" => 4,
    "I" => 1,
    "J" => 8,
    "K" => 5,
    "L" => 1,
    "M" => 3,
    "N" => 1,
    "O" => 1,
    "P" => 3,
    "Q" => 10,
    "R" => 1,
    "S" => 1,
    "T" => 1,
    "U" => 1,
    "V" => 4,
    "W" => 4,
    "X" => 8,
    "Y" => 4,
    "Z" => 10,
  }

  @doc """
  Returns the point value of an individual `tile`.

  ## Examples

      iex> LexibombServer.Tile.points "G"
      2
      iex> LexibombServer.Tile.points "g"
      0
      iex> LexibombServer.Tile.points "_"
      0
  """
  @spec points(String.t) :: integer
  def points(tile) do
    Map.get(@letter_points, tile, 0)
  end
end
