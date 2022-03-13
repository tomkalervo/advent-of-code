defmodule Depth do

  def input_jose(file) do
    input = File.stream!(file, [], :line)
    |> Stream.map(fn(x) -> Enum.filter(to_charlist(x), fn(char) -> char != ?\n end) end)
    |> Stream.map(fn(x) -> List.to_integer(x) end)

    first = Enum.chunk_every(input, 2, 1, :discard) #From josé
    |> Enum.count(fn([left,right]) -> left < right end) #From josé

    second = Enum.chunk_every(input, 3, 1, :discard)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.count(fn([left,right]) -> Enum.sum(left) < Enum.sum(right) end)

    :io.format("first solution: \t~w\nsecond solution: \t~w\n", [first, second])

  end

  def input(file) do
    input = File.stream!(file, [], :line)
    # clean input
    input = Stream.map(input, fn(x) ->
      Enum.filter(to_charlist(x), fn(x) -> x != ?\n end) end) |>
      Stream.map(fn(x) -> List.to_integer(x) end)
    # count and print
    :io.format("first solution: \t~w\n", [counter(Enum.to_list(input))])

    input = update(Enum.to_list(input), [])

    # window
    :io.format("second solution: \t~w\n", [counter(input)])

  end

  def counter([], {_,_,counter}) do counter end
  def counter([h|t], {:count, {:prev, value}, counter}) when h > value do
    counter(t, {:count, {:prev, h}, counter + 1})
  end
  def counter([h|t], {:count, {:prev, _}, counter}) do
    counter(t, {:count, {:prev, h}, counter})
  end
  def counter([h|t]) do
    counter(t, {:count, {:prev, h}, 0})
  end

  def update([_,_], lst) do Enum.reverse(lst) end
  def update([h|t], lst) do
  update(t, [h + List.foldl(Enum.take(t, 2), 0, fn(x, acc) -> acc + x end) | lst])
  end


end
