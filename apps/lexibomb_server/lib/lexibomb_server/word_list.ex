defmodule LexibombServer.WordList do
  @moduledoc """
  Manages access to the list of valid gameplay words.
  """

  @doc """
  Starts an agent linked to the current process to store a normalized version
  of `word_list`.

  The default word list is based on Mendel Leo Cooper's
  _[Yet Another Word List](https://github.com/elasticdog/yawl)_ (YAWL) project.
  """
  @spec start_link(MapSet.t) :: Agent.on_start
  def start_link(word_list \\ default_list) do
    normalized_list = Enum.map(word_list, &normalize/1)
    Agent.start_link(fn -> normalized_list end, name: __MODULE__)
  end

  @spec default_list :: MapSet.t
  defp default_list do
    Application.app_dir(:lexibomb_server, "priv/word.list")
    |> File.stream!
    |> Stream.map(&String.rstrip/1)
    |> MapSet.new
  end

  @spec normalize(String.t) :: String.t
  defp normalize(word) do
    String.upcase(word)
  end

  @doc """
  Retrieves the default word list from the agent.
  """
  @spec get :: MapSet.t
  def get do
    Agent.get(__MODULE__, &(&1))
  end

  @doc """
  Checks if the word list contains `word`.
  """
  @spec member?(String.t) :: boolean
  def member?(word) do
    Agent.get(__MODULE__, fn word_list ->
      normalize(word) in word_list
    end)
  end

  @doc """
  The set of all prefixes of each word in a given `word_list`.

  ## Examples

      iex> word_list = MapSet.new(["HELLO", "HELP", "HELPER"])
      iex> LexibombServer.WordList.prefixes(word_list)
      #MapSet<["", "H", "HE", "HEL", "HELL", "HELP", "HELPE"]>
  """
  @spec prefixes(MapSet.t) :: MapSet.t
  def prefixes(word_list) do
    Enum.reduce(word_list, MapSet.new([""]), fn word, prefixes ->
      word |> do_prefixes |> MapSet.union(prefixes)
    end)
  end

  defp do_prefixes(word) do
    for i <- 1..byte_size(word) - 1, into: %MapSet{} do
      <<prefix::binary-size(i), _::binary>> = word
      prefix
    end
  end
end
