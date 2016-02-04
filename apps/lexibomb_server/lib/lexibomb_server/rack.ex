defmodule LexibombServer.Rack do
  @moduledoc """
  Provides functions related to dealing with a rack of tiles.

  A rack is a list of (usually 7) tiles, like `["E", "E", "L", "R", "T", "T", "S"]`.
  """

  defstruct tiles: []

  @type t :: %{tiles: [String.t]}

  @blank "_"
  @alpha ~w{a b c d e f g h i j k l m n o p q r s t u v w x y z}

  @doc """
  Creates a new rack with the given tiles.

  The tiles are normalized to uppercase.

  `tiles` can be either a string, which will be tokenized for you, or a list of
  tiles.

  ## Examples

      iex> LexibombServer.Rack.new "Hello"
      %LexibombServer.Rack{tiles: ["H", "E", "L", "L", "O"]}
      iex> LexibombServer.Rack.new ~W(E E L R T T _)
      %LexibombServer.Rack{tiles: ["E", "E", "L", "R", "T", "T", "_"]}
  """
  @spec new(String.t | [String.t]) :: t
  def new(tiles)

  def new(string) when is_binary(string) do
    string |> String.graphemes |> new
  end

  def new(tiles) when is_list(tiles) do
    tiles = tiles |> Enum.map(&String.upcase/1)

    %LexibombServer.Rack{tiles: tiles}
  end

  @doc """
  Returns the distinct letters in a `rack`.

  Includes the lowercase alphabet if there are any blank tiles.

  ## Examples

      iex> LexibombServer.Rack.new("EELRTTS") |> LexibombServer.Rack.letters
      ["E", "L", "R", "T", "S"]
      iex> LexibombServer.Rack.new("EELRTT_") |> LexibombServer.Rack.letters
      ["E", "L", "R", "T", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l",
       "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
  """
  @spec letters(t) :: [String.t]
  def letters(rack) do
    if @blank in rack.tiles do
      rack.tiles
      |> Stream.filter(&(&1 !== @blank))
      |> Stream.concat(@alpha)
      |> Enum.uniq
    else
      rack.tiles
      |> Enum.uniq
    end
  end

  @doc """
  Returns a copy of `rack` with the given letters removed.

  If any of the given letters are lowercase, a corresponding blank tile is
  removed from the rack.

  `letters` can be either a string, which will be tokenized for you, or a list
  of letters.

  ## Examples

      iex> LexibombServer.Rack.new("EELRTTS") |> LexibombServer.Rack.remove("SET")
      %LexibombServer.Rack{tiles: ["E", "L", "R", "T"]}
      iex> LexibombServer.Rack.new("EELRTT_") |> LexibombServer.Rack.remove(~W(T R E a T))
      %LexibombServer.Rack{tiles: ["E", "L"]}
  """
  @spec remove(t, String.t | [String.t]) :: t
  def remove(rack, letters)

  def remove(rack, string) when is_binary(string) do
    letters = string |> String.graphemes
    remove(rack, letters)
  end

  def remove(rack, letters) when is_list(letters) do
    tiles =
      Enum.reduce(letters, rack.tiles, fn(letter, tiles) ->
        if lowercase?(letter), do: letter = @blank
        tiles |> List.delete(letter)
      end)

    new(tiles)
  end

  @spec lowercase?(String.t) :: boolean
  defp lowercase?(letter) do
    String.downcase(letter) === letter
  end
end
