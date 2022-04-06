defmodule Calc do

  def control do
    input = """
    23,-10  25,-9   27,-5   29,-6   22,-6   21,-7   9,0     27,-7   24,-5
    25,-7   26,-6   25,-5   6,8     11,-2   20,-5   29,-10  6,3     28,-7
    8,0     30,-6   29,-8   20,-10  6,7     6,4     6,1     14,-4   21,-6
    26,-10  7,-1    7,7     8,-1    21,-9   6,2     20,-7   30,-10  14,-3
    20,-8   13,-2   7,3     28,-8   29,-9   15,-3   22,-5   26,-8   25,-8
    25,-6   15,-4   9,-2    15,-2   12,-2   28,-9   12,-3   24,-6   23,-7
    25,-10  7,8     11,-3   26,-7   7,1     23,-9   6,0     22,-10  27,-6
    8,1     22,-8   13,-4   7,6     28,-6   11,-4   12,-4   26,-9   7,4
    24,-10  23,-8   30,-8   7,0     9,-1    10,-1   26,-5   22,-9   6,5
    7,5     23,-6   28,-10  10,-2   11,-1   20,-9   14,-2   29,-7   13,-3
    23,-5   24,-8   27,-9   30,-7   28,-5   21,-10  7,9     6,6     21,-5
    27,-10  7,2     30,-9   21,-8   22,-7   24,-9   20,-6   6,9     29,-5
    8,-2    27,-8   30,-5   24,-7
    """
    correct =
      String.split(input, ["\n", " "], trim: true)
      |> Enum.map(fn(x) ->
        String.split(x, ",") |> Enum.map(fn(e) -> String.to_integer(e) end)
        |> List.to_tuple()
      end)

    table = start()

    missing(correct, table, []) |> IO.inspect()



  end

  def missing([],_,acc), do: acc
  def missing([h|t], table, acc) do
    if Enum.member?(table, h) do
      missing(t, table, acc)
    else
      missing(t, table, [h|acc])
    end
  end

  def start() do
    target = Shot.target
    x1 = min_x(target)
    max = max_y(target) # This is part 1
    y2 = get_y(max)
    [target: {{_,x2},{y1,_}}] = target

    interval = {{x1,y1},{x2,y2}}
    |> IO.inspect()
    table = []

    table = find_all_probes({x1,y1}, interval, target, table)

    # Total amount of solutions, Part 2
    Enum.count(table)|> IO.puts()
    # IO.inspect(table)
  end

  def find_all_probes(last, {_, last}, target, table) do
    #check last
    IO.puts("check last")
    IO.inspect(last)
    table =
      if Shot.run([{:aim, last}, {:coords, {0,0}}], target) do
        [last|table]
      else
        table
      end
    #return table
    Enum.reverse(table)
  end

  def find_all_probes({x,y}, {{x1,_}, {x,_}} = interval, target, table) do
    coords = {:coords, {0,0}}
    #check {x,y}
    IO.puts("check {#{x},#{y}}")
    table =
      if Shot.run([{:aim, {x,y}}, coords], target) do
        [{x,y}|table]
      else
        table
      end
    find_all_probes({x1,y+1}, interval, target, table)
  end

  def find_all_probes({x,y}, interval, target, table) do
    coords = {:coords, {0,0}}
    #check {x,y}
    IO.puts("check {#{x},#{y}}")
    table =
      if Shot.run([{:aim, {x,y}}, coords], target) do
        [{x,y}|table]
      else
        table
      end
    #find_all_probes({x+1,y})
    find_all_probes({x+1,y}, interval, target, table)
  end

  def max_y([target: {_, {y,_}}]) do
    acc = 0-y
    IO.puts(acc)
    max_y(y,0, acc)
  end
  def max_y(y,acc,0), do: acc + y
  def max_y(y,acc,n) do
    acc = acc+n
    max_y(y,acc,n-1)
  end
  def get_y(0,n), do: n-1
  def get_y(max, n) do
    get_y(max-n, n+1)
  end
  def get_y(max) do
    get_y(max, 0)
  end

  def min_x([target: {{x,_}, _}]) do
    min_x(x,0)
  end
  def min_x(x,n) when x < 0 do
    n-1
  end
  def min_x(x,n) do
    min_x(x-n, n+1)
  end

