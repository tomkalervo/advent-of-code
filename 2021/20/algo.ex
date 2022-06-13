defmodule Algo do
  # Return value at position n in the list algorithm
  def get_value(n, algorithm) do
    Enum.fetch!(algorithm, n)
  end

  # Take an 'image' as a list, take 'pixel'-coordinate as a tuple
  # Return the bitsequence from the 3x3 square centered on the coordinate.
  def get_bitseq(image, {x1, y1}) do
    for y <- (y1 - 1)..(y1 + 1) do
      for x <- (x1 - 1)..(x1 + 1) do
        get_bit(image, {x, y})
      end
    end
    |> List.flatten()
  end

  def get_bit([row | _], {x, 0}) do
    get_bit(row, x)
  end
  def get_bit([_ | cols], {x, y}) when y > 0 do
    get_bit(cols, {x, y - 1})
  end
  def get_bit([h | _], 0), do: h
  def get_bit([_ | t], x) when is_number(x) do
    if x > 0 do
      get_bit(t, x - 1)
    else
      ?? #Change depending on enhance-iteration and algorithm for index 0
    end
  end
  def get_bit(_, _) do
    ?? #Change depending on enhance-iteration and algorithm for index 0
  end

  def sequence_to_number(seq) do
    {_, n} =
      Enum.map(seq, fn char ->
        case char do
          ?. -> 0
          ?# -> 1
        end
      end)
      |> List.foldr({1, 0}, fn c, {i, tot} ->
        {i * 2, c * i + tot}
      end)

    n
  end
end
