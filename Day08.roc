app "day-8"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [Aoc, Util]
    provides [main] to pf

main = Aoc.solveDay { day: 8, parse, part1, part2 }

parse = \s -> Str.split s "\n" |> List.map Str.toUtf8

mapMatrixVisibility = \m, f ->
    row, rowIndex <- List.mapWithIndex m
    item, colIndex <- List.mapWithIndex row
    column = List.keepOks m (\r -> List.get r colIndex)
    { left, right } = Util.splitExclusive row colIndex
    { left: top, right: bottom } = Util.splitExclusive column rowIndex

    f item [List.reverse left, right, List.reverse top, bottom]

visibilityMap : List (List U8) -> List (List Bool)
visibilityMap = \m ->
    item, allDirections <- mapMatrixVisibility m
    direction <- List.any allDirections
    List.all direction (\n -> n < item)

scenicScores : List (List U8) -> List (List U64)
scenicScores = \m ->
    item, allDirections <- mapMatrixVisibility m
    directionScores =
        trees <- List.map allDirections
        count, current <- List.walkUntil trees 0
        if current >= item then Break (count + 1) else Continue (count + 1)

    List.product directionScores

part1 = \m ->
    visibilityMap m
    |> List.map (\l -> List.countIf l (\b -> b))
    |> List.sum
    |> Num.toStr

part2 = \m ->
    scenicScores m
    |> List.keepOks List.max
    |> List.max
    |> Result.withDefault 0
    |> Num.toStr
