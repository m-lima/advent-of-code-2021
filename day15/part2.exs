defmodule Aoc do
  @spec to_integer(char) :: integer
  def to_integer(c), do: c - ?0

  defp neighboors(index, len) do
    last = len - 1
    [0, -len, +len | case rem(index, len) do
      0 -> [+1]
      ^last -> [-1]
      _ -> [+1, -1]
    end]
      |> Enum.map(fn i -> index + i end)
  end

  def increase(risks, amount), do:
    Enum.map(risks, fn x -> rem(x + amount - 1, 9) + 1 end)

  def visit(unvisited, visited, risks, _) when length(unvisited) == 0 do
    visited
      |> Enum.filter(fn {i, _} -> i == Enum.count(risks) - 1 end)
      |> Enum.map(fn {_, r} -> r end)
      |> List.first
  end

  def visit(unvisited, visited, risks, len) do
    {index, risk} = unvisited
      |> Enum.min_by(fn {_, r} -> r end)

    unvisited = List.delete(unvisited, {index, risk})
    visited = [ {index, risk} | visited ]

    unvisited = neighboors(index, len)
      |> Enum.flat_map(fn i -> Enum.filter(unvisited, fn
        {^i, _} -> true
        _ -> false
      end) end)
      |> Enum.map(fn {i, r} -> {i, min(r, risk + Enum.at(risks, i))} end)
      |> Enum.reduce(unvisited, fn
      {i, r}, acc -> acc
        |> Enum.map(fn
        {^i, _} -> {i, r}
        e -> e
        end)
      end)

    visit(unvisited, visited, risks, len)
  end
end

risks = File.read!("input.txt")
  |> String.split("\n")
  |> Enum.map(fn s ->
    s
    |> String.to_charlist()
    |> Enum.map(&Aoc.to_integer/1)
  end)
  |> Enum.map(fn s ->
    0..4
      |> Enum.map(fn a -> Aoc.increase(s, a) end)
      |> List.flatten
  end)
  |> List.flatten

risks = 0..4
  |> Enum.map(fn a -> Aoc.increase(risks, a) end)
  |> List.flatten

last = Enum.count(risks) - 1
len = Enum.count(risks) |> :math.sqrt |> round
unvisited = 0..last |> Enum.map(fn
  0 -> {0, 0}
  i -> {i, :infinity}
  end)
visited = []

Aoc.visit(unvisited, visited, risks, len)
  |> IO.inspect
