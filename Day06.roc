app "day-6"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [Aoc]
    provides [main] to pf

main = Aoc.solveDay { day: 6, parse: \s -> s, part1, part2 }

findMarker : [CheckLast Nat] -> (List U8, U8 -> [Break (List U8), Continue (List U8)])
findMarker = \CheckLast n ->
    \visited, current ->
        newVisited = List.append visited current
        markerFound =
            List.takeLast newVisited n
            |> Set.fromList
            |> \s -> Set.len s == n

        if markerFound then
            Break newVisited
        else
            Continue newVisited

part1 = \s ->
    Str.toUtf8 s
    |> List.walkUntil [] (findMarker (CheckLast 4))
    |> List.len
    |> Num.toStr

part2 = \s ->
    Str.toUtf8 s
    |> List.walkUntil [] (findMarker (CheckLast 14))
    |> List.len
    |> Num.toStr
