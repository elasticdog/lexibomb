defmodule LexibombServer.WordList do
  @moduledoc """
  Manages access to the list of valid words based on Mendel Leo Cooper's
  _[Yet Another Word List](https://github.com/elasticdog/yawl)_ (YAWL).
  """

  @doc """
  Starts an agent linked to the current process to store the word list after
  reading it from disk.
  """
  @spec start_link :: Agent.on_start
  def start_link do
    path = Application.app_dir(:lexibomb_server, "priv/word.list")
    word_list =
      path
      |> File.stream!
      |> Stream.map(&String.rstrip/1)
      |> MapSet.new

    Agent.start_link(fn -> word_list end, name: __MODULE__)
  end

  @doc """
  Checks if the word list contains `word`.
  """
  @spec member?(String.t) :: boolean
  def member?(word) do
    Agent.get(__MODULE__, fn word_list ->
      word in word_list
    end)
  end
end
