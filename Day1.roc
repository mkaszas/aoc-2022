app "day-1"
    packages { pf: "examples/cli/cli-platform/main.roc" }
    imports [pf.Task.{Task}, Aoc]
    provides [main] to pf

main = Aoc.dayProgram { parse, part1, part2 }

parse : Task (List (List U32)) _ _
parse =
    inputStr <- Task.map (Aoc.readDailyInput 1)
    groups <- List.map (Str.split inputStr "\n\n")

    Str.split groups "\n"
        |> List.keepOks Str.toU32


part1 : List (List U32) -> Str
part1 = \input ->
    List.map input List.sum
        |> List.max
        |> Result.withDefault 112
        |> Num.toStr


part2 : List (List U32) -> Str
part2 = \input ->
    List.map input List.sum
        |> List.sortDesc
        |> List.takeFirst 3
        |> List.sum
        |> Num.toStr
