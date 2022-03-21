defmodule Syntax do
  # [ = 91
  # ] = 93
  # ( = 40
  # ) = 41
  # { = 123
  # } = 125
  # < = 60
  # > = 62
  @points [{:point, ?), 0}, {:point, ?], 0}, {:point, ?}, 0}, {:point, ?>, 0}]

  def start() do
    # PART 2
    Input.input
    |> String.split("\n", trim: true)
    |> Enum.map(fn(x) ->
      String.to_charlist(x)
    end)
    |> syntax_check([])
    |> IO.inspect()
    |> List.foldl([], fn({status, line}, acc) ->
      if status == :ok do
        case missing_brackets(line, []) do
          [] ->
            acc
          missing_brackets ->
            [missing_brackets|acc]
        end
      else
        acc
      end
    end)
    |> List.foldl([], fn(x, acc) ->
      in_sort(score(x, 0), acc)
    end)
    |> middle_score()

    # PART 1
    # Input.demo
    # Input.input
    # |> String.split("\n", trim: true)
    # |> Enum.map(fn(x) ->
    #   String.to_charlist(x)
    # end)
    # |> syntax_check([])
    # |> IO.inspect()
    # |> List.foldl(@points, fn(x, points) ->
    #   case x do
    #     {:ok, _} ->
    #       points
    #     {:corrupt, bracket} ->
    #       update_points(points, [], bracket)
    #   end
    # end)
    # |> List.foldl(0, fn(x, acc) ->
    #   acc + points(x)
    # end)

  end
  # PART 2 functions below
  # 1st / entry for getting the middle score of a list of ordered scores
  def middle_score([h|t]) do
    middle_score(t, 1, [h])
  end
  # 2nd
  def middle_score([], val, stack) do
    middle_score(div(val, 2), stack)
  end
  def middle_score([h|t], val, stack) do
    middle_score(t, val+1, [h|stack])
  end
  # 3rd
  def middle_score(0, [h|_]), do: h
  def middle_score(val, [h|t]) do
    middle_score(val-1, t)
  end

  def score([], sum), do: sum
  def score([h|t], sum) do
    case h do
      ?( ->
        score(t, (5 * sum) + 1)
      ?[ ->
        score(t, (5 * sum) + 2)
      ?{ ->
        score(t, (5 * sum) + 3)
      ?< ->
        score(t, (5 * sum) + 4)
    end
  end
  def missing_brackets([], stack), do: stack
  def missing_brackets([h|t], stack) do
    if close_bracket(h) do
      stack = rm_pair(h, stack, [])
      missing_brackets(t, stack)
    else
      missing_brackets(t, [h|stack])
    end
  end
  def rm_pair(b, [h|t], stack) do
    case b - h do
      1 ->
        append(stack, t)
      2 ->
        append(stack, t)
      _ ->
        rm_pair(b, t, [h|stack])
    end
  end

  # PART 1 functions below
  def update_points([{:point, bracket, num}|points], stack, bracket) do
    append(stack, [{:point, bracket, num+1}|points])
  end
  def update_points([h|points], stack, bracket) do
    update_points(points, [h|stack], bracket)
  end
  def points({:point, b, n}) do
    case b do
      ?) ->
        3 * n
      ?] ->
        57 * n
      ?} ->
        1197 * n
      ?> ->
        25137 * n
    end
  end

  def syntax_check([], result), do: Enum.reverse(result)
  def syntax_check([line|rest], result) do
    #IO.puts("Check line: #{line}")
    syntax_check(rest, [line_check(line,[])|result])
  end
  def line_check([],line), do: {:ok, Enum.reverse(line)}
  def line_check([h1|t1], []), do: line_check(t1, [h1])
  def line_check([h1|t1], stack) do
    #IO.puts("Line check, h1: #{h1}, stack: #{stack}")
    if close_bracket(h1) do
      case syntax_match([h1], stack) do
        :ok ->
          #IO.puts("ok!, h1: #{h1}")
          line_check(t1, [h1|stack])
        :no ->
          #IO.puts("corrupt, h1: #{h1}")
          {:corrupt, h1}
      end
    else
      line_check(t1, [h1|stack])
    end
  end
  def syntax_match([], _), do: :ok
  def syntax_match([h1|stack], [h2|rest]) do
    if close_bracket(h2) do
      syntax_match([h2,h1|stack], rest)
    else
      case h1 - h2 do
        1 ->
          syntax_match(stack, rest)
        2 ->
          syntax_match(stack, rest)
        _ -> #IO.puts("#{h1} - #{h2} = #{h1-h2}")
          :no
      end
    end

  end
  def close_bracket(b) do
    case b do
      ?) -> true
      ?] -> true
      ?} -> true
      ?> -> true
      _ -> false
    end
  end

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
defmodule Input do
  @demo """
  [({(<(())[]>[[{[]{<()<>>
  [(()[<>])]({[<{<<[]>>(
  {([(<{}[<>[]}>{[]{[(<()>
  (((({<>}<{<{<>}{[]{[]{}
  [[<[([]))<([[{}[[()]]]
  [{[{({}]{}}([{[{{{}}([]
  {<[[]]>}<{[{[{[]{()[[[]
  [<(<(<(<{}))><([]([]()
  <{([([[(<>()){}]>(<<{{
  <{([{{}}[<[[[<>{}]]]>[]]
  """
  @input """
  ((((<([<{(<(<[<><>>[{}()]>{{()[]}<[][]>}){{(()<>)(<>())}}>{<(([]())({}<>))[<{}()>{{}{}}]>}){{<
  <{<[([{<{{<{[({}())[<>()]]([{}()]{{}[]})}{([[]]<{}[]>){<<>[]><<>[]>}}>}}{[{[{[[]{}]<[][]>>{[<
  [([<[(({(<[<[(<><>)([]())][((){})<<>[]>]>{([<>()]<<>[]>)({{}<>})}][{(<()()>{<><>}){[<>[]][<
  [<[[[{{<{{((<[[][]][[]<>]><({}[])>){{[<>()]{{}{}}}<(()())[<>[]]}}){[(({}{}))](<(<>)>{(<>())(<>[])})}}<<[<<<><
  {{{[{[[{{{{{<<{}<>>{{}[]}>[{<>()}<<>{}>]}<{<<>{}>{[]<>}}({<>()}<(){}>)>}[[(([]<>)<{}()>)]{{[<>{}](<><>)}{([
  {{<[([<[({(<{([][])[{}{}]>([{}<>](<><>))><[[<>{}]]<{<><>}{{}()}>>)<[[([]{})]([<>[]]({}[]))]({(
  ({(([[<<([(([([]())<{}<>>](<()[]>[[]{}])){{{()[]}<<><>>}})<{((<><>)[()[]]]}>])><{<(([{()[]}])[{[{}<>]({
  {[<{(([{[([(<[(){}]<()[]>>[<{}<>>[[]<>]>)]{{({[]}({}()))<<{}<>>{<>{}}>}[({<>[]}[[]<>])([{}[]](<>[]))]})
  [({<({([<{<<({()()}<[]{}>)<<<>()>[<>()])>[(<{}<>>[[]()])<(()()){[]<>}>]>}[([<<{}<>>({}{})>[<[]<>><<>()
  [([(<[([<[([[((){})<()[]>]([{}[]](<>()))]){<[<<>()>(<>{})][[<><>]]>({([][]){<>[]}}[{{}}<()()>])}
  {{[[(([{{((<{[{}[]][{}()]}{((){})<()()>}>(<[{}{}]{()<>}>(<{}()>(()()))))){[[[<{}[]><[]<>>][[{}[]]{
  [{(<{<[<(<{({[()[]]([]<>)}[[<>()]{(){}}])}({{<{}<>><{}()>}{([]())[()<>]}}[(((){})<<>[]>)])><([[<()
  [{<[<{<(({<<{{{}<>}}{[[]()]}>>}[((<[<>][[]<>]>))(({[()<>]<<>()>}<{[][]}<[][]>>))>))>}><[<<<([{{([][])({}<>)
  <{([({[<{{{<(<[]()>[()<>])({<><>}[{}])}}<[(<[]<>>((){})){({}[])(<><>)}]<[[<>[]]<{}()>]>>}{[<<([
  <[{[[[{<{[<({[[]{}]{<>]}[[[]{}]<[]<>>])>]}{{{({<<>{}>(<><>)}[<{}[]>]){([[][]](<>{}))}}{<[(()())(<>(
  (<{(<[({<(<((<(){}>[{}<>])<{(){}}({}[])>)<{<{}[]>{()[]}}([()<>]<<>[]>)>){<<<{}()><{}[]>>{{[][]}}
  [((((<[(([[<{{()[]}{<>()}}{<[]{}>{<>[]}}>[[{<>{}}([]{})]]][([<()<>><{}{}>]<<[]()>{{}()}>)]](<{[[
  <(({<{[(([<[{(<>)<<>{}>}[(<>{}){{}<>}]]>(((([][])(<>{}))))](([{{<>()}(()[])}{<<>>}][([{}{}]
  [{({[[[[<{(<[{()}<[]<>>]{([])}>[(<()<>>({}<>))[({})]]){<<[[]]{<>{}}>{({}{})[<>()]}><{{()<>}({}[])
  [[([[{(((<{(({(){}}[[]{}])[{{}()}[{}()]])[<<{}[]>((){})>]}>{<<[<(){}>](<[]<>>{{}<>})>>}))[{{(({[<><>][
  {({{[{{<<<<<((<>())<[]<>>)<<()<>>({}[])>>>(<{[[]{}]{<>[]}}(<()<>>{[]<>})>({{[][]}([]())}{({}{})[[]
  (((<(([<[[{<{[[]<>][[]<>]}>{<<<>[]>>([[]()][{}()])}}]<{<{(()<>)[<>()>}[[{}[]]]>[<[<>[]]([]
  {[<[<[[<[[<([{{}{}}<[]()>](<{}<>>(()())))<[([]<>){[]<>}]<[<>{}]<[]{}>>>>[([([])[[]{}]]{<{}<>><[]<
  <({<[<{<[<{[(<{}()>)[[[][]]<<>{}>]]{[[()()]<[]<>>][<[]()>{{}[]}]}}[({<{}<>>})<[{{}()}{()<>}]{<[]<>>(
  ({<[<<{<[[<{(<{}()><(){}>)<<[][]>{{}{}}>}[<[{}<>][<>[]]>({()()}<[][]>)]>]}({(<(<<>[]>[<>()])><
  [({((({[<{<{{[<>{}]({}{})}}><<({()[]}{(){}})([[][]]<<>[]>)>{<{()}(<>)>}>}><{<(<<{}>(()[])>)
  <{<([<{{[(<({<{}[]><[][]>}<{(){}}<[]>>)<<({}{})>[{(){}}<[]()>]>>{<{{[]<>)[[]()]}{(<>[])[()<>]}>[
  [<<{(<[{[{<{<[(){}]><{<>}<[]()>>}{<[<>{}](<>>>}>[[<{()()}[()[]]>{[{}()]<{}[]>}]]}]}]>{{<[<[<<{()[]}[[]()]>
  <(<{<[[{<<((<(<>[])(<>{})><[[][]]({}[])>))>(<{<<<>[]>{{}[]}>[({}<>)[()<>]]}>)>}]]>}{{(<<<[
  <[((([<{({({[({}<>}({}{})]<(()())[<>()]>}{{<()[]>}{<<>()>(<>{})}})[<[({}())(<>[])]<{{}()}>>
  [{(<[<((<(({<([]())({}[])>([<>()]{[][]})}){<[([]())({}[])]<<<>()>>>})>{<{<([[]{}][[]()])<(()<>)(<>{})>>}{<{{
  <{[[{({[{[<{(([]<>)<(){}>)<<<><>>[[]<>]>}>{({{()[]}(()[])}<[[]()]>){[([]<>)<[]{}>]}}](<<{[(){}]{<>}}{([]<>)(
  <{(<<[<[[<[[[{()[]}[<>{}]](<<>{}><[][]>)]{(([]){[][]})<<()<>>>}]>[<[({(){}]){<{}{}>([][])}]>(({[<>[]
  <{[<<({[(<({([()][{}()])}([{{}{}}([]<>)]{{{}}<{}()>})){<{{{}}(()[])}([[]<>]{()[]})><<(<>[]
  {({[{[(<<[<{[<<>()>[[]<>>](<<>()>[<>()])}<<[()[]]<<>{}>>{{(){}}[[][]]}>>]>>[(({({([]{})<<>{}>}<{()[]}{[]{}}
  ([(({[{<{{[<{<{}{}>(<>{})}>([<{}[]><<><>>]{(()<>){<><>}})]}[([<[()[]]{<><>}><{[]}{{}[])>]([({}<>)<()<>>]))
  {<<<[([(<<<{<{{}[]}{<>()}><<{}()><(){}>>}>[<<[<><>]<()()>><<(){}>{[]<>}>)(<{(){}}({}{})>{[
  (({({[<[(([[(({}[]){<>()})]]<([([]())<{}[]>]){{{{}[]}{<>()}}([[][]](<>{}))}>)[<[{<{}()>{{}<>}}]<<
  {{(({{<((<<({[(){}]<[]()>}(<{}()>[<>()]))[{{{}<>}[<>()]}[{[]}{()()}]]>][(<<<[]<>>{{}()}>(<{}{}>{<>{
  ({([{<{{{[{({{[]()}<[]{}>})[{<<>()>{[]}}<({}{})({}<>)>]}<{[[[]<>][{}()]][[()<>]([]<>)]}({[<>[]]<{}<>>}<
  [[(<[[({<[{({<{}()>[()[]]}{{[]()}{[][]}})[(({}<>)<<><>>)[([]<>)<{}[]>]]}]>>[{<<(<[[]<>](()[])>[<{}><[]()>
  (<<<<[{<{({<(<{}<>>)>{({[]{}}<<>{}>)<[{}<>]<[]()>>}}){{{{([]<>){(){}}}[{[]<>}[[]{})]}[({(){}
  ({[{{[{[[<([[<{}()>[[][]]]{((){}){()<>}}](([{}[]][[][]])[([]())]))>]]{<<<<([{}[]])<([])[{}{}
  ({(((({{{[[[[{<><>}]<[<><>][(){}]>]{{(<>()){<>[]}}{<()<>>{<>}}}]]}}<[<<((<{}<>><<>[]>){<<><>>{()
  {{<<{{[<<[[<[<{}>[{}<>]]<<<><>>([]())>>(<(<>())(<>{})>(({}{})(<><>)))]<{{{[]{}}[<>{}]}(<(){}>[()()]
  [<(<<{(([{{(((()()){<>()}){[[]()]})((<{}()>[<><>])[({}[])([]<>)])}{([(<>[])<{}<>>]{[()()][{}()]}){[{<>()}<<>
  (<{(<<{[({{([[[]<>][[][]]][<<>()>[[][]]])}[<<([]())<()()>>{[{}()]<[]()>}><({{}[]}{<>()})>]})[{[[([{}]<{
  <<[[(((({<({{([][]){<>()}}}<{(()())<{}()>}{[[][]]<<>()>}>)>})[{{<{[{<><>}[(){}]]((()[])(<><>))}>([<
  <([<{<{{[[[{<{{}<>}<{}]>({<>{}}[{}<>])}(((<>())<[]()>)((()<>){{}[]}))]<{[[<>][<>{}]][([]())]}([[()<>]{(
  {<((<[[{{([<[[()[]]]<{[]{}}{{}}>>(<(()<>)<[]<>>>[<<>()>[{}<>]])]){([[<[]{}>([]())][{()<>}]]<{<
  ((([[<(<<(<({{()[]}{[][]}}{<[]()>[{}()]})[(<<>()>([]<>))<[<>{}]>]>)<<[<[[]<>]>{(()[]){()<>}}]{(
  (<({<{<{[([{{<<>{}>(()[])}}[(({}())([][]))[{{}{}}([]<>)]]](<([[]{}]([]{}))([<><>](()<>))>{[({}{})[()()]][
  {<{{{{{(<{((({{}}[[][]]){([]{}>})<{{()()}[{}<>]}([(){}])>)<<([<>[]]<<>>)[(()<>)([])]><{<()<>>}(<<><
  {{<[{([{{<{([<[]<>>[<>{}]][({}()><<>()>])[<[()[]](()())><[[]]<[]()>>]}{[([<>[]])[<[]{}>]]{{(<><>){{}<>}}(
  [(<({<[{<({[[{[]<>}[[][]]]<{[]()}<[]()>>]<[[[][]]{[]<>}][<[]<>>{[]()}]>}[<<(<>{})[{}{}]>[{{}()}[()()]]><[(
  <([[<(({<{[{{<()[]><{}()>}{{{}<>}}}([{{}[]}<{}<>>]{<[]<>>({}[])})]}>((([{<[]<>>{<>[])}(<<>[]
  ({{<[[([{<{{<[<>{}](()<>)><(()())>}[[<{}[]><<>()}]<{()<>}[()()]>]}>{<<([<>()]([]{}))((<>())[[][]])>
  ([((([[[{{<((<<><>>{[]})<(<><>)<()<>>>){([[]{}][[][]])<<{}<>>{{}<>}>}>{<<[(){}][()()]>[<[]()><
  [<<[[({<<[[<<<()<>>[()[]]><(()())>>(((()[])[(){}])((<>[]){{}[]>))]<<{[[]()][()]}>{(<{}<>>(<><>))<[<>()][
  {{{[([(({{{(([{}[]](()<>))({{}{}})){[({}())(<>[])]}}{<(([][])[<>()])([(){}][{}[]])>[[[[]()]]({<>()}<<>>)]}
  {<(<(([<[<<[[({}[])<<><>>]]({<[]()>}({[]()}<[]()>))><<(((){})(<>[]))>({{<>[]}({}<>)}{<{}()>(()())})>>([<{{
  [<{[[<[({{{<{{[]{}}<[]{}>}{<<><>>}>}[{[([][])<{}()>]({[]<>}[()()])}[([{}[]][[]<>])]]}}<<{[([{}(
  {[([(<{{{([{<[<><>]<<>{}>>[<{}[]>[[]<>]]}])<({[<[][]><[]<>>][<<><>><{}()>]})>}(<{<[(()[])<()
  {((((<{[[[{([(()[])[<>()]]){[{{}()}]}}{{{({}[]){[][]}}[<[]()>]}}]]{[[<({<><>}(<>[]))[({}{})<()()>]>]{{[
  [(({[[<<{<[[(({}{}){{}{}}>[[[][]]<{}<>>]][{{<>()}{[][]}}]]>[[[<<{}[]>>[[<>[]][<>{}]]]{{{{}(
  [([[[[{((<([{[{}{}]([]())}{[()()][{}<>]}])<({{{}{}}<()()>}<([]{})[(){}]>)<({{}{}}<<>[]>)<[<><>][(){}]>>>>[[
  [{{<[{<((([{{<[][]>{<>[]}}({<><>}<<><>>)}<<<{}{}>{[]{}}>{[[]<>]({})}>][<<{{}}(<>())>{{[][]}<[]>}>
  [(([({<(<{[{<{<>{}}><[()()]<()[]>>}{((()())<<><>>)[<{}<>>[<>()]]}]}{{{(<{}{}><<>[]>){{{}}[(){}]}}}{[<{[]{}}>{
  {[[{<[(<<[({({{}{}}[{}<>])[(<>{})<<><>>]}(([{}{}](()()))(<[]>[<>[]])))<({<[]()>}[[<><>]<()
  <[({({<[((<[<({}<>)({}())>]>[({{[]}<{}()>})((<[][]>((){}))[<(){}><()()>])])([[([{}{}]<(){}>)](<<{}[]>{{}<>}>)
  <<<[<{[[<{[<<([]<>}[{}{}]>>{[(()()){()<>}][<<>{}>{{}{}}]}][[<[[]<>]{<>}><{[]<>}{{}{}}>]<[{()
  ([({{[({{{({<[[]]<{}[]>>}{{<[]()]<<><>>}{[()<>]([]())}}){{[<<><>><<>{}>]<(<><>)([]{})>}}}(
  {[[[({{({[((<[[])(<>{})>{[[]<>]<()>})[[<[]<>>[()()]][{[]<>}<<>[]>]])[<{<{}{}>([]())}{[<>{}]}>]]}[((<
  [<(<<<{{((<<({[]{}}([]{})><({}{})>><({<>{}}<()[]>)({[]()}[{}()])>>(([[()[]]<<>[]>](<<>()>({}<>)))<<([
  {[[{{<<[[[[[([()()}(<>[]))]((<<><>>[[]{}])(<{}[]>[{}()]))]{<{{{}<>}}({<>()}{()()})>{{<{}()><{}<>>}}}]]<({<
  <<<[[{(<{({([{<><>}<[][]>]<([]())[{}]>)})<<[<{[]()}({}{})>](<{{}[]}[()[]]>(<[]<>><<>()>)))>}
  ([([((([(<({<[[]<>][()()]>})[[<<<>><<>[]>>({()()}([][]))][<({}[])<<>[]>>{{{}()}{[]{}}}]]><<[<{(){
  {[([{{<{{[{{{<<>{}>}}<[(())(<>{})]{({}<>)[{}[]>}>}{<([[]()]([][]))[[<>[]]<()[]>]>}]({{{[[]{}]{{}()}}}}([[
  {[<[(<<<[<{([(<>[])<{}()>]{[[]{}]<[]<>>})}>]{{[(<{<><>}[{}()]>{[[]{}][{}{}]}){[([]<>)({}())]{{(){}}({
  ((({<{<[[[({<[[]()]{()()}><[<>()][{}[]]>}<(<{}[]>)((<><>)<{}{}>)>)]]{((<<[{}{}][[]()]>(([]<>)[[]{}])><[{[
  {<[<<([<<<{([{<>[]}[()[]]]([{}<>]<[]<>>))<[{<>[]}[{}]]>}[[<[<><>](<>{})>{[()<>)[{}()]}](<((){})([]<>)>)]>
  {[((<[<((<<<{{{}<>}(<>[])}({<><>}(<>{}))>[[<(){}>((){})]((()[]){<>()})]>[<{[[]{}][{}()]}({(){}}<{}
  [{[<{<(([[([(<[]()>((){}))[([]{})[<>{}]]]{<{{}()}(<>{})>})<{(<{}{}>((){}))<{<>[]}<<>()>>}>]({<([{}<>]{<>(
  <{(<([<<{([<{([]{})<[]()>}<{[][]}({}[])>>{(<<>{}>){[()[]]<()()>}}]<[<(<>())><{()()}[()<>]>]>){<{[<(){}><
  (<([([<{<{[<(({}[])((){}))[[{}()](<>())]>][[{[[]()]<()()>]]<<{[]()}>{[{}<>]<[]()>}>]}<<([{{}<>}<()
  [({(({[[[[({{[{}{}]}{(()())[<>[]]}}<{<<>()>(<>[])}(([]){<>{}})>)<<{{[]}[<>()]}{{<>[]}<[]()>})>]]]]})[<[
  <((([[{({(<[<{{}<>>[[]()]><<[][]>[{}()]>][<<{}[]><{}<>>>{[{}()]{<>{}}}]><[{<(){}>{()()}}<(<>{
  [{<{(<{[((<{<{{}[]}({}{})>{({}[])[<>[]]}}{({[]()}){[{}()]<()>}}><<([[]]{<><>}){[[]()](<>{})}>{(<(){}>{[]
  <<([{(<<(([{[{<><>}<{}<>>][[()<>]]}([(()[])[[]()]}<<<>{}>{(){}}>)])[(<<{()()}><[()[]]{<>()}>><(([]{})
  [(<([<{<{{((<((){})<[]{}>>({()[]}({}<>))))}([<[(<>())[{}[]]]((<>[])[{}[]])>[[[(){}]{<>{}}]]])}[{({(<()()){{}
  {({<(<(<{{(({{<>[]}{<>[]}}[{{}}<<>>]))<<[<()[]><()[]>]<({}{})<<>[]>>>{[[[]())<[]()>]}>}{{{(<[]<>><
  {[{{[(<[[[({[{[]()}[[]]]<<<>[]><()()>>})][[(([<>{}]{{}()}){<{}<>>{[]<>}})[{({}<>)}]]<<{(<><>)<{}()>}<(<>())<<
  <{<{{[<[<{<(([[]{}])[[{}{}]{()[]}])<<{()()}{()<>)>>>}<[<[[{}{}][()[]]]<<[]()>(<>[])>>[(([])
  (([{([<<{{((({()()}[()<>])({<><>}))<<{[][]}[{}()]>{([]{})}>)}}(<<{(<[]()>{[]()})((()()){<><
  [[{<{{{{<(<{{{()[]}{{}[]}}}><<<<{}[]>{{}()}><[{}<>](()[])>>{{({}()><(){}>}<{[]()}[{}]>}>)>[[[{[[{}<>]<()()>][
  [(<<{[{([{[[[{(){}}]<[[][]][<>[]]>]<[<()[]>(()<>)]<<[]()>{[]<>}>>]<<{<{}{}>{{}<>}}{<<><>>[{}<>]}>[
  <[{[({[[[[([([[]<>]<<>{}>)(<{}[]>[<><>])]{[[[]<>}{<><>}]{(()())[()[]]}}){<(<()[]><{}{}>)>{((<><>)[<><>]){{<>
  {([((<{[<({{(<[]>({}{})]{[<>{}]<{}()>}}{([<>{}]<(){}>)[[<>{}](())]}})>[{{<[<<>[]>({}[])]<<{}{}>{
  [<<{([{{{([(<[<>[]][()<>]>(<[]()><<>[]>))(((()()){{}()})<<<>{}>[()<>]>)][{({[]{}}(<><>))[{(){}]]}{<([]<>)
  {[<(([[[{{[{<(<><>)<<>{}>>}]{<{<<><>>}>{[{[]()}[<><>]]([()()][()()])}}}<[{(<()<>>{{}<>})}]{{[<()>{{}[]}]{{{}
  [<[{({{{[<[({<<>{}>{{}{}}})<((<>{}))[{(){}}]>]><((<{[]()}>[([][])]))[[(<()()><{}{}>)[[{}<>]<<>{}}]]{[[<><>
  ([{<(([(((<{({()[]}{[]<>})[{[]{}}]}>(<{<()[]>}(([]{})[[]])>)){{{({{}()})(<<>()><[]<>>)}<[{[]{}}]<(()[]>([](
  """
  def demo, do: @demo
  def input, do: @input
end