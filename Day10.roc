app "day-10"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [Aoc, Util]
    provides [main] to pf

main = Aoc.solveDay { day: 10, parse, part1, part2 }

Instruction : [Noop, AddX I32]

parse : Str -> State
parse = \s ->
    Str.split s "\n"
    |> List.keepOks parseInstruction
    |> buildState

parseInstruction : Str -> Result Instruction _
parseInstruction = \s ->
    when Str.split s " " is
        ["noop"] -> Ok Noop
        ["addx", n] -> Result.map (Str.toI32 n) AddX
        _ -> Err BadInstructionFormat

State : { pastValues : List I32, drawnPixels : List Str, registerX : I32, drawPosition : U8 }

drawPixel : I32, U8 -> Str
drawPixel = \xValue, drawPosition ->
    if Num.abs (xValue - Num.toI32 drawPosition) < 2 then "█" else " "

step : State, Instruction -> State
step = \{ pastValues, drawnPixels, registerX, drawPosition }, instruction ->
    when instruction is
        Noop ->
            {
                pastValues: List.append pastValues registerX,
                drawnPixels: List.append drawnPixels (drawPixel registerX drawPosition),
                registerX,
                drawPosition: Num.rem (drawPosition + 1) 40,
            }

        AddX n ->
            {
                pastValues: List.concat pastValues [registerX, registerX + n],
                drawnPixels: List.concat drawnPixels [drawPixel registerX drawPosition, drawPixel registerX (drawPosition + 1)],
                registerX: registerX + n,
                drawPosition: Num.rem (drawPosition + 2) 40,
            }

initState = { pastValues: [1], drawnPixels: [], registerX: 1, drawPosition: 0 }
buildState = \instructions -> List.walk instructions initState step

part1 = \{ pastValues } ->
    [20, 60, 100, 140, 180, 220]
    |> List.keepOks (\c -> List.get pastValues (c - 1) |> Result.map (\x -> x * Num.toI32 c))
    |> List.sum
    |> Num.toStr

part2 = \{ drawnPixels } ->
    Util.groupsOf drawnPixels 40
    |> List.map (\s -> Str.joinWith s "")
    |> Str.joinWith "\n"
    |> Str.withPrefix "\n"
