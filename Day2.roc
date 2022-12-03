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

# score:
# 1 for Rock, 2 for Paper, and 3 for Scissors
# + 0 if you lost, 3 if the round was a draw, and 6 if you won.

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
        when opp is
            Rock ->
                when me is
                    Rock -> Draw
                    Paper -> Win
                    Scissors -> Lose
            Paper ->
                when me is
                    Rock -> Lose
                    Paper -> Draw
                    Scissors -> Win
            Scissors ->
                when me is
                    Rock -> Win
                    Paper -> Lose
                    Scissors -> Draw
    gameScore =
        when gameResult is
            Lose -> 0
            Draw -> 3
            Win -> 6

    mySymbol + gameScore



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
    when opp is
        Rock ->
            when outcome is
                Win -> Paper
                Draw -> Rock
                Lose -> Scissors
        Paper ->
            when outcome is
                Win -> Scissors
                Draw -> Paper
                Lose -> Rock
        Scissors ->
            when outcome is
                Win -> Rock
                Draw -> Scissors
                Lose -> Paper

part2 : List GameOutcome -> Str
part2 = \outcomes ->
    List.map outcomes (\oc -> { opp: oc.opp, me: handFromOutcome oc })
        |> List.map score
        |> List.sum
        |> Num.toStr