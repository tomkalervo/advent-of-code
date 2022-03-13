#find the gamma and epsiol
defmodule Fuel do
  def test() do
    test = """
        00100
        11110
        10110
        10111
        10101
        01111
        00111
        11100
        10000
        11001
        00010
        01010
        """
    power(test)
  end

  def power(input) do
    String.split(input, "\n")
    |> Enum.filter(fn(row) -> String.length(row) > 1 end)
    |> List.foldl(Enum.map(0..4, fn(_) -> 0 end), fn(row, acc) ->
      count(row,0,acc)
    end)
    |> consumption()

  end

  def consumption(x) do
    consumption(x, Enum.reverse(Enum.map(0..4, fn(x) ->
      :math.pow(2,x) end)), {0,0})
  end
  def consumption([],[],{g,e}), do: g*e
  def consumption([hx|tx], [hp|tp], {g,e}) do
    if hx > 0 do
      # Gamma found
      consumption(tx,tp,{g + hp, e})
    else
      # Epsilon found
      consumption(tx,tp,{g,e + hp})
    end
  end

  def count(_,_,[]), do: []
  def count(row,n,[h|t]) do
    case String.slice(row, n..n) do
      "1" -> [h+1|count(row,n+1,t)]
      "0" -> [h-1|count(row,n+1,t)]
    end
  end

end
