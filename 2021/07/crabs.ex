defmodule Crabs do
  def demo() do
    input = [16,1,2,0,4,2,7,1,2,14]
    start(input)
  end

  def input(file) do
    File.stream!(file, [:read], :line)
    |> Enum.flat_map(fn(x) ->
      String.split(x, ",")
    end)
    |> Enum.map(fn(x) -> String.to_integer(x) end)
    |> start()
  end


  def start(crabs) do
    positions = List.foldl(crabs, 0, fn(x, acc) -> if x > acc do x else acc end end)
    [pos_h|pos_t] = Enum.to_list(0..positions)

    {pos, sum} = align(pos_t, crabs, fuel_cost(crabs, pos_h, 0))
    IO.write("Least cost of #{sum} found at position #{pos}\n")
  end

  def align([], _, result), do: result
  def align([h|rest], crabs, {pos_min, sum_min}) do
    {pos, min} = fuel_cost(crabs, h, 0)
    if min < sum_min do
      align(rest, crabs, {pos, min})
    else
      align(rest, crabs, {pos_min, sum_min})
    end
  end

  def fuel_cost([], pos, sum), do: {pos, sum}
  def fuel_cost([c|crabs], c, sum), do: fuel_cost(crabs, c, sum)
  def fuel_cost([c|crabs], position, sum) do
    if c > position do
      # PART 2
      fuel = List.foldl(Enum.to_list(0..(c-position)), 0, fn(x, acc) -> acc + x end)
      fuel_cost(crabs, position, sum + fuel)
      # PART 1
      # fuel_cost(crabs, position, sum + c - position)
    else
      # PART 2
      fuel = List.foldl(Enum.to_list(0..(position-c)), 0, fn(x, acc) -> acc + x end)
      fuel_cost(crabs, position, sum + fuel)
      # PART 1
      # fuel_cost(crabs, position, sum + position - c)
    end
  end
end
