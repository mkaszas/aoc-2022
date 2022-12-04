app "day-2"
    packages { pf: "examples/cli/cli-platform/main.roc" }
    imports [Aoc]
    provides [main] to pf

main = Aoc.solveDay { day: 2, parse, part1, part2 }

Symbol : [Rock, Paper, Scissors]
Game : { opp : Symbol, me : Symbol }

parse : Str -> List Game
parse = \str ->
    Str.split str "\n"
        |> List.keepOks parseGame


parseGame : Str -> Result Game _
parseGame = \gameStr ->
    s = Str.split gameStr " "

    oppStr <- Result.try (List.get s 0)
    opp <- Result.try (parseSymbol oppStr)
    meStr <- Result.try (List.get s 1)
    me <- Result.try (parseSymbol meStr)

    Ok { opp, me }


parseSymbol : Str -> Result Symbol [BadSymbol]*
parseSymbol = \s ->
    when s is
        "A" | "X" -> Ok Rock
        "B" | "Y" -> Ok Paper
        "C" | "Z" -> Ok Scissors
        _ -> Err BadSymbol

part1 : List Game -> Str
part1 = \games ->
    List.map games score
        |> List.sum
        |> Num.toStr


score : Game -> U32
score = \{ opp, me } ->
    mySymbol =
        when me is
            Rock -> 1
            Paper -> 2
            Scissors -> 3

    gameScore =
        if me == opp then
            3
        else if me == next opp then
            6
        else
            0

    mySymbol + gameScore

next : Symbol -> Symbol
next = \s ->
    when s is
        Rock -> Paper
        Paper -> Scissors
        Scissors -> Rock


convertOutcome = \{ opp, me } ->
    when me is
        Rock -> next (next opp)
        Paper -> opp
        Scissors -> next opp


part2 : List Game -> Str
part2 = \games ->
    List.map games (\oc -> { oc & me: (convertOutcome oc) })
        |> List.map score
        |> List.sum
        |> Num.toStr
