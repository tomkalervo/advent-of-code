defmodule Decode do
  use Bitwise

  @packet1 "D2FE28"
  @packet2 "38006F45291200"
  @packet3 "EE00D40C823060"
  @packet4 "8A004A801A8002F478"
  @packet5 "620080001611562C8802118E34"
  @packet6 "C0015000016115A2E0802F182340"
  @packet7 "A0016C880162017C3686B18A3D4780"

  @input "A20D74AFC6C80CEA7002D4009202C7C00A6830029400F500218080C3002D006CC2018658056E7002DC00C600E75002ED6008EDC00D4003E24A13995080513FA309482649458A054C6E00E6008CEF204BA00B080311B21F4101006E1F414846401A55002F53E9525B845AA7A789F089402997AE3AFB1E6264D772D7345C6008D8026200E41D83B19C001088CB04A294ADD64C0129D818F802727FFF3500793FFF9A801A801539F42200DC3801A39C659ACD3FC6E97B4B1E7E94FC1F440219DAFB5BB1648E8821A4FF051801079C379F119AC58ECC011A005567A6572324D9AE6CCD003639ED7F8D33B8840A666B3C67B51388440193E003413A3733B85F2712DEBB59002B930F32A7D0688010096019375300565146801A194844826BB7132008024C8E4C1A69E66108000D39BAD950802B19839F005A56D9A554E74C08028992E95D802D2764D93B27900501340528A7301F2E0D326F274BCAB00F5009A737540916D9A9D1EA7BD849100425D9E3A9802B800D24F669E7691E19CFFE3AF280803440086C318230DCC01E8BF19E33980331D631C593005E80330919D718EFA0E3233AE31DF41C67F5CB5CAC002758D7355DD57277F6BF1864E9BED0F18031A95DDF99EB7CD64626EF54987AE007CCC3C4AE0174CDAD88E65F9094BC4025FB2B82C6295F04100109263E800FA41792BCED1CC3A233C86600B48FFF5E522D780120C9C3D89D8466EFEA019009C9600A880310BE0C47A100761345E85F2D7E4769240287E80272D3CEFF1C693A5A79DFE38D27CCCA75E5D00803039BFF11F401095F714657DC56300574010936491FBEC1D8A4402234E1E68026200CC5B8FF094401C89D12E14B803325DED2B6EA34CA248F2748834D0E18021339D4F962AB005E78AE75D08050E10066114368EE0008542684F0B40010B8AB10630180272E83C01998803104E14415100623E469821160"

  # transform string into bit sequence
  # initialise parse/1
  def start() do
    IO.puts("Start")
    stream =
      String.to_integer(@input, 16)
      |> to_bits()

    # parse stream of packages
    result = parse(stream)
    # Part 1 - print sum of versions
    v_sum = Print.sum_v(result)
    IO.puts("Version sum : #{v_sum}")
    # Part 2 - Get value with ID - operations
    [result|_] = result
    transmission = Print.op(result)
    IO.puts("Transmission value : #{transmission}")
  end

  # parse main package
  def parse(stream), do: parse(stream, [])
  def parse([], result), do: Enum.reverse(result)
  def parse(stream, result) do
    case get_package(stream) do
      :eof ->
        parse([], result)
      {package, rest} ->
        parse(rest, [package|result])
    end
  end

  # subpackages
  def sub_parse(stream, result, 0) do
    {Enum.reverse(result), stream}
  end
  def sub_parse(stream, result, n) do
    {package, rest} = get_package(stream)
    sub_parse(rest, [package|result], n-1)
  end

  # not used
  def trim(stream) do
    n = 4-rem(Enum.count(stream), 4)
    check_bits(stream, [], n)
  end
  def check_bits(stream, _, 0) do
    trim(stream)
  end
  def check_bits([h|t], acc, n) when h == 0 do
    check_bits(t,[h|acc], n-1)
  end
  def check_bits(stream, acc, _) do
    append(acc, stream)
  end

  # get header information and get corresponding package format
  # return the result
  # def get_package([],_), do: :end_of_stream
  def get_package(stream) do
    IO.inspect(stream)
    {p_vs, stream} = header(stream)
    {p_id, stream} = header(stream)
    p_vs = binary_to_decimal(p_vs)
    p_id = binary_to_decimal(p_id)
    # IO.puts("vs : #{p_vs}, id : #{p_id}")
    # IO.inspect(stream)
    case get_package(p_id, stream) do
      :eof ->
        :eof
      {package, stream} ->
        {{{:version, p_vs}, {:id, p_id}, {:package, package}}, stream}
    end
  end

  # package is in literal format
  def get_package(4, stream) do
    literal(stream)
  end

  # package is in operator format,
  # length ID is 0 means package length is in next 15 bits
  def get_package(_, [0|stream]) do
    {length, stream} =
      Enum.split(stream, 15)

    length = binary_to_decimal(length)
    {sub_stream, stream} =
      Enum.split(stream, length)

    {parse(sub_stream, []), stream}
  end

  # length ID is 1 means number of sub packages is in next 11 bits
  def get_package(_, [1|stream]) do
    {length, stream} =
      Enum.split(stream, 11)

    length = binary_to_decimal(length)

    sub_parse(stream, [], length)
  end

  def get_package(n,stream) do
    IO.puts("eof")
    IO.puts(n)
    IO.inspect(stream)
    :eof
  end

  # literal/1 reads bit-patterns of 5.
  # If 1st bit is 0 then the remaining 4 bits are the last int in the package.
  # packet length is a multiple of 4, thus padded 0's must be removed at the end.
  def literal(stream) do
    literal(stream, [])
  end
  def literal([h|stream], acc) do
    if h == 0 do
      # get last int
      {int, stream} = Enum.split(stream, 4)
      literal =
        Enum.reverse([int|acc])

      # get decimal value of literal
        literal =
          List.flatten(literal) |> binary_to_decimal()
      # return values
      {literal, stream}
    else
      # get one (not last) int
      {int, stream} = Enum.split(stream, 4)
      # continue recursion
      literal(stream, [int|acc])
    end
  end

  # header/1 returns the first 3 bits and the remaining stream of packages
  def header(stream) do
    Enum.split(stream, 3)
  end

  # Takes a list of binaries and returns its decimal value as an integer
  def binary_to_decimal(binary) do
    List.foldl(binary, [], fn(x,acc) ->
      [x | Enum.map(acc, fn(val) -> val * 2 end)]
    end)
    |> Enum.sum()
  end
  # takes an integer and returns a list of the value as a bit sequence
  # F -> 1 1 1 1
  def to_bits(int), do: to_bits(int, 0, [])
  def to_bits(0, n, bits) do
    case 4-rem(n,4) do
      4 -> bits
      pad ->
        Enum.to_list(1..pad)
        |> List.foldl(bits, fn(_,bits) -> [0|bits] end)
    end
  end
  def to_bits(int, n, bits) do
    bits = [int &&& 1 | bits]
    int = int >>> 1
    to_bits(int, n+1, bits)
  end

  def to_bits([], bits), do: Enum.reverse(bits)

  # quick append, reverses first parameter
  def append([], x), do: x
  def append([h|t], x), do: append(t, [h|x])
