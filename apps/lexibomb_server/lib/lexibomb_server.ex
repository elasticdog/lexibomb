defmodule LexibombServer do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      worker(LexibombServer.WordList, word_list_args),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LexibombServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Force a minimal word list when running tests
  defp word_list_args do
    case Mix.env do
      :test ->
        [MapSet.new(~W(THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG))]
      _ ->
        []
    end
  end
end
