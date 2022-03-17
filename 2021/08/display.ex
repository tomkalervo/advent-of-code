defmodule Display do

  @table [{'abcefg', 0}, {'cf', 1}, {'acdeg', 2}, {'acdfg', 3},
          {'bcdf', 4}, {'abdfg', 5}, {'abdefg', 6}, {'acf', 7},
          {'abcdefg', 8}, {'abcdfg', 9}]

  def start() do
    # PART 1
    input = File.stream!("data.txt", [:read], :line)
    # |> unique_output()

    # PART 2 -
    # data structure
    str = [{:a, nil}, {:b, nil}, {:c, nil}, {:d, nil}, {:e, nil}, {:f, nil}, {:g, nil}]
    |> Enum.map(fn({x, _}) -> {x, String.to_charlist("abcdefg")} end)
    decode_stream(input, str)
  end

  def demo() do
    # PART 1
    input = File.stream!("demo.txt", [:read], :line)
    # |> unique_output()

    # PART 2 -
    # data structure
    str = [{:a, nil}, {:b, nil}, {:c, nil}, {:d, nil}, {:e, nil}, {:f, nil}, {:g, nil}]
    |> Enum.map(fn({x, _}) -> {x, String.to_charlist("abcdefg")} end)
    decode_stream(input, str)
  end

  # Sends each line through deduct_line and sums up all values
  def decode_stream(input, str) do
    Stream.map(input, fn(x) ->
      String.split(x, " | ")
    end)
    |> Stream.map(fn([patterns, output]) -> deduct_line(patterns, output, str) end)
    |> Enum.sum
  end

  # deducts the patterns at this line and decodes the output
  def deduct_line(patterns, output, str) do
    String.split(patterns)
    |> List.foldl({[],str}, fn(x, {p,str}) ->
      {[x|p],update(x, str)}
    end)
    |> deduct()
    |> decode_line(output)
  end

  # uses the str to decode the output and find its sum
  def decode_line(str, output) do
    String.split(output, "\n", trim: true)
    |> List.foldl([], fn(x,_) -> String.split(x," ", trim: true) end)
    |> Enum.map(fn(x) ->
      decode(String.to_charlist(x), str)
    end)
    |> Enum.map(fn(x) ->
      {_, x} = Enum.find(@table, -1, fn({key, _}) ->
        key == x
      end)
      x
    end)
    |> Enum.reverse()
    |> Enum.map_reduce(0, fn(x, n) -> {x * :math.pow(10,n), n+1} end)
    |> get_sum()
  end

  def get_sum({sum,_}) do
    Enum.sum(sum)
  end

  def decode(code, str) do
    Enum.map(code, fn(x) ->
      find(str, [x])
    end)
    |> List.foldl([], fn([x], acc) -> [x|acc] end)
    |> Enum.sort()
  end

  def find([{letter, x}|_], x), do: Atom.to_charlist(letter)
  def find([_|rest], x), do: find(rest, x)

  def deduct({patterns, str}) do
    deduct(patterns, str, [], [])
  end
  def deduct([],str,fives,sixes) do
    update_str(str, [:a,:d,:g], fives)
    |> update_str([:a,:b,:f,:g], sixes)
  end
  def deduct([p|p_rest], str, fives, sixes) do
    case String.length(p) do
      5 ->
        deduct(p_rest, str, common(String.to_charlist(p),fives), sixes)
      6 ->
        deduct(p_rest, str, fives, common(String.to_charlist(p),sixes))
      _ ->
        deduct(p_rest, str, fives, sixes)
    end
  end
  def common(pattern, list) do

    case list do
      [] ->
        pattern
      _ ->
        Enum.filter(list, fn(x) ->
          exists?(pattern, x)
        end)
    end
  end

  def valid([]), do: true
  def valid([{_,[]}|_]), do: false
  def valid([_|rest]), do: valid(rest)

  def update(pattern, str) do
    len = String.length(pattern)
    pattern = String.to_charlist(pattern)
    case len do
      # 1:
      2 -> update_str(str, [:c,:f], pattern)
      # 7:
      3 -> update_str(str, [:a,:c,:f], pattern)
      # 4:
      4 -> update_str(str, [:b, :c, :d, :f], pattern)
      # 2/3/5:
      5 -> str
      # 0/6/9
      6 -> str
      # 8
      7 -> str
    end

  end

  def update_str(str, segment, pattern) do
    update_str(str, segment, pattern, [])
  end

  def update_str([], _, _, update) do
    Enum.reverse(update)
  end

  def update_str([{x, chars}|str_rest], segment, pattern, update) do
    if exists?(segment, x) do
      chars = keep(chars, pattern, [])
      update_str(str_rest, segment, pattern, [{x, chars}|update])
    else
      chars = remove(chars, pattern, [])
      update_str(str_rest, segment, pattern, [{x, chars}|update])
    end
  end

  def remove([],_, new), do: new
  def remove([c|c_rest], pattern, new) do
    if exists?(pattern, c) do
      remove(c_rest, pattern, new)
    else
      remove(c_rest, pattern, [c|new])
    end
  end

  def keep(_,[], new), do: new
  def keep(chars,[p|p_rest], new) do
    if exists?(chars, p) do
      keep(chars, p_rest, [p|new])
    else
      keep(chars, p_rest, new)
    end
  end

  def exists?([h|_], h), do: true
  def exists?([], _), do: false
  def exists?([_|t], p), do: exists?(t, p)

  def unique_output(input) do
    Stream.map(input, fn(x) ->
      String.split(x, " | ")
    end)
    |> Stream.map(fn([_,output]) -> output end)
    |> Stream.map(fn(x) -> String.split(x, "\n", trim: true) end)
    |> Stream.map(fn(x) -> find_unique(x) end)
    |> Enum.sum()

    #String.length()
  end
  # non unique strings have 5 or 6 chars
  def find_unique([string]) do
    String.split(string, " ", trim: true)
    |> List.foldl(0, fn(x, acc) ->
      case String.length(x) do
        5 -> acc
        6 -> acc
        _ -> 1 + acc
      end
    end)
  end
end
