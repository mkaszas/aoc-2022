app "day-9"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [Aoc]
    provides [main] to pf

main = Aoc.solveDay { day: 9, parse, part1, part2 }

Direction : [U, D, L, R]
Instruction : { dir : Direction, moves : U8 }

parse = \s ->
    Str.split s "\n"
    |> List.keepOks parseInstruction

parseInstruction = \s ->
    when Str.split s " " is
        ["U", n] -> Result.map (Str.toU8 n) (\m -> { dir: U, moves: m })
        ["D", n] -> Result.map (Str.toU8 n) (\m -> { dir: D, moves: m })
        ["L", n] -> Result.map (Str.toU8 n) (\m -> { dir: L, moves: m })
        ["R", n] -> Result.map (Str.toU8 n) (\m -> { dir: R, moves: m })
        _ -> Err BadRowFormat

Position : { x : I32, y : I32 }
MoveState : { lastKnot : Position, movedKnots : List Position }

moveKnot : MoveState, Position -> MoveState
moveKnot = \{ lastKnot, movedKnots }, thisKnot ->
    xDistance = Num.abs (lastKnot.x - thisKnot.x)
    yDistance = Num.abs (lastKnot.y - thisKnot.y)
    movement = \thisCoord, previousCoord ->
        when Num.compare previousCoord thisCoord is
            EQ -> 0
            LT -> -1
            GT -> 1
    newPosition =
        if xDistance > 1 || yDistance > 1 then
            {
                x: thisKnot.x + movement thisKnot.x lastKnot.x,
                y: thisKnot.y + movement thisKnot.y lastKnot.y,
            }
        else
            thisKnot

    { lastKnot: newPosition, movedKnots: List.append movedKnots newPosition }

State : { head : Position, body : List Position, tail : Position, tailVisited : Set Position }

move : State, Instruction -> State
move = \{ head, body, tail, tailVisited }, { dir, moves } ->
    newHead =
        when dir is
            U -> { x: head.x, y: head.y + 1 }
            D -> { x: head.x, y: head.y - 1 }
            L -> { x: head.x - 1, y: head.y }
            R -> { x: head.x + 1, y: head.y }
    { lastKnot, movedKnots: newBody } = List.walk body { lastKnot: newHead, movedKnots: [] } moveKnot
    newTail = moveKnot { lastKnot, movedKnots: [] } tail |> .lastKnot
    newState = { head: newHead, body: newBody, tail: newTail, tailVisited: Set.insert tailVisited newTail }

    if moves == 1 then newState else move newState { dir, moves: moves - 1 }

startPos = { x: 0, y: 0 }
startState = { head: startPos, body: [], tail: startPos, tailVisited: Set.empty }

part1 = \instructions ->
    List.walk instructions startState move
    |> .tailVisited
    |> Set.len
    |> Num.toStr

part2 = \instructions ->
    List.walk instructions { startState & body: List.repeat startPos 8 } move
    |> .tailVisited
    |> Set.len
    |> Num.toStr
