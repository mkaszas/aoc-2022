app "day-14"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [Aoc, Util]
    provides [main] to pf

main = Aoc.solveDay { day: 14, parse, part1, part2 }

Point : { x : U16, y : U16 }

parse : Str -> Set Point
parse = \s ->
    pointLists =
        lineStr <- List.map (Str.split s "\n")
        pointStr <- List.keepOks (Str.split lineStr " -> ")

        when Str.split pointStr "," is
            [xStr, yStr] ->
                x <- Result.try (Str.toU16 xStr)
                y <- Result.try (Str.toU16 yStr)

                Ok { x, y }

            _ -> Err BadPointFormat

    List.map pointLists (\l -> Util.walk2 l Set.empty (\a, b, acc -> Set.union acc (drawLine a b)))
    |> List.walk Set.empty Set.union

drawLine : Point, Point -> Set Point
drawLine = \{ x: xA, y: yA }, { x: xB, y: yB } ->
    points =
        x <- List.joinMap (List.range { start: At xA, end: At xB })
        y <- List.map (List.range { start: At yA, end: At yB })
        { x, y }

    Set.fromList points

startLocation = { x: 500, y: 0 }
maxY = \points -> Set.toList points |> List.map .y |> List.max |> Result.withDefault 0
checkPos = \points, point -> if Set.contains points point then Occupied else Empty

checkLocation : { stop : [At U16, WhenOverflowing] }, Point, Set Point -> Result Point [Overflowing]
checkLocation = \{ stop }, point, occupiedPoints ->
    { shouldStop, returnValue } =
        when stop is
            At i -> { shouldStop: point.y == i, returnValue: Ok point }
            WhenOverflowing -> { shouldStop: point.y > maxY occupiedPoints, returnValue: Err Overflowing }

    if shouldStop then
        returnValue
    else
        pointBelow = { point & y: point.y + 1 }
        leftDiagonal = { x: point.x - 1, y: point.y + 1 }
        rightDiagonal = { x: point.x + 1, y: point.y + 1 }

        when T (checkPos occupiedPoints leftDiagonal) (checkPos occupiedPoints pointBelow) (checkPos occupiedPoints rightDiagonal) is
            T Occupied Occupied Occupied -> Ok point
            T _ Empty _ -> checkLocation { stop } pointBelow occupiedPoints
            T Empty Occupied _ -> checkLocation { stop } leftDiagonal occupiedPoints
            T Occupied Occupied Empty -> checkLocation { stop } rightDiagonal occupiedPoints

fillWithSand : { stop : [At U16, WhenOverflowing] }, Set Point -> Set Point
fillWithSand = \{ stop }, occupiedPoints ->
    when checkLocation { stop } startLocation occupiedPoints is
        Err Overflowing -> occupiedPoints
        Ok newPoint if newPoint == startLocation -> Set.insert occupiedPoints newPoint
        Ok newPoint -> fillWithSand { stop } (Set.insert occupiedPoints newPoint)

part1 = \points ->
    blocks = Set.len points
    allOccupied = Set.len (fillWithSand { stop: WhenOverflowing } points)

    allOccupied - blocks |> Num.toStr

part2 = \points ->
    blocks = Set.len points
    allOccupied = Set.len (fillWithSand { stop: At (maxY points + 1) } points)

    allOccupied - blocks |> Num.toStr
