app "day-1"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [Aoc]
    provides [main] to pf

main = Aoc.solveDay { day: 1, parse, part1, part2 }

parse : Str -> List (List U32)
parse = \inputStr ->
    groups <- List.map (Str.split inputStr "\n\n")

    Str.split groups "\n"
    |> List.keepOks Str.toU32

part1 : List (List U32) -> Str
part1 = \input ->
    List.map input List.sum
    |> List.max
    |> Result.withDefault 0
    |> Num.toStr

part2 : List (List U32) -> Str
part2 = \input ->
    List.map input List.sum
    |> List.sortDesc
    |> List.takeFirst 3
    |> List.sum
    |> Num.toStr
