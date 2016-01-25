defmodule LexibombServer.Mixfile do
  use Mix.Project

  @source_url "https://github.com/elasticdog/lexibomb"

  def project do
    [
      app: :lexibomb_server,
      name: "Lexibomb Server",
      source_url: @source_url,
      homepage_url: "https://elasticdog.github.io/lexibomb",
      version: "0.0.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.2",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,
      docs: [
        source_url_pattern: "#{@source_url}/blob/#{source_ref}/apps/lexibomb_server/%{path}#L%{line}",
      ],
    ]
  end

  defp source_ref do
    {ref, 0} = System.cmd("git", ["rev-parse", "--verify", "--quiet", "HEAD"])
    ref = String.rstrip(ref)
    {tag, _} = System.cmd("git", ["tag", "--points-at", ref])
    tag = String.rstrip(tag)

    case tag do
      "" -> ref
      _ -> tag
    end
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger],
     mod: {LexibombServer, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # To depend on another app inside the umbrella:
  #
  #   {:myapp, in_umbrella: true}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    []
  end
end
