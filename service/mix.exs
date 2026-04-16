defmodule BKHack.Mix do
  use Mix.Project

  def project do
    [
      app: :bkhack,
      version: "0.9.0",
      deps: deps()
    ]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:ecto_sqlite3, "~> 0.17"},
      {:postgrex, ">= 0.0.0"},
      {:cowboy, "~> 2.6"},
      {:plug, "~> 1.7"},
      {:plug_cowboy, "~> 2.0"},
      {:json, "~> 1.4"}
    ]
  end
end