end

defmodule Shot do

  @demo "target area: x=20..30, y=-10..-5"
  @input "target area: x=269..292, y=-68..-44"

  def target do
    [x,y] =
      String.split(@input, " ", trim: true)
      |> Enum.drop(2) |> Enum.map(fn(x) ->
        String.split(x, ["=", "..", ","], trim: true)
        |> Enum.drop(1) |> Enum.map(fn(x) ->
          String.to_integer(x)
        end)
        |> List.to_tuple()
      end)

      [target: {x, y}]
  end

  def run(probe, target) do
    [_, coords_prev] = probe
    [velocity, coords] = step(probe)
    case hit(coords, target) do
      [x: :less, y: :greater] ->
        run([velocity, coords], target)

      [x: :inside, y: :inside] ->
        IO.puts("hit")
        :true # hit

      [x: :inside, y: :greater] ->
        run([velocity, coords], target)

      [x: _, y: :less] ->
        if decrease_height?(coords_prev, coords) do
          IO.puts("miss")
          :false # miss
        else
          run([velocity, coords], target)
        end

      [x: :less, y: _] ->
        if halt?(coords_prev, coords) do
          IO.puts("miss")
          :false # miss
        else
          run([velocity, coords], target)
        end
        _ ->
          :false
    end
  end


  def halt?({:coords, {x_prev,_}}, {:coords, {x,_}}) do
    x_prev == 0 and x == 0
  end

  def decrease_height?({:coords, {_,y_prev}}, {:coords, {_,y}}) do
    y < y_prev
  end

  # simulate one step
  def step(probe) do
    [velocity, coords] = update_coords(probe)
    velocity = update_velocity(velocity)
    [velocity, coords]
  end

  # return true if hit, miss if passed, continue if before or over
  def hit({:coords, {cx,cy}}, [target: {{x_min, x_max}, {y_min, y_max}}]) do
    x_status = check_coord(x_max >= cx, x_min <= cx) # change to x_max < cx ...
    y_status = check_coord(y_max >= cy, y_min <= cy) # - || -
    [x: x_status, y: y_status]
    # |> IO.inspect()
  end

  def check_coord(true, true), do: :inside
  def check_coord(true, false), do: :less
  def check_coord(false, true), do: :greater

  # update coordinates
  def update_coords([aim: {vx,vy}, coords: {cx,cy}]) do
    [aim: {vx,vy}, coords: {cx+vx,cy+vy}]
  end

  # update velocity/aim
  def update_velocity({:aim, {vx, vy}}) when vx > 0 do
    {:aim, {vx-1, vy-1}}
  end
  def update_velocity({:aim, {vx, vy}}) when vx < 0 do
    {:aim, {vx+1, vy-1}}
  end
  def update_velocity({:aim, {0, vy}}) do
    {:aim, {0, vy-1}}
  end

