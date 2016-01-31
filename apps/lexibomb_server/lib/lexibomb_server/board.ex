defmodule LexibombServer.Board do
  @moduledoc """
  """

  defstruct [:grid, :seed]

  alias LexibombServer.Board.Grid
  alias LexibombServer.Utils

  @type coord :: Grid.coord | {non_neg_integer, String.t} | String.t
  @type seed :: {integer, integer, integer}
  @type t :: %{grid: Grid.t, seed: seed}

  @typep reason :: :badarg | :coord_off_board

  @default_size 15
  @bomb_count 22

  @spec start_link :: Agent.on_start
  def start_link do
    start_link(new)
  end

  @spec start_link(t) :: Agent.on_start
  def start_link(board) do
    Agent.start_link(fn -> board end)
  end

  @spec new(pos_integer) :: t
  def new(size \\ @default_size) do
    new(size, Utils.unique_seed)
  end

  @spec new(pos_integer, seed) :: t
  def new(size, seed) do
    %LexibombServer.Board{
      grid: Grid.init(size),
      seed: seed,
    }
  end

  @spec get(pid) :: t
  def get(pid) do
    Agent.get(pid, &(&1))
  end

  @spec set(t, pid) :: :ok
  def set(board, pid) do
    Agent.update(pid, fn _ -> board end)
  end

  @spec size(pid) :: pos_integer
  def size(pid) do
    Agent.get(pid, fn board ->
      Grid.board_size(board.grid)
    end)
  end

  @doc """
  Places a bomb on the board square at the given coordinate.

  Returns `:ok` on success, or `{:error, reason}` on failure.
  """
  @spec place_bomb(pid, coord) :: :ok | {:error, reason}
  def place_bomb(pid, coord) do
    case parse_coord(pid, coord) do
      {:ok, coord} ->
        do_place_bomb(pid, coord)
      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec do_place_bomb(pid, Grid.coord) :: :ok
  defp do_place_bomb(pid, coord) do
    Agent.update(pid, fn board ->
      %{board | grid: Grid.place_bomb(board.grid, coord)}
    end)
  end

  @spec place_bombs(pid, [coord]) :: :ok | {:error, reason}
  def place_bombs(pid, coords) do
    parsed_coords = coords |> Enum.map(&parse_coord(pid, &1))

    any_errors? =
      Enum.any?(parsed_coords, fn coord ->
        match?({:error, _}, coord)
      end)

    if any_errors? do
      {:error, :badarg}
    else
      parsed_coords
      |> Keyword.values
      |> do_place_bombs(pid)
    end
  end

  @spec do_place_bombs([Grid.coord], pid) :: :ok
  defp do_place_bombs(coords, pid) do
    Agent.update(pid, fn board ->
      %{board | grid: Grid.place_bombs(board.grid, coords)}
    end)
  end

  @spec place_random_bombs(pid, pos_integer) :: :ok
  def place_random_bombs(pid, count \\ @bomb_count) do
    board = get(pid)
    _ = Utils.seed_the_prng(board.seed)

    board.grid
    |> Grid.active_squares
    |> Map.keys
    |> Enum.take_random(count)
    |> do_place_bombs(pid)
  end

  @spec parse_coord(pid, coord) :: {:ok, Grid.coord} | {:error, reason}
  defp parse_coord(pid, coord) when is_binary(coord) do
    {row_string, letter} = coord |> String.split_at(-1)

    try do
      row_string
      |> String.rstrip
      |> String.to_integer
    catch
      :error, :badarg -> {:error, :badarg}
    else
      row -> parse_coord(pid, {row, letter})
    end
  end

  defp parse_coord(pid, {row, letter}) when is_binary(letter) do
    col = letter_to_col(letter)
    parse_coord(pid, {row, col})
  end

  defp parse_coord(pid, {row, col}) do
    grid = get(pid).grid

    if Grid.valid_coord?(grid, {row, col}) do
      {:ok, {row, col}}
    else
      {:error, :coord_off_board}
    end
  end

  @spec letter_to_col(String.t) :: pos_integer
  defp letter_to_col(string) when byte_size(string) === 1 do
    normalized = String.downcase(string)
    [char] = normalized |> to_char_list

    char - ?a + 1
  end

  # Reveal all the squares on a `board` for debugging.
  @doc false
  @spec __reveal__(pid | t) :: t
  def __reveal__(pid) when is_pid(pid) do
    Agent.get_and_update(pid, fn board ->
      new_board = __reveal__(board)
      {new_board, new_board}
    end)
  end
  def __reveal__(board) do
    %{board | grid: Grid.__reveal__(board.grid)}
  end
end


defimpl Inspect, for: LexibombServer.Board do
  alias LexibombServer.Board.{Grid, Square}
  alias LexibombServer.Utils

  @spec inspect(LexibombServer.Board.t, Keyword.t) :: String.t
  def inspect(board, _opts) do
    render(board.grid)
  end

  @spec render(Grid.t | nil) :: String.t
  defp render(nil), do: "#Board<[]>"
  defp render(grid) do
    indent = 2
    label_width = 3
    space_width = 4
    line_width =
      indent + label_width + (Grid.size(grid) * space_width) + 1

    board =
      grid
      |> render_into_list
      |> Stream.map(&String.rjust(&1, line_width))
      |> Enum.join("\n")

    """
    #Board<
    #{board}
    >
    """
    |> String.rstrip
  end

  @spec render_into_list(Grid.t) :: [String.t]
  defp render_into_list(grid) do
    size = Grid.size(grid)

    header = header(size - 2)
    top    = Utils.draw_grid_line(size, :top)
    middle = collect_rows(grid)
    bottom = Utils.draw_grid_line(size, :bottom)

    [header] ++ [top] ++ middle ++ [bottom]
  end

  @spec header(pos_integer) :: String.t
  defp header(size) do
    last_col = ?a + size - 1
    spacer = "   "
    offset = "      "

    Enum.to_list(?a .. last_col)
    |> List.to_string
    |> String.graphemes
    |> Enum.join(spacer)
    |> Kernel.<>(offset)
  end

  @spec collect_rows(Grid.t) :: [String.t]
  defp collect_rows(grid) do
    size = Grid.size(grid)
    grid_line = Utils.draw_grid_line(size, :middle)

    grid
    |> chunk_by_rows(size)
    |> Stream.map(&Utils.draw_segments/1)
    |> label_rows(size)
    |> Enum.intersperse(grid_line)
  end

  @spec chunk_by_rows(Grid.t, pos_integer) :: Enumerable.t
  defp chunk_by_rows(grid, count) do
    grid
    |> Enum.sort_by(fn {coord, _} -> coord end)
    |> Stream.map(fn {_, square} -> Square.__render_state__(square) end)
    |> Stream.chunk(count)
  end

  @spec label_rows(Enumerable.t, pos_integer) :: Enumerable.t
  defp label_rows(rows, grid_size) do
    rows
    |> Stream.with_index
    |> Stream.map(fn {row, index} ->
         label? = !Utils.first_or_last?(index, grid_size)
         label = if label?, do: Utils.zero_pad(index, 2), else: "  "

         "#{label} #{row}"
       end)
  end
end
