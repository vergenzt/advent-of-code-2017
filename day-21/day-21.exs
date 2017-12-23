defmodule Day21 do
  # 1. canonicalize blocks (rotate/flip)
  # 2. enhance blocks

  def canonicalize(block) do
    [
      block,
      block |> rotate(),
      block |> rotate() |> rotate(),
      block |> rotate() |> rotate() |> rotate(),
    ]
    |> Enum.flat_map(fn block ->
      [
        block,
        block |> fliplr(),
        block |> flipud(),
        block |> flipud() |> fliplr()
      ]
    end)
    |> Enum.min()
  end

  def rotate(block) do
    case block do
    [
      [a, b],
      [c, d]
    ] -> [
      [c, a],
      [d, b]
    ]
    [
      [a, b, c],
      [d, e, f],
      [g, h, i]
    ] -> [
      [g, d, a],
      [h, e, b],
      [i, f, c]
    ]
    end
  end

  def fliplr(block) do
    case block do
    [
      [a, b],
      [c, d]
    ] -> [
      [b, a],
      [d, c]
    ]
    [
      [a, b, c],
      [d, e, f],
      [g, h, i]
    ] -> [
      [c, b, a],
      [f, e, d],
      [i, h, g]
    ]
    end
  end

  def flipud(block) do
    case block do
    [
      [a, b],
      [c, d]
    ] -> [
      [c, d],
      [a, b]
    ]
    [
      [a, b, c],
      [d, e, f],
      [g, h, i]
    ] -> [
      [g, h, i],
      [d, e, f],
      [a, b, c]
    ]
    end
  end

  def parse_grid(grid) do
    grid
    |> String.split("/")
    |> Enum.map(fn line -> line
      |> String.trim()
      |> String.split("", trim: true)
    end)
  end

  def parse_rule(line) do
    case String.split(line, " => ") do
      [rule, result] -> {canonicalize(parse_grid(rule)), parse_grid(result)}
    end
  end

  def enhance(block, rules) do
    {_rule, result} = rules |> List.keyfind(canonicalize(block), 0)
    result
  end

  def count_num_on(block) do
    block
    |> Enum.flat_map(fn line -> line end)
    |> Enum.count(fn
      "#" -> true
      "." -> false
    end)
  end

  def count_at_depth(0, block, _), do: count_num_on(block)
  def count_at_depth(depth, block, rules) do
    eblock = enhance(block, rules)
    case eblock do
      [[_, _, _], [_, _, _], [_, _, _]] ->
        count_at_depth(depth-1, eblock, rules)
      [
        [a1, a2, b1, b2],
        [a3, a4, b3, b4],
        [c1, c2, d1, d2],
        [c3, c4, d3, d4]
      ] ->
        Enum.sum([
          count_at_depth(depth-1, [[a1, a2], [a3, a4]], rules),
          count_at_depth(depth-1, [[b1, b2], [b3, b4]], rules),
          count_at_depth(depth-1, [[c1, c2], [c3, c4]], rules),
          count_at_depth(depth-1, [[d1, d2], [d3, d4]], rules),
        ])
    end
  end
end

start = Day21.parse_grid(".#./..#/###")
rules = IO.stream(:stdio, :line) |> Enum.map(&Day21.parse_rule/1)

#IO.puts inspect(start)
#IO.puts inspect(rules)

IO.puts Day21.count_at_depth(5, start, rules)



