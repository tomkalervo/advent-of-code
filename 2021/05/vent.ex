defmodule Vent do
  def start(file) do
    input = File.stream!(file, [:read], :line)
    |> Stream.map(fn(x) ->
      String.replace_suffix(x, "\n", "")
      |> String.split(" -> ")
      |> Enum.map(fn(pair) ->
        String.split(pair, ",")
        |> Enum.map(fn(value) ->
          String.to_integer(value)
        end)
        |> List.to_tuple()
      end)
    end)
    |> Enum.to_list()


    find_vents(input, %{})
    |> Map.values()
    |> List.foldl(0,fn(x,acc) ->
      if x > 1 do acc + 1 else acc end
    end)
  end

  def find_vents([], map), do: map
  def find_vents([[pos1,pos2]|vents], map) do
    case find_straight(pos1, pos2, map) do
      {:true, map} ->
        find_vents(vents, map)
      :false ->
        map = find_diagonal(pos1,pos2,map)
        find_vents(vents, map)
    end
  end

  # PART 2
  def find_diagonal({x1,y1}, {x2,y2}, map) do
    if x1 < x2 do
      update_diagonal({x1,y1}, {x2-x1,y2-y1}, map)
    else
      update_diagonal({x2,y2}, {x1-x2,y1-y2}, map)
    end
  end

  def update_diagonal({x,y},{0,_},map) do
    update_map(map, {x, y})
  end
  def update_diagonal({x,y}, {xn,yn}, map) when xn > 0 do
    map = update_map(map, {x+xn,y+yn})
    if yn < 0 do
      update_diagonal({x,y}, {xn-1,yn+1}, map)
    else
      update_diagonal({x,y}, {xn-1,yn-1}, map)
    end
  end

  # PART 1
  def find_straight({x1,y1} = pos, {x2,y2}, map) do
    case x1 == x2 do
      true ->
        {:true, update_straight(:x, pos, y1 - y2, map)}
      false ->
        case y1 == y2 do
          true ->
            {:true, update_straight(:y, pos, x1 - x2, map)}
          false ->
            :false
        end
    end
  end

  def update_straight(_, {x,y}, 0, map) do
    update_map(map, {x,y})
  end
  def update_straight(:x, {x,y}, n, map) when n < 0 do
    update_straight(:x, {x,y-n}, 0-n, map)
  end
  def update_straight(:y, {x,y}, n, map) when n < 0 do
    update_straight(:y, {x-n,y}, 0-n, map)
  end
  def update_straight(:x, {x,y}, n, map) do
      map = update_map(map, {x,y-n})
      update_straight(:x, {x,y}, n-1, map)
  end
  def update_straight(:y, {x,y}, n, map) do
    map = update_map(map, {x-n,y})
    update_straight(:y, {x,y}, n-1, map)
  end

  def update_map(map, pos) do
    if Map.has_key?(map, pos) do
      Map.update!(map, pos, &(&1+1))
    else
      Map.put(map, pos, 1)
    end
  end

end
