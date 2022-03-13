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

  end

  def gamma(input) do
    String.split(input, '\n')
    |> Stream.map(fn(row) -> String.to_integer(row) end)
    |> IO.inspect()
  end


end
