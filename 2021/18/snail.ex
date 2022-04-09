defmodule Snail do

  @test_code_0 """
  [10,10]
  [10,10]
  """

  @test_code_1 """
  [[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
  [7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
  [[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
  [[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
  [7,[5,[[3,8],[1,4]]]]
  [[2,[2,2]],[8,[8,1]]]
  [2,9]
  [1,[[[9,3],9],[[9,0],[0,7]]]]
  [[[5,[7,4]],7],1]
  [[[[4,2],2],6],[8,7]]
  """

  @demo """
  [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
  [[[5,[2,8]],4],[5,[[9,9],0]]]
  [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
  [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
  [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
  [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
  [[[[5,4],[7,7]],8],[[8,3],8]]
  [[9,3],[[9,9],[6,[4,9]]]]
  [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
  [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
  """
  # for testing
  def demo do
    test_exp1 = [[[[[9,8],1],2],3],4]
    test_exp2 = [[6,[5,[4,[3,2]]]],1]
    test_exp3 = [[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]
    test_split1 = [[[[0,7],4],[15,[0,13]]],[1,1]]
    test_op_a_1 = [[[[4,3],4],4],[7,[[8,4],9]]]
    test_op_b_1 = [1,1]
    test_op_2 = """
              [1,1]
              [2,2]
              [3,3]
              [4,4]
              """
    test_op_3 = """
              [1,1]
              [2,2]
              [3,3]
              [4,4]
              [5,5]
              """
    test_op_4 = """
              [1,1]
              [2,2]
              [3,3]
              [4,4]
              [5,5]
              [6,6]
              """
    test_big = [[0,[20,0]],[0,0]]
    # Results
    # Split     [[0,[[10,10],0]],[0,0]]


    test_big_2 = [[0,[0,20]],[10,0]]
    # Split     [[0,[0,[10,10]]],[[10,0],0]]
    # Split     [[0,[0,[[5,5],10]]],[[10,0],0]]
    # explosion [[0,[5,[0,15]]],[[10,0],0]]
    # split     [[0,[5,[0,[7,8]]]],[[10,0],0]]
    # explosion [[0,[5,[7,0]]],[[18,0],0]]
    # split     [[0,[5,[7,0]]],[[[9,9],0],0]]

    # TESTS
    #IO.puts("test 1 exp")
    #Operation.explosion(test_exp1) |> IO.inspect()
    #IO.puts("test 2 exp")
    #Operation.explosion(test_exp2) |> IO.inspect()
    #IO.puts("test 3 exp")
    #Operation.explosion(test_exp3) |> IO.inspect()
    #IO.puts("test 1 split")
    #Operation.splits(test_split1) |> IO.inspect()
    #IO.puts("test 1 calc")
    #calc(test_op_a_1, test_op_b_1) |> IO.inspect()
    #IO.puts("test 1 list to string")
    #test = string_to_list(test_op_2) |> IO.inspect()
    #IO.puts("test 2 list op")
    #list(test) |> IO.inspect()
    #IO.puts("test 3 list op")
    #string_to_list(test_op_3) |> list() |> IO.inspect()
    #IO.puts("test 4 list op")
    #string_to_list(test_op_4) |> list() |> IO.inspect()
    #IO.puts("********* test big numbers **********************")
    #list(test_big_2) |> IO.inspect()

    #IO.puts("********* test code 1 STRING **********************")
    #string_to_list(@test_code_1) |> list() |> Operation.magnitude()

    #IO.puts("********* test demo **********************")
    #string_to_list(@demo) |> list() |> Operation.magnitude()

    #IO.puts("********* Part 2 demo **********")
    #string_to_list(@demo) |> combo()

  end

  def start do
    #Part 1
    #string_to_list(Input.input) |> list() |> Operation.magnitude()

    #Part 2
    string_to_list(Input.input) |> combo()

  end

  # finds the two rows of numbers that results in the largest magnitude
  def combo(list) do
    combo(list,[],0)
  end
  def combo([_], [], val), do: val
  def combo([_], acc, val) do
    combo(acc,[],val)
  end
  def combo([h1,h2|t],acc, val) do
    val1 = calc(h1,h2) |> Operation.magnitude()
    val2 = calc(h2,h1) |> Operation.magnitude()
    combo([h1|t], [h2|acc], max(val,max(val1,val2)))
  end

  def string_to_list(str) do
    String.split(str, "\n", trim: true)
    |> Enum.map(fn(x) ->
      {list,_} =
        find_list(String.to_charlist(x))
      list
    end)
  end

  # takes a charlist of nested lists and transform into a list
  def find_list([?[|t]) do
    {left, [_|t]} = get_left(t)
    {right, t} = get_right(t)
    {[left,right], t}
  end
  def get_left([h|t]) do
    case h do
      ?[ ->
        find_list([h|t])
      char ->
        {char - 48, t}
    end
  end
  def get_right([h|t]) do
    case h do
      ?[ ->
        find_list([h|t])
      ?, ->
        get_right(t)
      ?] ->
        get_right(t)
      char ->
        {char - 48, t}
    end
  end

  def list([h1,h2|t]) do
    h = calc(h1,h2)
    list(t, h)
  end
  def list([], ns) do
    ns
  end
  def list([h|t], acc) do
    list(t, calc(acc,h))
  end


  def calc(n1,n2) do
    ns = Operation.addition(n1,n2)
    loop(ns)
  end

  def loop(ns) do
    new = Operation.explosion(ns)
    case Operation.splits(new) do
      {:yes, new} ->
        loop(new)
      :no ->
        new
    end
  end

end

defmodule Operation do

  def magnitude([h1,h2]) do
    3*magnitude(h1)+2*magnitude(h2)
  end
  def magnitude(h) when is_integer(h) do
    h
  end

  def addition(n1, n2) do
    [n1,n2]
  end

  def splits(h) when is_integer(h) do
    if h > 9 do
      #IO.puts("Splitting h: #{h}")
      val = div(h,2)
      {:yes, [val, h-val]}
    else
      :no
    end
  end
  def splits([h1,h2]) do
    case splits(h1) do
      {:yes, h} ->
        {:yes, [h,h2]}
      :no ->
        case splits(h2) do
          {:yes, h} ->
            {:yes, [h1,h]}
          :no ->
            :no
        end
    end
  end

  def explosion(ns) do
    {_, ns} = explosion(ns,0)
    ns
  end

  def explosion([l,r], i) when i > 3 do
      {[sum(l),sum(r)], 0}
  end
  # check h1, check h2 - combine results
  def explosion([h1,h2], i) do
  {[l1,r1], h1} =
    explosion(h1, i+1)
  {[l2,r2], h2} =
    explosion(add_first(h2, r1), i+1)
  {[l1,r2], [add_last(h1,l2), h2]}
  end
  # no explosion
  def explosion(h,_) do
    #IO.puts("no explosion")
    {[0,0], h}
  end

  def sum([]), do: 0
  def sum([h|t]) do
    sum(h) + sum(t)
  end
  def sum(n), do: n

  def add_first([],_), do: []
  def add_first(e, 0), do: e
  def add_first([h|t], n) do
    [add_first(h, n)|t]
  end
  def add_first(h, n), do: h+n

  def add_last([],_), do: []
  def add_last(e,0), do: e
  def add_last([n1,n2], n) do
    if is_integer(n2) do
      [n1, n2+n]
    else
      [n1,add_last(n2, n)]
    end
  end
  def add_last([ns], n) do
    [add_last(ns, n)]
  end
  def add_last(ns, n), do: ns+n

  # quick append, reverses first parameter
  def append([], x), do: x
  def append([h|t], x), do: append(t, [h|x])

end
defmodule Input do
  @input """
  [[6,[[9,4],[5,5]]],[[[0,7],[7,8]],[7,0]]]
  [[[[2,1],[8,6]],[2,[4,0]]],[9,[4,[0,6]]]]
  [[[[4,2],[7,7]],4],[3,5]]
  [8,[3,[[2,3],5]]]
  [[[[0,0],[4,7]],[[5,5],[8,5]]],[8,0]]
  [[[[5,2],[5,7]],[1,[5,3]]],[[4,[8,4]],2]]
  [[5,[[2,8],[9,3]]],[[7,[5,2]],[[9,0],[5,2]]]]
  [[9,[[4,3],1]],[[[9,0],[5,8]],[[2,6],1]]]
  [[0,6],[6,[[6,4],[7,0]]]]
  [[[9,[4,2]],[[6,0],[8,9]]],[[0,4],[3,[6,8]]]]
  [[[[3,2],0],[[9,6],[3,1]]],[[[3,6],[7,6]],[2,[6,4]]]]
  [5,[[[1,6],[7,8]],[[6,1],[3,0]]]]
  [2,[[6,[7,6]],[[8,6],3]]]
  [[[[0,9],1],[2,3]],[[[7,9],1],7]]
  [[[[1,8],3],[[8,8],[0,8]]],[[2,1],[8,0]]]
  [[2,9],[[5,1],[[9,3],[4,0]]]]
  [9,[8,4]]
  [[[3,3],[[6,2],8]],5]
  [[[9,[4,8]],[[1,3],[6,7]]],[9,[[4,4],2]]]
  [[[[1,3],6],[[5,6],[1,9]]],[9,[[0,2],9]]]
  [7,[[[0,6],[1,2]],4]]
  [[[[5,0],[8,7]],[[7,3],0]],[[6,7],[0,1]]]
  [[[[5,4],7],[[8,2],1]],[[[7,0],[6,9]],0]]
  [[[3,[5,6]],[[9,5],4]],[[[9,4],[8,1]],[5,[7,4]]]]
  [[[3,[7,5]],[[8,1],8]],[[[6,3],[9,2]],[[5,7],7]]]
  [8,[[2,0],[[2,6],8]]]
  [[[[5,8],9],1],[9,6]]
  [[[9,9],[8,8]],[[[3,5],[8,0]],[[4,6],[3,2]]]]
  [[5,[[5,1],6]],[[5,8],9]]
  [[7,[[1,6],6]],[[[8,6],7],[6,6]]]
  [[0,[[9,5],0]],[4,[[7,9],[4,9]]]]
  [[[[4,3],[3,5]],[[1,9],[7,6]]],[3,[[6,4],[6,0]]]]
  [[[2,6],6],[6,3]]
  [[[[1,5],[3,7]],0],[3,7]]
  [4,[[[5,5],4],[[5,5],[9,3]]]]
  [[3,[8,6]],[8,[7,7]]]
  [8,[9,5]]
  [[[6,3],[2,[3,6]]],[[[6,0],[0,2]],[[8,7],5]]]
  [[[8,[1,2]],2],7]
  [[[[8,4],[2,7]],[[3,9],7]],[[4,[8,8]],[[7,4],9]]]
  [[[8,[2,5]],[3,[1,2]]],[[4,[5,0]],3]]
  [[8,[0,3]],[[5,1],[1,1]]]
  [[[8,[3,6]],6],[[7,[1,5]],[[4,8],9]]]
  [[[5,0],[0,3]],[[2,[7,8]],[1,[4,8]]]]
  [9,[4,[9,4]]]
  [[[9,[0,4]],2],3]
  [[9,[7,[8,9]]],3]
  [[[8,6],[[3,5],[9,2]]],[[3,[9,7]],5]]
  [[6,[[7,4],2]],[2,[7,[6,0]]]]
  [1,[[[2,2],6],8]]
  [[[6,[1,8]],[[9,3],[1,8]]],[[[8,2],[9,3]],[[8,2],[9,9]]]]
  [[[[2,9],[1,7]],[[4,0],8]],[[8,9],[6,3]]]
  [[[[2,4],[6,1]],[[5,4],[2,8]]],[8,[1,[2,4]]]]
  [[[4,6],[1,6]],[3,[1,1]]]
  [[[[8,3],8],8],[1,[[4,2],3]]]
  [[[9,[8,7]],[5,9]],[8,[[5,6],[4,5]]]]
  [[[[4,1],2],[[7,8],4]],[0,6]]
  [[[9,7],[[8,6],[6,9]]],[[8,[8,4]],[[9,0],2]]]
  [[[8,5],[1,9]],[[[2,4],5],6]]
  [[[9,[9,3]],[9,[2,3]]],[7,7]]
  [[[8,[7,4]],[2,6]],[[[4,5],[9,9]],[0,[5,2]]]]
  [7,[2,2]]
  [[[[1,8],[5,2]],3],[0,[2,[4,5]]]]
  [[5,[[4,8],[5,5]]],[4,[[3,4],[6,0]]]]
  [[3,1],[4,[3,[8,2]]]]
  [[3,7],[3,[[6,1],[0,2]]]]
  [[4,[6,2]],[[3,9],8]]
  [[[[2,9],3],[[5,6],4]],[8,2]]
  [[4,[[7,9],[4,9]]],[[4,3],[7,[0,7]]]]
  [[[3,[8,9]],[[3,4],[9,5]]],3]
  [0,[[[3,0],[8,7]],[[0,9],[9,1]]]]
  [[[5,[9,9]],2],[4,8]]
  [[[[4,4],4],5],[3,4]]
  [[[3,[2,2]],7],[[3,2],0]]
  [[[[0,5],[5,2]],2],[2,[[1,2],2]]]
  [[[4,6],6],[[0,1],6]]
  [2,[[[3,9],7],[[9,8],8]]]
  [[7,9],[7,[[3,0],9]]]
  [[[1,[6,2]],[0,8]],[[[7,2],4],9]]
  [[[[4,7],[1,5]],[5,9]],[[2,[0,4]],[7,[7,0]]]]
  [[1,[[2,0],[0,4]]],[[[4,6],9],[[6,8],[0,1]]]]
  [[[[6,0],7],[7,[9,6]]],[[7,[4,9]],[9,4]]]
  [[[5,[4,6]],[[1,9],[5,8]]],[[[3,6],[2,6]],[[7,3],7]]]
  [[[6,0],[6,6]],[2,8]]
  [[[4,[7,2]],[[5,6],[2,4]]],[[[6,8],5],[4,6]]]
  [[[[9,0],9],[4,0]],[[[9,1],8],[6,4]]]
  [[6,3],[1,[[5,0],[9,9]]]]
  [[[2,7],[5,6]],[[6,[1,4]],[9,9]]]
  [[[[0,5],3],[8,7]],[[[9,9],[6,2]],[0,7]]]
  [[[5,6],[1,7]],[[[0,4],9],9]]
  [[[7,3],3],[6,[0,[8,9]]]]
  [[[0,6],[[8,5],[4,6]]],[[[2,7],[4,2]],[[8,7],[0,5]]]]
  [[[8,[7,3]],1],8]
  [[8,[8,[8,2]]],[[5,4],[1,[2,6]]]]
  [[[[1,1],[8,6]],5],9]
  [[[[2,4],[5,7]],[[5,8],[3,1]]],7]
  [[4,[[0,1],9]],[[3,8],[4,2]]]
  [3,2]
  [[3,4],[8,[[6,5],[6,6]]]]
  [[[[7,0],[3,8]],[[3,3],[2,6]]],[[8,0],9]]
  """
  def input, do: @input
end
