defmodule Image do
  require Integer
  # Calculate nr of "lit" pixels, i.e. nr of '#'
  def lit_pixels(image) do
    List.foldl(image, 0, fn(row, tot_lit) ->
      tot_lit +
        List.foldl(row, 0, fn(pixel, lit) ->
          if pixel == ?# do
            lit + 1
          else
            lit
          end
        end)
    end)
  end

  # get nr of rows and columns
  def get_size(image = [h | _]) do
    rows = Enum.count(image)
    cols = Enum.count(h)
    [rows: rows, cols: cols]
  end

  # take an image, scan pixel starting from (-1, -1) to (+1, +1) and "enhance" it
  # since index is zero based we go to (+0,+0)
  def enhance(image, _, 0) do
    # Print for testing purpose
    # print(image)
    IO.inspect(get_size(image))
    IO.write(lit_pixels(image))
    IO.write("\n")
    image
  end
  def enhance(image, [zero|_] = algorithm, n) do
    [rows: rows, cols: cols] = get_size(image)
    # Print for testing purpose
    # print(image)
    IO.inspect([rows: rows, cols: cols])
    IO.write(lit_pixels(image))
    IO.write("\n")

    image =
      for row <- (-2)..(rows+1) do
        for col <- (-2)..(cols+1) do
          Algo.get_bitseq(image, {col,row})
          |> Enum.map(fn(pixel) ->
            if pixel == ?? do
              if (zero != ?.) and Integer.is_odd(n) do
                ?#
              else
                ?.
              end
            else
              pixel
            end
          end)
          |> Algo.sequence_to_number()
          |> Algo.get_value(algorithm)
        end
      end
    image = slim(image) # Turns out this function was not needed

    enhance(image, algorithm, n-1)
  end

  # Removes excess rows and cols that only consits of .
  # and are on the outer rim
  def slim(image) do
    slim_row(image, false)
    |> slim_col(false)
  end
  def slim_row([h|t] = image, n) do
    if slim_row(h) do
      slim_row(t, n)
    else
      if n do
        Enum.reverse(image)
      else
        slim_row(Enum.reverse(image), true)
      end
    end
  end
  def slim_row([]), do: true
  def slim_row([h|t]) do
    if h == ?. do
      slim_row(t)
    else
      false
    end
  end
  def slim_col(image, false) do
    case slim_col(image) do
      {true, im} -> slim_col(im, false)
      {false, _} ->
        image =
          Enum.map(image, fn(row) -> Enum.reverse(row) end)
        slim_col(image, true)
    end
  end
  def slim_col(image, true) do
    case slim_col(image) do
      {true, im} -> slim_col(im, true)
      {false, _} ->
        Enum.map(image, fn(row) -> Enum.reverse(row) end)
    end
  end
  def slim_col(image) do
      slim_dot_check([], image)
  end

  def slim_dot_check(acc, []), do: {true, Enum.reverse(acc)}
  def slim_dot_check(acc, [[h|t]|im]) do
    if h != ?. do
      {false, acc}
    else
      slim_dot_check([t|acc], im)
    end
  end

  # Prints the "image" for testing purposes
  def print([]), do: IO.write("\n")
  def print([h|t]) when is_integer(h) do
    IO.write([h])
    print(t)
  end
  def print([h|t]) do
    print(h)
    print(t)
  end
end
