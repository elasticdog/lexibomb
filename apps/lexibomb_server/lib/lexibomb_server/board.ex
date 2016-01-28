defmodule LexibombServer.Board do
  @moduledoc """
  """

  defstruct [:grid]

  alias LexibombServer.Board
  alias LexibombServer.Board.Square
  alias LexibombServer.Utils

  @type row :: non_neg_integer
  @type col :: non_neg_integer
  @type coord :: {row, col}
  @type grid :: %{coord => Square.t}
  @type t :: %{grid: grid}

  @default_size 15
  @bomb_count 22

  @spec new(pos_integer) :: Agent.on_start
  def new(size \\ @default_size) do
    board = %Board{grid: initialize_grid(size)}
    Agent.start_link(fn -> board end)
  end

  @spec initialize_grid(pos_integer) :: grid
  def initialize_grid(size) do
    border = 2

    empty_grid(size + border)
    |> deactivate_border
  end

  @spec empty_grid(pos_integer) :: grid
  def empty_grid(size) do
    for row <- 0 .. (size - 1),
        col <- 0 .. (size - 1),
        into: %{},
        do: {{row, col}, %Square{}}
  end

  @spec deactivate_border(grid) :: grid
  def deactivate_border(grid) do
    coords = Map.keys(grid)
    grid_size = size(grid)
    border_coords = Enum.filter(coords, &border_square?(&1, grid_size))

    Enum.reduce(border_coords, grid, &deactivate/2)
  end

  @spec size(grid) :: pos_integer
  def size(grid) do
    grid
    |> map_size
    |> :math.sqrt
    |> round
  end

  @spec border_square?(coord, pos_integer) :: boolean
  def border_square?(coord, grid_size) do
    {row, col} = coord
    cond do
      row |> first_or_last?(grid_size) -> true
      col |> first_or_last?(grid_size) -> true
      true -> false
    end
  end

  @spec first_or_last?(non_neg_integer, non_neg_integer) :: boolean
  def first_or_last?(index, size) do
    first = 0
    last = size - 1

    case index do
      ^first -> true
      ^last -> true
      _ -> false
    end
  end

  @spec deactivate(coord, grid) :: grid
  def deactivate(coord, grid) do
    Map.update!(grid, coord, &Square.deactivate/1)
  end

  @spec get(pid) :: Board.t
  def get(pid) do
    Agent.get(pid, &(&1))
  end

  @spec set(pid, Board.t) :: :ok
  def set(pid, board) do
    Agent.update(pid, fn _ -> board end)
  end

  # Reveal all the squares on a `board` for debugging.
  @doc false
  @spec __reveal__(Board.t) :: Board.t
  def __reveal__(board) do
    new_grid =
      board.grid
      |> Enum.into(%{}, fn {coord, square} ->
           {coord, Square.reveal(square)}
         end)

    %{board | grid: new_grid}
  end
end


defimpl Inspect, for: LexibombServer.Board do
  alias LexibombServer.Board
  alias LexibombServer.Utils

  import LexibombServer.Board, only: [
    first_or_last?: 2,
    size: 1,
  ]

  @spec inspect(Board.t, Keyword.t) :: String.t
  def inspect(board, _opts) do
    render(board.grid)
  end

  @spec render(Board.grid) :: String.t
  defp render(grid) do
    label_width = 3
    space_width = 4
    line_width =
      label_width + (size(grid) * space_width) + 1

    grid
    |> render_into_list
    |> Stream.map(&String.rjust(&1, line_width))
    |> Enum.join("\n")
  end

  @spec render_into_list(Board.grid) :: [String.t]
  defp render_into_list(grid) do
    size = size(grid)

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

  @spec collect_rows(Board.grid) :: [String.t]
  defp collect_rows(grid) do
    size = size(grid)
    grid_line = Utils.draw_grid_line(size, :middle)

    grid
    |> chunk_by_rows(size)
    |> Stream.map(&Utils.draw_segments/1)
    |> label_rows(size)
    |> Enum.intersperse(grid_line)
  end

  @spec chunk_by_rows(Board.grid, pos_integer) :: Enumerable.t
  defp chunk_by_rows(grid, count) do
    grid
    |> Enum.sort_by(fn {coord, _} -> coord end)
    |> Stream.map(fn {_, square} -> inspect(square) end)
    |> Stream.chunk(count)
  end

  @spec label_rows(Enumerable.t, pos_integer) :: Enumerable.t
  defp label_rows(rows, grid_size) do
    rows
    |> Stream.with_index
    |> Stream.map(fn {row, index} ->
         label? = !first_or_last?(index, grid_size)
         label = if label?, do: Utils.zero_pad(index, 2), else: "  "

         "#{label} #{row}"
       end)
  end
end
