app "day-13"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [Aoc, Day13Input]
    provides [main] to pf

main = Aoc.solveDay { day: 13, parse, part1, part2 }

Packet : [Single U8, Array (List Packet)]
Pair : [Pair Packet Packet]

parse : Str -> List Pair
parse = \_ -> Day13Input.input

compare : Packet, Packet -> [LT, GT, EQ]
compare = \left, right ->
    when T left right is
        T (Single ln) (Single rn) -> Num.compare ln rn
        T (Array ll) (Array rl) ->
            firstLeft = List.first ll
            firstRight = List.first rl

            when T firstLeft firstRight is
                T (Err _) (Err _) -> EQ
                T (Err _) (Ok _) -> LT
                T (Ok _) (Err _) -> GT
                T (Ok ln) (Ok rn) ->
                    if compare ln rn == EQ then
                        compare (Array (List.dropFirst ll)) (Array (List.dropFirst rl))
                    else
                        compare ln rn

        T (Single ln) (Array rl) -> compare (Array [Single ln]) (Array rl)
        T (Array ll) (Single rn) -> compare (Array ll) (Array [Single rn])

expect compare (Array [Single 1, Single 1, Single 3, Single 1, Single 1]) (Array [Single 1, Single 1, Single 5, Single 1, Single 1]) == LT
expect compare (Array [Array [Single 1], Array [Single 2, Single 3, Single 4]]) (Array [Array [Single 1], Single 4]) == LT
expect compare (Array [Single 9]) (Array [Array [Single 8, Single 7, Single 6]]) == GT
expect compare (Array [Array [Single 4, Single 4], Single 4, Single 4]) (Array [Array [Single 4, Single 4], Single 4, Single 4, Single 4]) == LT
expect compare (Array [Single 7, Single 7, Single 7, Single 7]) (Array [Single 7, Single 7, Single 7]) == GT
expect compare (Array []) (Array [Single 3]) == LT
expect compare (Array [Array [Array []]]) (Array [Array []]) == GT
expect compare (Array [Single 1, Array [Single 2, Array [Single 3, Array [Single 4, Array [Single 5, Single 6, Single 7]]]], Single 8, Single 9]) (Array [Single 1, Array [Single 2, Array [Single 3, Array [Single 4, Array [Single 5, Single 6, Single 0]]]], Single 8, Single 9]) == GT

part1 = \pairs ->
    List.mapWithIndex pairs (\p, i -> T i p)
    |> List.keepIf (\T _ (Pair l r) -> compare l r == LT)
    |> List.map (\T i _ -> i + 76)
    |> List.sum
    |> Num.toStr

divider1 = Array [Array [Single 2]]
divider2 = Array [Array [Single 6]]

part2 = \pairs ->
    finalList : List Packet
    finalList =
        List.joinMap pairs (\Pair l r -> [l, r])
        |> List.concat [divider1, divider2]
        |> List.sortWith compare

    div1Pos = List.findFirstIndex finalList (\p -> p == divider1) |> Result.withDefault 0
    div2Pos = List.findFirstIndex finalList (\p -> p == divider2) |> Result.withDefault 0

    (div1Pos + 1)
    * (div2Pos + 1)
    |> Num.toStr
