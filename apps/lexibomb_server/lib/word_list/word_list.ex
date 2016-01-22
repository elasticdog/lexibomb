defmodule LexibombServer.WordList do
  @moduledoc """
  Manages access to the list of valid gameplay words.

  The default word list is based on Mendel Leo Cooper's
  _[Yet Another Word List](https://github.com/elasticdog/yawl)_ (YAWL) project.
  """

  @doc """
  Starts an agent linked to the current process to store a normalized version
  of `word_list`.
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
  Checks if the word list contains `word`.
  """
  @spec member?(String.t) :: boolean
  def member?(word) do
    Agent.get(__MODULE__, fn word_list ->
      normalize(word) in word_list
    end)
  end
end