end
defmodule Print do
  def sum_v(pkg), do: sum_v(pkg, 0)
  def sum_v([], sum), do: sum
  def sum_v([{{:version, v}, {:id, _}, {:package, package}}|t], sum) when is_integer(package) do
    sum_v(t, sum + v)
  end
  def sum_v([{{:version, v}, {:id, _}, {:package, package}}|t], sum) do
    sum = sum_v(package) + sum
    sum_v(t, sum + v)
  end

  # id 0 : sum
  # id 1 : product
  # id 2 : minimum
  # id 3 : maximum
  # id 5 : greater than
  # id 6 : less than
  # id 7 : equal

  # def op(pkg), do: op(pkg, 0)
  def op({_, {:id, id}, {:package, pkg}}) do
    case id do
      0 ->
        sum(pkg)
      1 ->
        prod(pkg)
      2 ->
        mini(pkg)
      3 ->
        maxi(pkg)
      4 ->
        pkg
      5 ->
        greater(pkg)
      6 ->
        less(pkg)
      7 ->
        equal(pkg)
    end
  end
  def sum(pkg), do: sum(pkg, 0)
  def sum([], sum), do: sum
  def sum([h|t], sum) do
      sum(t, sum + op(h))
  end

  def prod(pkg), do: prod(pkg, 1)
  def prod([], prod), do: prod
  def prod([h|t], prod) do
        prod(t, op(h) * prod)
  end

  def mini([h|t]), do: mini(t, op(h))
  def mini([], min), do: min
  def mini([h|t], min) do
    mini(t, min(op(h), min))
  end

  def maxi([h|t]), do: maxi(t, op(h))
  def maxi([], max), do: max
  def maxi([h|t], max) do
    maxi(t, max(op(h), max))
  end

  def greater([h1,h2]) do
    if op(h1) > op(h2) do
      1
    else
      0
    end
  end
  def less([h1,h2]) do
    if op(h1) < op(h2) do
      1
    else
      0
    end
  end

  def equal([h1,h2]) do
    if op(h1) == op(h2) do
      1
    else
      0
    end
  end
end
