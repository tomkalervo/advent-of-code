defmodule Smoke do
  @demo """
        2199943210
        3987894921
        9856789892
        8767896789
        9899965678
        """

  def start() do
    table = String.split(Input.data(), "\n", trim: true)
    # table = String.split(@demo, "\n", trim: true)
    |> Enum.map(fn(x) ->
      String.to_charlist(x)
      |> Enum.chunk_every(1)
    end)

    # PART 2
    IO.puts("Part2")
    find_lowpoints(table, table, 0, [])
    |> List.flatten()
    |> find_basins(table)
    |> get_sizes([])
    |> Enum.take(3)
    |> List.foldl(1, fn(x, acc) ->
      acc * x
    end)
    |> IO.puts()

    # PART 1
    IO.puts("\nPart1")
    find_lowpoints(table, table, 0, [])
    |> List.flatten()
    |> List.foldl(0, fn({[x],_,_}, acc) ->
      x - 47 + acc
      end)
    |> IO.puts()
  end

  def get_sizes([], sizes), do: sizes
  def get_sizes([b|basins], sizes) do
    sizes = in_sort(basin_size(b), sizes)
    get_sizes(basins, sizes)
  end
  def basin_size({:basin, basin}) do
    List.foldl(basin, 0, fn(row, acc) ->
      List.foldl(row, acc, fn(point, acc) ->
        if point == :ba do
          acc + 1
        else
          acc
        end
      end)
    end)
  end

  def find_basins(lowpoints, table) do
    Enum.map(lowpoints, fn({_, row, index}) ->
      {:basin, basin(row, index, table)}
    end)
  end

  # divide-n-concquer
  def basin(row, index, [h|_] = table) do
    check = basin_cols(row, length(table), index, length(h), table, [])
    case check do
      {:ok, table} ->
        table = basin(row, index-1, table)
        table = basin(row, index+1, table)
        table = basin(row-1, index, table)
        basin(row+1, index, table)
      :no ->
          table
    end
  end

  def basin_cols(row_len, row_len, _, _, _, _), do: :no
  def basin_cols(_, _, _, _, [], _), do: :no
  def basin_cols(_, _, index_len, index_len, _, _), do: :no
  def basin_cols(_, _, -1, _, _, _), do: :no
  def basin_cols(0,_,index,_,[h|table], stack) do
    case basin_row(index, h, []) do
      {:ok, h} ->
        {:ok, append(stack, [h|table])}
      :no ->
        :no
    end
  end
  def basin_cols(row, row_len, index, index_len, [h|table], stack) do
    basin_cols(row-1, row_len, index, index_len, table, [h|stack])
  end
  def basin_row(0, [h|t], stack) do
    case h do
      '9' ->
        :no
      :ba ->
        :no
      _ -> {:ok, append(stack, [:ba|t])}
    end
  end
  def basin_row(index, [h|t], stack) do
    basin_row(index-1, t, [h|stack])
  end

  def find_lowpoints([],_,_,lowpoints), do: lowpoints
  def find_lowpoints([line|rest], table, n, lowpoints) do
    case check_line(line, table, n, 0, []) do
      [] ->
        find_lowpoints(rest, table, n+1, lowpoints)
      points ->
        find_lowpoints(rest, table, n+1, [points|lowpoints])
    end

  end

  def check_line([h1,h2|t], table, n, 0, points) do
    if h1 < h2 do
      case check_vertical(h1,n,0,table) do
        {:ok, point} ->
          check_line([h1,h2|t], table, n, 1, [point|points])
        :no ->
          check_line([h1,h2|t], table, n, 1, points)
      end
    else
      check_line([h1,h2|t], table, n, 1, points)
    end
  end

  def check_line([h1,h2], table, n, l, points) do
    if h2 < h1 do
      #IO.write("Checking end point #{h2} from line #{n}\n")
      case check_vertical(h2,n,l,table) do
        {:ok, point} ->
          [point|points]
        :no ->
          points
      end
    else
      points
    end
  end
  def check_line([h1,h2,h3|t], table, n, l, points) do
    if h2 < h1 do
      if h2 < h3 do
        #IO.write("Checking #{h2} from line #{n}\n")
        case check_vertical(h2,n,l,table) do
          {:ok, point} ->
            check_line([h2,h3|t], table, n, l+1, [point|points])
          :no ->
            check_line([h2,h3|t], table, n, l+1, points)
        end
      else
        check_line([h2,h3|t], table, n, l+1, points)
      end
    else
      check_line([h2,h3|t], table, n, l+1, points)
    end
  end

  def check_vertical(value, n, l, table) do
    check_vertical(value, n, l, table, 1)
  end
  def check_vertical(value, 0, l, [_,bottom|_], 1) do
    if value < Enum.fetch!(bottom, l) do
      {:ok, {value, 0, l}}
    else
      :no
    end
  end
  def check_vertical(value, n, l, [top,_,bottom|_], n) do
    if value < Enum.fetch!(top, l) do
      if value < Enum.fetch!(bottom, l) do
        {:ok, {value, n, l}}
      else
        :no
      end
    else
      :no
    end
  end
  def check_vertical(value, n, l, [top,_], _p) do
    if value < Enum.fetch!(top, l) do
      {:ok, {value, n, l}}
    else
      :no
    end
  end
  def check_vertical(value, n, l, [_|rest], p) do
    check_vertical(value, n, l, rest, p+1)
  end

  # helper functions below

  # quick append, reverses first parameter
  def append([], x), do: x
  def append([h|t], x), do: append(t, [h|x])

  # insertion sort, descending order
  def in_sort(val, []), do: [val]
  def in_sort(val, [h|t]) do
    if val < h do
      [h|in_sort(val, t)]
    else
      [val,h|t]
    end
  end
end
