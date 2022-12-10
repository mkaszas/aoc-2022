app "day-4"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [Aoc]
    provides [main] to pf

main = Aoc.solveDay { day: 4, parse, part1, part2 }

Range : [Range U8 U8]
Pair : [Pair Range Range]

parse : Str -> List Pair
parse = \inputStr ->
    Str.split inputStr "\n"
    |> List.keepOks parsePair

parsePair : Str -> Result Pair _
parsePair = \str ->
    when Str.split str "," is
        [fst, snd] ->
            first <- Result.try (parseRange fst)
            second <- Result.try (parseRange snd)
            Ok (Pair first second)

        _ ->
            Err BadRowFormat

parseRange : Str -> Result Range _
parseRange = \str ->
    when Str.split str "-" is
        [s, e] ->
            start <- Result.try (Str.toU8 s)
            end <- Result.try (Str.toU8 e)
            Ok (Range start end)

        _ ->
            Err BadListFormat

contains : Pair -> Bool
contains = \Pair (Range start1 end1) (Range start2 end2) ->
    (start1 <= start2 && end1 >= end2)
    || (start2 <= start1 && end2 >= end1)

part1 = \pairs ->
    List.countIf pairs contains
    |> Num.toStr

distinct : Pair -> Bool
distinct = \Pair (Range start1 end1) (Range start2 end2) ->
    end1 < start2 || end2 < start1

part2 = \pairs ->
    List.countIf pairs (\p -> !(distinct p))
    |> Num.toStr
