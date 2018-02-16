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
    line
    |> String.split(" => ")
    |> Enum.map(&parse_grid/1)
    |> case do
         [rule, result] -> {canonicalize(rule), result}
       end
  end

  @doc "Expand the block into a list of subblocks after rule expansion."
  def expand(block, rules) do
    {rule, result} = rules |> List.keyfind(canonicalize(block), 0)
    {
      rule,
      case result do
        [
          [_, _, _],
          [_, _, _],
          [_, _, _]
        ] -> [
          result
        ]
        [
          [a1, a2, b1, b2],
          [a3, a4, b3, b4],
          [c1, c2, d1, d2],
          [c3, c4, d3, d4]
        ] -> [
          [[a1, a2], [a3, a4]],
          [[b1, b2], [b3, b4]],
          [[c1, c2], [c3, c4]],
          [[d1, d2], [d3, d4]]
        ]
      end
    }
  end

  def count_num_on(block) do
    block
    |> Enum.flat_map(fn row -> row end)
    |> Enum.count(fn
         "#" -> true
         "." -> false
       end)
  end

  def count_at_depth(0, block, _), do: count_num_on(block)
  def count_at_depth(depth, block, rules) do
    {rule, blocks} = expand(block, rules)
    IO.puts("Expanding rule " <> inspect(rule))

    blocks
    |> Enum.flat_map(fn block -> count_at_depth(depth-1, block, rules) end)
  end

  def start, do: parse_grid(".#./..#/###")
  def rules, do: File.read!("input.txt") |> String.split("\n", trim: true) |> Enum.map(&parse_rule/1)
  def solution, do: count_at_depth(5, start(), rules())
end

IO.puts Day21.solution
