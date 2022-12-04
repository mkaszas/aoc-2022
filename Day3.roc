app "day-3"
    packages { pf: "../basic-cli/src/main.roc" }
    imports [Aoc, Util]
    provides [main] to pf

main = Aoc.solveDay { day: 3, parse, part1, part2 }

Sack : [Sack (List U32) (List U32)]

parse : Str -> List Sack
parse = \str ->
    Str.split str "\n"
    |> List.map parseSack

parseSack : Str -> Sack
parseSack = \s ->
    allItems = List.map (Str.toScalars s) scalarToScore
    compartmentSize = List.len allItems // 2
    left = List.takeFirst allItems compartmentSize
    right = List.drop allItems compartmentSize

    Sack left right

scalarToScore : U32 -> U32
scalarToScore = \n ->
    if n >= 97 then n - 96 else n - 38

commonItem : Sack -> Result U32 _
commonItem = \Sack l1 l2 ->
    List.findFirst l1 (\s -> List.contains l2 s)

part1 = \sacks ->
    List.keepOks sacks commonItem
    |> List.sum
    |> Num.toStr

sacksToGroups = \sacks ->
    List.map sacks (\Sack l1 l2 -> List.concat l1 l2)
    |> Util.groupsOf 3

findCommonInAll : List (List a) -> Result a _ | a has Eq
findCommonInAll = \lists ->
    compList <- Result.try (List.first lists)
    element <- List.findFirst compList

    rest = List.dropFirst lists

    List.all rest (\l -> List.contains l element)

part2 = \sacks ->
    sacksToGroups sacks
    |> List.keepOks findCommonInAll
    |> List.sum
    |> Num.toStr
