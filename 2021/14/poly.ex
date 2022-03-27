defmodule Poly do

  def start(n) do
    # fetch starting template and rules
    {template, rules} =
      String.split(Input.input, "\n\n") |> List.to_tuple()

    # create lists
    template = String.to_charlist(template)

    rules =
    String.split(rules, "\n", trim: true)
    |> Enum.map(fn(x) ->
      String.split(x, " -> ")
      |> Enum.map(fn(x) -> String.to_charlist(x) end)
      |> List.to_tuple()
    end)

      # Create a table using a smarter data structure, then update n times with the rules
      # {start_pair, end_pair, [{pair_1, amount}, {pair_2, amount}, ..., {pair_n, amount}]}
      table =
        smart_start({[],[],[]}, template)
        |> smart_update(rules,n)
        #|> IO.inspect()

      # calculate nr of total elements, return most & least
      [most, least] =
        smart_calc(table)
        |> List.foldl([nil, nil], fn({_,value}, [most, least]) ->
          if most == nil do
            [value, value]
            else
              if value > most do
                [value, least]
              else
                if value < least do
                  [most, value]
                else
                  [most, least]
                end
              end
            end
        end)

      # display value of most subtracted by least
      IO.puts("most - least = #{most - least}")
  end

  # Getting letter frequence by sorting list and following the trail
  def smart_calc({[p,_] = first, last, smart_pairs}) do
    list = memb(first, smart_pairs, [], 1)
    list = memb(last, list, [], 1)
    smart_calc(list, memb([p],[],[], 1))
  end

  def smart_calc([], table), do: table
  def smart_calc([{_,0}|t], table) do
    smart_calc(t, table)
  end
  def smart_calc([{[_,p2], val}|t], table) do
    table = memb([p2], table, [], val)
    smart_calc(t, table)
  end

  defp smart_update(pairs_struct, _, 0) do
    pairs_struct
  end
  defp smart_update({first,last,pairs}, rules, n) do
    {first, pair1} = smart_insert(first, rules)
    {pair2, last} = smart_insert(last, rules)
    pairs = smart_add(pairs, pairs, rules)
    pairs = memb(pair1, pairs, [], 1)
    pairs = memb(pair2, pairs, [], 1)
    smart_update({first,last,pairs}, rules, n-1)
  end

  defp smart_add([], pairs, _), do: pairs
  defp smart_add([{pair, n}|t], pairs, rules) when n > 0 do
    {pair1,pair2} = smart_insert(pair, rules)
    pairs = memb(pair1, pairs, [], n)
    pairs = memb(pair2, pairs, [], n)
    pairs = memb(pair, pairs, [], -n)
    smart_add(t, pairs, rules)
  end
  defp smart_add([_|t], pairs, rules) do
    smart_add(t, pairs, rules)
  end

  defp smart_insert([h1,h3], [{[h1,h3], [h2]}|_]) do
    {[h1,h2], [h2,h3]}
  end
  defp smart_insert(pair, [_|t]), do: smart_insert(pair, t)

  defp smart_start({left,[],pairs}, [h1,h2]) do
    {left,[h1,h2],pairs}
  end
  defp smart_start({[],right,pairs}, [h1,h2|t]) do
    smart_start({[h1,h2],right,pairs}, [h2|t])
  end
  defp smart_start({left,right,pairs}, [h1,h2|t]) do
    smart_start({left,right,memb([h1,h2], pairs, [], 1)}, [h2|t])
  end

  defp memb(x, [], acc, k) do
    append(acc, [{x, k}])
  end
  defp memb(x, [{x, n}|rest], acc, k) do
    append(acc, [{x, n+k}|rest])
  end
  defp memb(x, [h|rest], acc, k) do
    memb(x, rest, [h|acc], k)
  end

  # quick append, reverses first parameter
  def append([], x), do: x
  def append([h|t], x), do: append(t, [h|x])
end
defmodule Input do
  @demo """
  NNCB

  CH -> B
  HH -> N
  CB -> H
  NH -> C
  HB -> C
  HC -> B
  HN -> C
  NN -> C
  BH -> H
  NC -> B
  NB -> B
  BN -> B
  BB -> N
  BC -> B
  CC -> N
  CN -> C
  """
  @input """
  KHSSCSKKCPFKPPBBOKVF

  OS -> N
  KO -> O
  SK -> B
  NV -> N
  SH -> V
  OB -> V
  HH -> F
  HP -> H
  BP -> O
  HS -> K
  SN -> B
  PS -> C
  BS -> K
  CF -> H
  SO -> C
  NO -> H
  PP -> H
  SS -> P
  KV -> B
  KN -> V
  CC -> S
  HK -> H
  FN -> C
  OO -> K
  CH -> H
  CP -> V
  HB -> N
  VC -> S
  SP -> F
  BO -> F
  SF -> H
  VO -> B
  FF -> P
  CN -> O
  NP -> H
  KK -> N
  OP -> S
  BH -> F
  CB -> V
  HC -> P
  KH -> V
  OV -> V
  NK -> S
  PN -> F
  VV -> N
  HO -> S
  KS -> C
  FP -> F
  FH -> F
  BB -> C
  FB -> V
  SB -> K
  KP -> B
  FS -> C
  KC -> P
  SC -> C
  VF -> F
  VN -> B
  CK -> C
  KF -> H
  NS -> C
  FV -> K
  HV -> B
  HF -> K
  ON -> S
  CV -> N
  BV -> F
  NB -> N
  NN -> F
  BF -> N
  VB -> V
  VS -> K
  BK -> V
  VP -> P
  PB -> F
  KB -> C
  VK -> O
  NF -> F
  FO -> F
  PH -> N
  VH -> B
  HN -> B
  FK -> K
  PO -> H
  CO -> B
  FC -> V
  OK -> F
  OF -> V
  PF -> F
  BC -> B
  BN -> O
  NC -> K
  SV -> H
  OH -> B
  PC -> O
  OC -> C
  CS -> P
  PV -> V
  NH -> C
  PK -> H
  """
  def demo, do: @demo
  def input, do: @input

end
