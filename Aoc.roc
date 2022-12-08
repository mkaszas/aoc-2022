interface Aoc
    exposes [solveDay, solveDayWithDifferentParsers]
    imports [pf.Stdout, pf.Stderr, pf.File, pf.Path, pf.Task.{ Task }, pf.Process, pf.Http, pf.Env]

solveDay = \{ day, parse, part1, part2 } ->
    solveDayWithDifferentParsers { day, parse1: parse, parse2: parse, part1, part2 }

solveDayWithDifferentParsers : { day : U8, parse1 : Str -> input1, parse2 : Str -> input2, part1 : input1 -> Str, part2 : input2 -> Str } -> Task {} []
solveDayWithDifferentParsers = \{ day, parse1, parse2, part1, part2 } ->
    input <- Task.attempt (File.readUtf8 (dailyInputPath day))

    when input is
        Ok str ->
            part1Sol = part1 (parse1 str)
            part2Sol = part2 (parse2 str)

            _ <- Task.await (Stdout.line "part1: \(part1Sol)")
            _ <- Task.await (Stdout.line "part2: \(part2Sol)")
            Process.exit 0

        Err (FileReadErr _ NotFound) ->
            handleDownload day

        Err _ ->
            _ <- Task.await (Stderr.line "something went wrong!")
            Process.exit 1

dailyInputPath = \d ->
    day = Num.toStr d

    Path.fromStr "input/day\(day).txt"

handleDownload : U8 -> Task {} []
handleDownload = \day ->
    _ <- Task.await (Stdout.line "Input file not found. Downloading file...")
    out <- Task.attempt (downloadInputFile day)
    when out is
        Ok _ ->
            path = Path.display (dailyInputPath day)

            _ <- Task.await (Stdout.line "File created: \(path)")
            Process.exit 0

        Err VarNotFound ->
            _ <- Task.await (Stderr.line "Failed to download input file. `AOC_COOKIE` environment variable not found.")
            Process.exit 1

        Err (HttpError e) ->
            _ <- Task.await (Stderr.line (Http.errorToString e))
            Process.exit 1

        Err (FileWriteErr p e) ->
            path = Path.display p
            writeError = File.writeErrToStr e

            _ <- Task.await (Stderr.line "Error when writing file to \(path): \(writeError)")
            Process.exit 1

downloadInputFile : U8 -> Task {} [VarNotFound, HttpError _, FileWriteErr _ _]
downloadInputFile = \d ->
    day = Num.toStr d
    url = "https://adventofcode.com/2022/day/\(day)/input"

    aocCookie <- Task.await (Env.var "AOC_COOKIE")
    headers = [Http.header "cookie" aocCookie]
    def = Http.defaultRequest
    request = { def & url, headers }

    inputContents <- Task.await (Task.mapFail (Http.send request) HttpError)
    File.writeUtf8 (dailyInputPath d) inputContents
