defmodule Aoe do
  def pilot() do
    {dist, alt, aim} = File.stream!("input.txt", [], :line)
    |> Enum.to_list()
    |> List.foldl({0,0,0}, fn(line, acc) -> nav(String.to_charlist(line), acc) end)
    IO.inspect({dist, alt, aim})
    IO.inspect(dist*alt)
  end

  def nav([?f,?o,?r,?w,?a,?r,?d,32,value,?\n], {dist, alt, aim}) do
    {dist + (value - 48), alt + (aim * (value - 48)), aim}
  end
  def nav([?u,?p,32,value,?\n], {dist, alt, aim}) do
    {dist, alt, aim - (value - 48)}
  end
  def nav([?d,?o,?w,?n,32,value,?\n], {dist, alt, aim}) do
    {dist, alt, aim + (value - 48)}
  end


end
