defmodule Octo do
  # PART 2
  def start() do
    #input = Input.demo
    input = Input.input
    |> String.split("\n", trim: true)
    |> Enum.map(fn(x) ->
      String.to_charlist(x)
    end)

    octos = List.foldl(input, 0, fn(row, acc) ->
      acc + List.foldl(row, 0, fn(_, acc) ->
        acc + 1
      end)
    end)
    |> IO.inspect()

    max_flash(input, octos, 0)
  end

  def max_flash(input, octos, iteration) do
    {{:flashes, f}, {:octos, o}} = sim_flashes({:flashes, 0}, {:octos, input}, 1)
    if f < octos do
      max_flash(o, octos, iteration+1)
    else
      iteration+1
    end
  end

  # PART 1
  def start(n) do
    #input = Input.demo
    input = Input.input
    |> String.split("\n", trim: true)
    |> Enum.map(fn(x) ->
      String.to_charlist(x)
    end)
    # |> IO.inspect()

    sim_flashes({:flashes, 0}, {:octos, input}, n)
  end


  def sim_flashes({:flashes, f}, {:octos, o}, 0) do
    #IO.puts("Flashes: #{f}")
    {{:flashes, f}, {:octos, o}}
    #IO.inspect(octos)
  end

  def sim_flashes({:flashes, nf}, {:octos, octos}, n) do
    octos = update_octos(octos, [])
    {{:flashes, f}, {:octos, o}} = flash_octos(octos)
    #IO.puts("Step #{n}")
    sim_flashes({:flashes, nf+f}, {:octos, o}, n-1)
  end

  def flash_octos(octos) do
    flash_octos(octos, [], 0)
  end
  def flash_octos([], prev, n) do
    #IO.puts("flash done")
    {{:flashes, n}, {:octos, Enum.reverse(prev)}}
  end
  def flash_octos([h|next], prev, n) do
    #IO.puts("flash octos, flashes: #{n}, line: #{h}")
    #IO.inspect([h|t])
    case flash_line(h, [], 0, next, prev) do
      {:continue, octos} ->
        flash_octos(octos, [], n+1)
      {:done, h, next, prev} ->
        flash_octos(next, [h|prev], n)
    end
  end

  def flash_line([], acc, _, next, prev), do: {:done, Enum.reverse(acc), next, prev}
  def flash_line([h|line], acc, col, [hn|next_lines], []) do
    if h > ?9 do
      row = flash(col, append(acc, [?0|line]), [])
      hn = flash(col, hn, [])
      octos = [row,hn|next_lines]
      {:continue, octos}
    else
      flash_line(line, [h|acc], col+1, [hn|next_lines], [])
    end
  end
  def flash_line([h|line], acc, col, [], [hp|prev_lines]) do
    if h > ?9 do
      row = flash(col, append(acc, [?0|line]), [])
      hp = flash(col, hp, [])
      octos = append(prev_lines, [hp,row])
      {:continue, octos}
    else
      flash_line(line, [h|acc], col+1, [], [hp|prev_lines])
    end
  end
  def flash_line([h|line], acc, col, [hn|next_lines], [hp|prev_lines]) do
    if h > ?9 do
      row = flash(col, append(acc, [?0|line]), [])
      hp = flash(col, hp, [])
      hn = flash(col, hn, [])
      octos = append(prev_lines, [hp,row,hn|next_lines])
      {:continue, octos}
    else
      flash_line(line, [h|acc], col+1, [hn|next_lines], [hp|prev_lines])
    end
  end

  def flash(_, [], acc) do
    Enum.reverse(acc)
  end
  def flash(-1, [h|t], acc) do
    if h > ?0 do
      append(acc, [h+1|t])
    else
      append(acc, [h|t])
    end
  end
  def flash(0, [h|t], acc) do
    if h > ?0 do
      flash(-1, t, [h+1|acc])
    else
      flash(-1, t, [h|acc])
    end
  end
  def flash(1, [h|t], acc) do
    if h > ?0 do
      flash(0, t, [h+1|acc])
    else
      flash(0, t, [h|acc])
    end
  end
  def flash(col, [h|t], acc) do
    flash(col-1, t, [h|acc])
  end

  def update_octos([], acc), do: Enum.reverse(acc)
  def update_octos([h|t], acc) do
    update_octos(t, [upd_line(h, [])|acc])
  end
  def upd_line([], acc), do: Enum.reverse(acc)
  def upd_line([h|t], acc) do
    upd_line(t, [h+1|acc])
  end

    # quick append, reverses first parameter
    def append([], x), do: x
    def append([h|t], x), do: append(t, [h|x])

end
defmodule Input do
  @demo """
  5483143223
  2745854711
  5264556173
  6141336146
  6357385478
  4167524645
  2176841721
  6882881134
  4846848554
  5283751526
  """

  @input """
  5665114554
  4882665427
  6185582113
  7762852744
  7255621841
  8842753123
  8225372176
  7212865827
  7758751157
  1828544563
  """
  def input, do: @input
  def demo, do: @demo
end
