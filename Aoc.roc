interface Aoc
    exposes [dayProgram, readDailyInput]
    imports [pf.Stdout, pf.Stderr, pf.File, pf.Path, pf.Program.{ Program }, pf.Task.{Task}]

dayProgram : { parse: Task input _ _, part1 : input -> Str, part2 : input -> Str } -> Program
dayProgram = \{ parse, part1, part2 } ->
    mainTask =
        input <- Task.attempt parse

        when input is
            Ok inp ->
                part1Sol = part1 inp
                part2Sol = part2 inp

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