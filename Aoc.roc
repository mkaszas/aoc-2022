interface Aoc
    exposes [solveDay, solveDayWithDifferentParsers]
    imports [pf.Stdout, pf.Stderr, pf.File, pf.Path, pf.Task.{ Task }, pf.Process]

solveDay = \{ day, parse, part1, part2 } ->
    solveDayWithDifferentParsers { day, parse1: parse, parse2: parse, part1, part2 }

solveDayWithDifferentParsers : { day : U8, parse1 : Str -> input1, parse2 : Str -> input2, part1 : input1 -> Str, part2 : input2 -> Str } -> Task {} []
solveDayWithDifferentParsers = \{ day, parse1, parse2, part1, part2 } ->
    input <- Task.attempt (readDailyInput day)

    when input is
        Ok str ->
            part1Sol = part1 (parse1 str)
            part2Sol = part2 (parse2 str)

            _ <- Task.await (Stdout.line "part1: \(part1Sol)")
            _ <- Task.await (Stdout.line "part2: \(part2Sol)")
            Process.exit 0

        Err _ ->
            _ <- Task.await (Stderr.line "something went wrong!")
            Process.exit 1

readDailyInput : U8 -> Task Str _
readDailyInput = \dayN ->
    day = Num.toStr dayN

    File.readUtf8 (Path.fromStr "input/day\(day).txt")
