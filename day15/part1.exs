defmodule Aoc do
  @spec to_integer(char) :: integer
  def to_integer(c), do: c - ?0

  defp neighboors(next, len) do
    last = len - 1
    [0, -len, +len | case rem(next, len) do
      0 -> [+1]
      ^last -> [-1]
      _ -> [+1, -1]
    end]
  end

  defp step(unvisited, visited, risks, nodes, len) do
    {_, risk, next} = List.first(risks)
    risks = neighboors(next, len)
      |> Enum.map(fn s -> s + next end)
      |> Enum.filter(fn i -> MapSet.member?(unvisited, i) end)
      |> Enum.reduce(risks, fn curr, acc ->
        acc
          |> Enum.map(fn
            {_, value, ^next} -> {true, value, next}
            {seen, value, ^curr} -> {seen, min(value, risk + Enum.at(nodes, curr)), curr}
            {seen, value, idx} -> {seen, value, idx}
          end)
      end)
      |> Enum.sort
    unvisited = MapSet.delete(unvisited, next)
    visited = MapSet.put(visited, next)
    visit(unvisited, visited, risks, nodes, len)
  end

  def visit(unvisited, visited, risks, nodes, len) do
    case List.first(risks) do
      {true, _, _} -> risks
      _ -> step(unvisited, visited, risks, nodes, len)
    end
  end
end

nodes = [ 0 | File.read!("input.txt")
  |> String.replace(~r"[^0-9]", "")
  |> String.to_charlist()
  |> Enum.drop(1)
  |> Enum.map(&Aoc.to_integer/1)]

last = Enum.count(nodes) - 1
len = Enum.count(nodes) |> :math.sqrt |> Kernel.round
unvisited = 0..last |> MapSet.new
visited = MapSet.new()
risks = 0..last |> Enum.map(fn
  0 -> {false, 0, 0}
  i -> {false, :infinity, i}
  end)

Aoc.visit(unvisited, visited, risks, nodes, len)
  |> Enum.find_value(-1, fn
    {_, v, ^last} -> v
    _ -> nil
  end)
  |> IO.inspect
