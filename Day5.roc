app "day-5"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [Aoc, Util]
    provides [main] to pf

main = Aoc.solveDay { day: 5, parse, part1, part2 }

# Nobody has time for parsing THAT!
# might come back and write a parser, but for now, this is small enough to copy by hand
startingArrangement =
    [["R", "C", "H"], ["F", "S", "L", "H", "J", "B"], ["Q", "T", "J", "H", "D", "M", "R"], ["J", "B", "Z", "H", "R", "G", "S"], ["B", "C", "D", "T", "Z", "F", "P", "R"], ["G", "C", "H", "T"], ["L", "W", "P", "B", "Z", "V", "N", "S"], ["C", "G", "Q", "J", "R"], ["S", "F", "P", "H", "R", "T", "D", "L"]]

State : { stacks : Stacks, moves : List Move }
Stacks : List (List Str)
Move : { quantity : Nat, from : Nat, to : Nat }

parse : Str -> State
parse = \inputStr ->
    moves =
        Str.split inputStr "\n\n"
        |> List.get 1
        |> Result.withDefault ""
        |> Str.split "\n"
        |> List.keepOks parseMove

    { stacks: startingArrangement, moves }

parseMove : Str -> Result Move _
parseMove = \str ->
    s1 <- Result.try (Str.replaceFirst str "move " "")
    { before: rawQuantity, after: s2 } <- Result.try (Str.splitFirst s1 " from ")
    { before: rawFrom, after: rawTo } <- Result.try (Str.splitFirst s2 " to ")
    quantity <- Result.try (Str.toNat rawQuantity)
    from <- Result.try (Str.toNat rawFrom)
    to <- Result.try (Str.toNat rawTo)

    Ok { quantity, from, to }

makeMove : { moveAll : Bool } -> (Stacks, Move -> Result Stacks _)
makeMove = \{ moveAll } ->
    \stacks, { quantity, from, to } ->
        fromStack <- Result.map (List.get stacks (from - 1))
        movedItems = List.takeFirst fromStack quantity
        placedItems = if moveAll then movedItems else List.reverse movedItems

        Util.updateAt stacks (from - 1) (\s -> List.drop s quantity)
        |> Util.updateAt (to - 1) (\s -> List.concat placedItems s)

part1 = \{ stacks, moves } ->
    List.walkTry moves stacks (makeMove { moveAll: Bool.false })
    |> Result.withDefault []
    |> List.keepOks List.first
    |> Str.joinWith ""

part2 = \{ stacks, moves } ->
    List.walkTry moves stacks (makeMove { moveAll: Bool.true })
    |> Result.withDefault []
    |> List.keepOks List.first
    |> Str.joinWith ""
