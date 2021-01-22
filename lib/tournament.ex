defmodule Tournament do
  @resultHeaderString "Team                           | MP |  W |  D |  L |  P"
  @gameResultIndex 2
  @possibleGameResults ["win", "draw", "loss"]
  @result %{mp: 1, w: 0, d: 0, l: 0, p: 0}

  @doc """
  Given `input` lines representing two teams and whether the first of them won,
  lost, or reached a draw, separated by semicolons, calculate the statistics
  for each team's number of games played, won, drawn, lost, and total points
  for the season, and return a nicely-formatted string table.

  A win earns a team 3 points, a draw earns 1 point, and a loss earns nothing.

  Order the outcome by most total points for the season, and settle ties by
  listing the teams in alphabetical order.
  """
  @spec tally(input :: list(String.t())) :: String.t()
  def tally(input) do
    input
    # destruct the input with -----;-
    |> Enum.map(&String.split(&1, ";"))
    # Clear the results if --------count is 3------and---------game result is valid-
    |> Enum.filter(fn game -> Enum.count(game) == 3 && Enum.at(game, @gameResultIndex) in @possibleGameResults end)
    # Analyze the lines!
    |> Enum.map(fn i -> analyze_game(i) end)
    # Merge results!
    |> Enum.reduce(fn game, acc -> Map.merge(acc, game, fn (_, v, vv) -> Map.merge(v, vv, fn (_, x, y) -> x + y end) end) end)
    # Sort the results by ----------point-
    |> Enum.sort_by(fn {_team, %{p: point}} -> point end, &Kernel.>=/2)
    # Generate Table!
    |> Enum.map(&format_results/1)
    # Add the header of the table!
    |> (&(Kernel.++([@resultHeaderString], &1))).()
    # Generate one result string with newline joined.
    |> Enum.join("\n")
  end

  defp resulter("win"), do: %{@result | mp: 1, w: 1, p: 3}
  defp resulter("draw"), do: %{@result | mp: 1, d: 1, p: 1}
  defp resulter("loss"), do: %{@result | mp: 1, l: 1, p: 0}
  defp resulter(_), do: raise {:error, "Invalid game result!"}

  defp analyze_game([home, away, "win"]), do: %{home => resulter("win"), away => resulter("loss")}
  defp analyze_game([home, away, "draw"]), do: %{home => resulter("draw"), away => resulter("draw")}
  defp analyze_game([home, away, "loss"]), do: %{home => resulter("loss"), away => resulter("win")}

  defp format_results({team, results}),
    do: "#{String.pad_trailing(team, 31)}|  #{results.mp} |  #{results.w} |  #{results.d} |  #{results.l} |  #{results.p}"

end
