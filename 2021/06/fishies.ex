defmodule Fishies do
  def demo(days) do
    start([3,4,3,1,2], days)
  end
  def input(file, days) do
    File.stream!(file, [:read], :line)
    |> Enum.flat_map(fn(x) ->
      String.split(x, ",")
    end)
    |> Enum.map(fn(x) -> String.to_integer(x) end)
    |> start(days)
  end

  def start(fishies, days) do
    # Part 2 - Use smarter data structure [age 0, age 1, ..., age 8]
    template = Enum.to_list(0..8)
    |> Enum.map(fn(_) -> 0 end)
    |> List.to_tuple()
    List.foldl(fishies, template, fn(x, template) ->
      val = elem(template, x)
      put_elem(template, x, val+1)
    end)
    |> Tuple.to_list()
    |> simulate(days)
    |> List.foldl(0, fn(x, acc) ->  x + acc end)

    # Part 1 - Simple list operations
    # simulate(fishies, days, [])
    # |> Enum.count()
  end

  # Part 2
  def simulate(fishies, 0), do: fishies
  def simulate([birth|fishies], days) do
    fishies = fish_append(fishies, birth, 0, [])
    simulate(fishies, days-1)
  end
  def fish_append([], birth, 8, fishies), do: Enum.reverse([birth|fishies])
  def fish_append([f|fish], birth, n, fishies) do
    if n == 6 do
      fish_append(fish, birth, n+1, [f+birth|fishies])
    else
      fish_append(fish, birth, n+1, [f|fishies])
    end
  end

  # Part 1
  def simulate(fishies, 0, _), do: fishies
  def simulate([], days, growth), do: simulate(growth, days-1, [])
  def simulate([f|fishies], days, growth) do
    if f == 0 do
      simulate(fishies, days, [6,8|growth])
    else
      simulate(fishies, days, [f-1|growth])
    end
  end
end