end
defmodule Shot2 do

  @demo "target area: x=20..30, y=-10..-5"
  @input "target area: x=269..292, y=-68..-44"

  def demo do
    [x,y] =
      String.split(@input, " ", trim: true)
      |> Enum.drop(2) |> Enum.map(fn(x) ->
        String.split(x, ["=", "..", ","], trim: true)
        |> Enum.drop(1) |> Enum.map(fn(x) ->
          String.to_integer(x)
        end)
        |> List.to_tuple()
      end)

      target = {:target, x, y}
      |> IO.inspect()
      #probe = [aim: {30,-5}, coords: {0,0}]
      #run(probe, target)

      {:stop, aim} = start(target)
      IO.inspect({:stop, aim})
      max_height(aim) |> IO.puts()

      #max_height({:aim, {6,9}})
  end

  def max_height({:aim, {x,y}}) do
    max_height({:aim, {x,y}}, y)
  end
  def max_height(aim, max) do
    {:aim, {x,y}} = update_velocity(aim)
    if y > 0 do
      max_height({:aim, {x,y}}, max + y)
    else
      max
    end
  end

  # calc start velocity
  # 1. decrease velocity until miss
  # 2. increase height aim until hit
  # 3. store velocity
  # 4. increase velocity until miss
  # 5. return to 2.

  def start(target) do
    probe = get_start(target)
    fun = fn(aim) -> update_aim(:velocity, aim, -1) end
    find_next(probe, target, fun, nil)
  end

  def find_next([{:aim, {0,_}},coords],target,_,aim) do
    IO.puts("iterate")
    probe = [aim, coords]
    fun = fn(x) -> update_aim(:velocity, x, -1) end
    find_next(probe, target, fun, aim)
  end

  def find_next(probe, target, fun, n) do
    IO.puts("find next with probe:")
    [aim, coords] = probe
    aim = fun.(aim)
    probe = [aim, coords]
    IO.inspect(probe)

    # less & less or greater & _ or inside & less
    case run(probe, target, :greater) do
      true ->
        IO.inspect({:hit, aim})
        fun = fn(aim) -> update_aim(:height, aim, 1) end
        find_next(probe, target, fun, aim)

      {false, [x: :less, y: :less]} ->
        IO.inspect({:miss, aim})
        fun = fn(aim) -> update_aim(:velocity, aim, 1) end
        find_next(probe, target, fun, n)

      {false, [x: :greater, y: _]} ->
        IO.inspect({:miss, aim})
        fun = fn(aim) -> update_aim(:velocity, aim, -1) end
        find_next(probe, target, fun, n)

      {false, [x: :inside, y: :less]} ->
        IO.inspect({:miss, aim})
        fun = fn(aim) -> update_aim(:height, aim, 1) end
        find_next(probe, target, fun, n)

      {:stop, [x: :less, y: _]} ->
        {:stop, n}

      {:stop, _} ->
        IO.inspect({:miss, aim})
        fun = fn(aim) -> update_aim(:velocity, aim, -1) end
        find_next(probe, target, fun, n)

    end
  end

  def update_aim(:height, {:aim, {x,y}}, n) do
    {:aim, {x,y+n}}
  end
  def update_aim(:velocity, {:aim, {x,y}}, n) do
    {:aim, {x+n,y}}
  end

  def get_start({:target, {_,x}, {_,y}}) do
    [aim: {x,y}, coords: {0,0}]
  end

  def run(probe, target, prev_y) do
    [velocity, coords] = step(probe)
    case hit(coords, target) do
      [x: :less, y: :greater] ->
        run([velocity, coords], target, :greater)

      [x: :inside, y: :inside] ->
        :true

      [x: :inside, y: :greater] ->
        run([velocity, coords], target, :greater)

      [x: _, y: :less] = result ->
        if prev_y == :greater do
          {:stop, result}
        else
          {:false, result} # less & less or greater & _ or inside & less
        end

      result ->
        {:false, result} # less & less or greater & _ or inside & less

    end
  end

  # simulate one step
  def step(probe) do
    [velocity, coords] = update_coords(probe)
    velocity = update_velocity(velocity)
    [velocity, coords]
  end

  # return true if hit, miss if passed, continue if before or over
  def hit({:coords, {cx,cy}}, {:target, {x_min, x_max}, {y_min, y_max}}) do
    x_status = check_coord(x_max >= cx, x_min <= cx) # change to x_max < cx ...
    y_status = check_coord(y_max >= cy, y_min <= cy) # - || -
    [x: x_status, y: y_status]
    |> IO.inspect()
  end

  def check_coord(true, true), do: :inside
  def check_coord(true, false), do: :less
  def check_coord(false, true), do: :greater

  # update coordinates
  def update_coords([aim: {vx,vy}, coords: {cx,cy}]) do
    [aim: {vx,vy}, coords: {cx+vx,cy+vy}]
  end

  # update velocity/aim
  def update_velocity({:aim, {vx, vy}}) when vx > 0 do
    {:aim, {vx-1, vy-1}}
  end
  def update_velocity({:aim, {vx, vy}}) when vx < 0 do
    {:aim, {vx+1, vy-1}}
  end
  def update_velocity({:aim, {0, vy}}) do
    {:aim, {0, vy-1}}
  end

end
