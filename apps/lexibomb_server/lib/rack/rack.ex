defmodule LexibombServer.Rack do
  @moduledoc """
  Provides functions related to dealing with a rack of tiles.

  A tile is represented as a single-character string, like `"W"`. A blank tile,
  while on the rack, is represented as the underscore character, `"_"`. Once
  a blank tile is played on the board, it is used to represent a specific
  letter in a word, but does not earn points. To distinguish between scoring
  and non-scoring tiles, uppercase and lowercase letters are used respectively.

  A rack is a list of tiles (usually 7 tiles),
  like `["E", "E", "L", "R", "T", "T", "S"]`.

  For example, `~W(E E L R T T _)` is a rack that contains a blank tile;
  and `~W(L E T T E R s)` is a word played on the board that uses the blank to
  stand for the letter _S_.
  """

  @blank "_"
  @alpha ~w{a b c d e f g h i j k l m n o p q r s t u v w x y z}

  @doc """
  Returns the distinct letters in a `rack`.

  Includes the lowercase alphabet if there are any blank tiles.

  ## Examples

      iex> LexibombServer.Rack.letters ~W(E E L R T T S)
      ["E", "L", "R", "T", "S"]
      iex> LexibombServer.Rack.letters ~W(E E L R T T _)
      ["E", "L", "R", "T", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l",
       "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
  """
  @spec letters([String.t]) :: [String.t]
  def letters(rack) do
    if @blank in rack do
      rack
      |> Stream.filter(&(&1 !== @blank))
      |> Stream.concat(@alpha)
      |> Enum.uniq
    else
      Enum.uniq(rack)
    end
  end

  @doc """
  Returns a copy of `rack` with the given `tiles` removed.

  If any of the given tiles are lowercase letters, a corresponding blank tile
  is removed from the rack.

  ## Examples

      iex> LexibombServer.Rack.remove ~W(E E L R T T S), ~W(S E T)
      ["E", "L", "R", "T"]
      iex> LexibombServer.Rack.remove ~W(E E L R T T _), ~W(T R E a T)
      ["E", "L"]
  """
  @spec remove([String.t], [String.t]) :: String.t
  def remove(rack, tiles) do
    Enum.reduce(tiles, rack, fn(tile, rack) ->
      if lowercase?(tile), do: tile = @blank
      List.delete(rack, tile)
    end)
  end

  @spec lowercase?(String.t) :: boolean
  defp lowercase?(tile) do
    String.downcase(tile) === tile
  end
end
