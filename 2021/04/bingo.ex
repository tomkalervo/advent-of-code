defmodule Bingo do

  def start(file) do
    {[numbers], boards} = File.stream!(file, [], :line)
    |> Enum.split(1)

    boards = build_boards(boards)

    [numbers] = String.split(numbers, "\n")
    |> Enum.filter(fn(x) -> x != "" end)
    numbers = String.split(numbers, ",")
    |> Enum.filter(fn(x) -> x != "" end)

    # PART 1
    bingo(numbers, boards)
    # PART 2
    bingo_lose(numbers, boards)
  end
  # PART 2
  def bingo_lose(numbers, [board]), do: bingo(numbers, [board])
  def bingo_lose([num|rest], boards) do
    boards = check_lose(num, boards, [])
    bingo_lose(rest, boards)
  end

  def check_lose(_,[],boards), do: Enum.reverse(boards)
  def check_lose(num, [h|t], boards) do
    #IO.write("check #{num}\n")
    board = filter_board(num, h, [])
    #IO.inspect(board)
    case win_condition(board) do
      {:win, _} ->
        check_lose(num, t, boards)
      :no ->
        check_lose(num, t, [board|boards])
    end
  end

  # PART 1
  def bingo([num|rest], boards) do
    case check(num, boards, []) do
      {:win, board} ->
        IO.write("Winning boardvalue: ")
        val = calculate_win(num, board, 0)
        IO.write("#{val}\n")
      {:continue, boards} ->
        bingo(rest, boards)
    end
  end

  def check_rows([]), do: :no
  def check_rows([h|t]) do
    case Enum.filter(h, fn(x) -> x != :x end) do
      [] -> :win
      _ ->check_rows(t)
    end
  end

  def check_index(_, []), do: :ok
  def check_index(n, [h|t]) do
    case List.pop_at(h, n) do
      {:x, _} ->
        check_index(n, t)
      {_,_} ->
        :no
      nil -> IO.puts("error")
    end
  end

  def check_cols(_,len,len), do: :no
  def check_cols(cols, len, n) do
    case check_index(n, cols) do
      :ok ->
        :win
      :no ->
        check_cols(cols, len, n + 1)
    end
  end
  def check_cols([h|_] = cols) do
    check_cols(cols, Enum.count(h), 0)
  end

  def win_condition(board) do
    case check_rows(board) do
      :win ->
        {:win, board}
      :no ->
        case check_cols(board) do
          :win ->
            {:win, board}
          :no ->
            :no
        end
    end
  end
  def check(_,[],boards), do: {:continue, Enum.reverse(boards)}
  def check(num, [h|t], boards) do
    #IO.write("check #{num}\n")
    board = filter_board(num, h, [])
    #IO.inspect(board)
    case win_condition(board) do
      {:win, board} ->
        {:win, board}
      :no ->
        check(num, t, [board|boards])
    end
  end

  def filter_board(_, [], acc), do: Enum.reverse(acc)
  def filter_board(num, [row|t], acc) do
    row = Enum.map(row, fn(x) ->
      if x == num do
        :x
      else
        x
      end end)
    filter_board(num, t, [row|acc])
  end

  def calculate_win(num, [], sum), do: String.to_integer(num) * sum
  def calculate_win(num, [h|t], sum) do
    row_sum = Enum.filter(h, fn(x) -> x != :x end)
    |> Enum.map(fn(x) -> String.to_integer(x) end)
    |> List.foldl(0, fn(x, acc) -> x + acc end)
    calculate_win(num, t, sum + row_sum)
  end

  def build_boards([], boards), do: boards
  def build_boards(text, boards) do
    case Enum.split(text, 1) do
      {["\n"], rest} ->
         {rest, board} = build_board(rest, [])
         build_boards(rest,[board|boards])
      error -> IO.inspect(error)
    end
  end
  def build_boards(text), do: build_boards(text, [])

  def build_board([], board), do: {[], board}
  def build_board(rest, board) do
    case Enum.split(rest, 1) do
      {["\n"], _} ->
        #IO.inspect({rest, board})
        {rest, board}
      {row, rest} ->
        build_board(rest, [build_row(row)|board])
    end
  end

  def build_row([row]) do
    [row] = String.split(row, "\n")
    |> Enum.filter(fn(x) -> x != "" end)

    String.split(row, " ")
    |> Enum.filter(fn(x) -> x != "" end)
  end

end
