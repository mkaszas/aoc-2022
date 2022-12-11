app "day-11"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [Aoc, Day11Input, Util]
    provides [main] to pf

main = Aoc.solveDay { day: 11, parse, part1, part2 }

parse = \_ -> Day11Input.input

Monkey : { items : List U64, operation : U64 -> U64, divCheck : U64, next : Bool -> Nat, inspected : Nat }

throwItem : Monkey, (U64 -> U64) -> (List Monkey, U64 -> List Monkey)
throwItem = \{ operation, divCheck, next }, f ->
    \monkeys, item ->
        # all numbers are prime, so LCM == their product
        lcm = List.map monkeys .divCheck |> List.product
        { nextIndex, nextItem } =
            operation item
            |> f
            |> Num.rem lcm
            |> \n -> { nextIndex: next (Num.rem n divCheck == 0), nextItem: n }

        Util.updateAt monkeys nextIndex (\monkey -> { monkey & items: List.append monkey.items nextItem })

runMonkey : (U64 -> U64) -> (List Monkey, Nat -> List Monkey)
runMonkey = \f ->
    \monkeys, monkeyIndex ->
        List.get monkeys monkeyIndex
        |> Result.map (\monkey -> List.walk monkey.items monkeys (throwItem monkey f))
        |> Result.withDefault monkeys
        |> Util.updateAt monkeyIndex (\monkey -> { monkey & items: [], inspected: monkey.inspected + List.len monkey.items })

round : (U64 -> U64) -> (List Monkey -> List Monkey)
round = \f ->
    \monkeys ->
        List.range { start: At 0, end: Before (List.len monkeys) }
        |> List.walk monkeys (runMonkey f)

part1 = \monkeys ->
    Util.applyTimes monkeys (round \n -> n // 3) 20
    |> List.map .inspected
    |> List.sortDesc
    |> List.takeFirst 2
    |> List.product
    |> Num.toStr

part2 = \monkeys ->
    Util.applyTimes monkeys (round \n -> n) 10_000
    |> List.map .inspected
    |> List.sortDesc
    |> List.takeFirst 2
    |> List.product
    |> Num.toStr
