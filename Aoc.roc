interface Aoc
    exposes [solveDay, solveDayWithDifferentParsers]
    imports [pf.Stdout, pf.Stderr, pf.File, pf.Path, pf.Program.{ Program }, pf.Task.{Task}]

solveDay = \{ day, parse, part1, part2 } ->
    solveDayWithDifferentParsers {day, parse1: parse, parse2: parse, part1, part2}


solveDayWithDifferentParsers : { day: U8, parse1: Str -> input1, parse2: Str -> input2, part1 : input1 -> Str, part2 : input2 -> Str } -> Program
solveDayWithDifferentParsers = \{ day, parse1, parse2, part1, part2 } ->
    mainTask : Task _ [] _
    mainTask =
        input <- Task.attempt (readDailyInput day)

        when input is
            Ok str ->
                part1Sol = part1 (parse1 str)
                part2Sol = part2 (parse2 str)

                _ <- Task.await (Stdout.line "part1: \(part1Sol)")
                Stdout.line "part2: \(part2Sol)"
                    |> Program.exit 0

            Err _ ->
                Stderr.line "something went wrong!"
                    |> Program.exit 1

    Program.noArgs mainTask

readDailyInput : U8 -> Task Str _ _
readDailyInput = \dayN ->
    day = Num.toStr dayN
    File.readUtf8 (Path.fromStr "input/day\(day).txt")