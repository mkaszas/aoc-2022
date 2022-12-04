app "day-2"
    packages { pf: "examples/cli/cli-platform/main.roc" }
    imports [Aoc]
    provides [main] to pf

main = Aoc.solveDayWithDifferentParsers { day: 2, parse1, parse2, part1, part2 }

Symbol : [Rock, Paper, Scissors]
Outcome : [Lose, Draw, Win]
Game : { opp : Symbol, me : Symbol }
GameOutcome : { opp : Symbol, outcome : Outcome }

parse1 : Str -> List Game
parse1 = \str ->
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

    gameResult =
        if me == opp then
            Draw
        else if me == next opp then
            Win
        else
            Lose

    gameScore =
        when gameResult is
            Lose -> 0
            Draw -> 3
            Win -> 6

    mySymbol + gameScore

next : Symbol -> Symbol
next = \s ->
    when s is
        Rock -> Paper
        Paper -> Scissors
        Scissors -> Rock

parse2 : Str -> List GameOutcome
parse2 = \str ->
    Str.split str "\n"
        |> List.keepOks parseGameOutcome

parseGameOutcome : Str -> Result GameOutcome _
parseGameOutcome = \str ->
    s = Str.split str " "

    oppStr <- Result.try (List.get s 0)
    opp <- Result.try (parseSymbol oppStr)
    outcomeStr <- Result.try (List.get s 1)
    outcome <- Result.try (parseOutcome outcomeStr)

    Ok { opp, outcome }

parseOutcome = \s ->
    when s is
        "X" -> Ok Lose
        "Y" -> Ok Draw
        "Z" -> Ok Win
        _ -> Err BadOutcome

handFromOutcome = \{ opp, outcome } ->
    when outcome is
        Win -> next opp
        Draw -> opp
        Lose -> next (next opp)

part2 : List GameOutcome -> Str
part2 = \outcomes ->
    List.map outcomes (\oc -> { opp: oc.opp, me: handFromOutcome oc })
        |> List.map score
        |> List.sum
        |> Num.toStr
