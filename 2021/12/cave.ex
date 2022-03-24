defmodule Cave do
  @small """
  start-A
  start-b
  A-c
  A-b
  b-d
  A-end
  b-end
  """
  @large """
  dc-end
  HN-start
  start-kj
  dc-start
  dc-HN
  LN-dc
  HN-end
  kj-sa
  kj-HN
  kj-dc
  """

  @larger """
  fs-end
  he-DX
  fs-he
  start-DX
  pj-DX
  end-zg
  zg-sl
  zg-pj
  pj-he
  RW-he
  fs-DX
  pj-RW
  zg-RW
  start-pj
  he-WI
  zg-he
  pj-fs
  start-RW
  """
  @input """
  EG-bj
  LN-end
  bj-LN
  yv-start
  iw-ch
  ch-LN
  EG-bn
  OF-iw
  LN-yv
  iw-TQ
  iw-start
  TQ-ch
  EG-end
  bj-OF
  OF-end
  TQ-start
  TQ-bj
  iw-LN
  EG-ch
  yv-iw
  KW-bj
  OF-ch
  bj-ch
  yv-TQ
  """

  def start() do
    edges = String.split(@input, "\n", trim: true)
    |> Enum.map(fn(nodes) ->
      String.split(nodes, "-", trim: true)
      |> List.to_tuple()
    end)
    |> IO.inspect()

    # PART 1
    small_caves = Enum.map(edges, fn(x) ->
      Tuple.to_list(x)
    end)
    |> List.flatten()
    |> Enum.filter(fn(elem) ->
      !String.contains?(elem, Enum.map((Enum.to_list(?A..?Z)), fn(x) ->
        List.to_string([x])
      end))
    end)
    |> List.foldl([], fn(x, acc) ->
      if member(x, acc) do
        acc
      else
        [x|acc]
      end
    end)
    |> Enum.sort()
    |> Enum.map(fn(x) ->
      if x == "start" do
        {x, :visited}
      else
        {x, :hidden}
      end
    end)
    |> IO.inspect()

    find_paths(edges, edges, "start", "end", [], [], small_caves)
    |> IO.inspect()
    |> Enum.count()
    |> IO.puts()

    # PART 2
    IO.puts("Part 2")
    smc = Enum.map(small_caves, fn({x, status}) ->
      {x, status, 0}
    end)
    smc = [{:twice, false}|smc]
    |> IO.inspect()
    find_paths(edges, edges, "start", "end", [], [], smc)
    |> IO.inspect()
    |> Enum.count()
    |> IO.puts()

  end

  def find_paths(_,_, to, to, path, paths, _) do
    [append(path, [to])|paths]
    #|> IO.inspect()
  end
  def find_paths(edges, [{from, c1}|t], from, to, path, paths, small_caves) do
    #IO.puts("from #{from} found cave #{c1}")
    case update_caves(c1, small_caves, []) do
      {:ok, smc} ->
        paths = find_paths(edges, edges, c1, to, [from|path], paths, smc)
        find_paths(edges, t, from, to, path, paths, small_caves)
      _ ->
        find_paths(edges, t, from, to, path, paths, small_caves)
    end
  end
  def find_paths(edges, [{c1, from}|t], from, to, path, paths, small_caves) do
    #IO.puts("from #{from} found cave #{c1}")
    case update_caves(c1, small_caves, []) do
      {:ok, smc} ->
        paths = find_paths(edges, edges, c1, to, [from|path], paths, smc)
        find_paths(edges, t, from, to, path, paths, small_caves)
      _ ->
        find_paths(edges, t, from, to, path, paths, small_caves)
    end
  end

  def find_paths(ed,[_|t],fr,to,path,paths,smc) do
    find_paths(ed,t,fr,to,path,paths,smc)
  end

  def find_paths(_,[],_,_,_,paths,_), do: paths

  # Part 2 handling small cave visit twice
  def update_caves(cave, [{:twice, bool}|smc], []) do
    up_cvs(cave, smc, {:twice, bool}, [])
  end

  # Part 1 handling
  def update_caves(_, [], stack), do: {:ok, Enum.reverse(stack)}
  def update_caves(cave, [{cave, status}|t], stack) do
    case status do
      :hidden ->
        {:ok, append(stack, [{cave, :visited}|t])}
      :visited ->
        :visited
    end
  end
  def update_caves(cave, [h|t], stack) do
    update_caves(cave, t, [h|stack])
  end

  def up_cvs(_, [], {:twice, bool}, stack) do
    {:ok, [{:twice, bool}|Enum.reverse(stack)]}
  end
  # Not the prettiest solution
  def up_cvs(cave, [{cave, status, n}|t], {:twice, bool}, stack) do
    case status do
      :hidden ->
        if bool do
          # bool == true
          if n < 1 do
            {:ok, [{:twice, bool}|append(stack, [{cave, :visited, n+1}|t])]}
          else
            :visited
          end
        else
          # bool == false
          if n < 1 do
            {:ok, [{:twice, bool}|append(stack, [{cave, :hidden, n+1}|t])]}
          else
            {:ok, [{:twice, true}|append(stack, [{cave, :visited, n+1}|t])]}
          end
        end
      :visited ->
        :visited
    end
  end
  def up_cvs(cave, [h|t], visit, stack) do
    up_cvs(cave, t, visit, [h|stack])
  end

  # quick append, reverses first parameter
  def append([], x), do: x
  def append([h|t], x), do: append(t, [h|x])

  def member(_, []), do: false
  def member(x, [x|_]), do: true
  def member(x, [_|t]) do
    member(x, t)
  end
end
