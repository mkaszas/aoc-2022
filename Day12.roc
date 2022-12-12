app "day-12"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [Aoc]
    provides [main] to pf

main = Aoc.solveDay { day: 12, parse, part1, part2 }

Index : { row : I8, col : I8 }
Map : Dict Index U8

startMarker = 83
startHeight = 97
endMarker = 69
endHeight = 122

parse : Str -> Map
parse = \input ->
    Str.split input "\n"
    |> List.mapWithIndex
        (\row, rowIndex ->
            Str.toUtf8 row
            |> List.mapWithIndex (\n, colIndex -> T { row: Num.toI8 rowIndex, col: Num.toI8 colIndex } n)
        )
    |> List.join
    |> Dict.fromList

startIndex = \map ->
    Dict.toList map
    |> List.findFirst (\T _ val -> val == startMarker)
    |> Result.map (\T i _ -> i)
    |> Result.withDefault { row: 0, col: 0 }

neighbours = \{ row, col } ->
    [{ row: row - 1, col }, { row, col: col + 1 }, { row: row + 1, col }, { row, col: col - 1 }]

updateNeighbour = \heightMap, distanceMap, index, previousHeight, previousDistance ->
    thisHeight <- Result.try (Dict.get heightMap index)
    thisDistance <- Result.try (Dict.get distanceMap index)

    adjustedHeight = if thisHeight == endMarker then endHeight else thisHeight

    if adjustedHeight > previousHeight + 1 then
        Err E
    else
        when thisDistance is
            Visited _ -> Err E
            Checked d -> List.min [d, previousDistance + 1] |> Result.map (\newDistance -> T index (Checked newDistance))
            Unknown -> Ok (T index (Checked (previousDistance + 1)))

getChecked = \dist ->
    when dist is
        Checked d -> Ok d
        _ -> Err E

findShortestPath : { heightMap : Map, distanceMap : Dict Index [Unknown, Visited Nat, Checked Nat], currentIndex : Index, currentDistance : Nat, currentHeight : U8 } -> Result Nat _
findShortestPath = \{ heightMap, distanceMap, currentIndex, currentDistance, currentHeight } ->
    if currentHeight == endMarker then
        Ok currentDistance
    else
        newNeighbourDistances =
            neighbours currentIndex
            |> List.keepOks (\index -> updateNeighbour heightMap distanceMap index currentHeight currentDistance)
            |> Dict.fromList

        newDistanceMap =
            Dict.insertAll distanceMap newNeighbourDistances
            |> Dict.insert currentIndex (Visited currentDistance)

        nextDistance <-
            Dict.values newDistanceMap
            |> List.keepOks getChecked
            |> List.min
            |> Result.try

        nextIndex <-
            Dict.toList newDistanceMap
            |> List.findFirst (\T _ d -> d == Checked nextDistance)
            |> Result.map (\T i _ -> i)
            |> Result.try

        nextHeight <- Dict.get heightMap nextIndex |> Result.try

        findShortestPath { heightMap, distanceMap: newDistanceMap, currentIndex: nextIndex, currentDistance: nextDistance, currentHeight: nextHeight }

emptyDistanceMap = \m ->
    Dict.keys m
    |> List.map (\i -> T i Unknown)
    |> Dict.fromList

part1 : Map -> Str
part1 = \heightMap ->
    findShortestPath { heightMap, distanceMap: emptyDistanceMap heightMap, currentIndex: startIndex heightMap, currentDistance: 0, currentHeight: startHeight }
    |> Result.withDefault 1
    |> Num.toStr

startingDistanceMap = \m ->
    Dict.toList m
    |> List.map (\T i h -> if h == startHeight then T i (Checked 0) else T i Unknown)
    |> Dict.fromList

part2 : Map -> Str
part2 = \heightMap ->
    findShortestPath { heightMap, distanceMap: startingDistanceMap heightMap, currentIndex: startIndex heightMap, currentDistance: 0, currentHeight: startHeight }
    |> Result.withDefault 1
    |> Num.toStr
