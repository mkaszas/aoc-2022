interface Util
    exposes [groupsOf, updateAt, splitExclusive, applyTimes, walk2]
    imports []

groupsOf : List a, Nat -> List (List a)
groupsOf = \list, size ->
    if size <= 0 then
        []
    else
        go = \xs, acc ->
            if List.isEmpty xs then
                acc
            else
                thisGroup = List.takeFirst xs size

                if size == List.len thisGroup then
                    rest = List.drop xs size

                    go rest (List.append acc thisGroup)
                else
                    acc

        go list []

updateAt : List a, Nat, (a -> a) -> List a
updateAt = \list, index, fn ->
    result =
        { before, others } = List.split list index

        element <- Result.map (List.first others)
        List.concat before (List.prepend (List.dropFirst others) (fn element))

    Result.withDefault result list

splitExclusive : List a, Nat -> { left : List a, right : List a }
splitExclusive = \list, index ->
    { before, others } = List.split list index

    { left: before, right: List.dropFirst others }

applyTimes : a, (a -> a), Nat -> a
applyTimes = \a, f, n ->
    if n == 0 then a else applyTimes (f a) f (n - 1)

walk2 : List a, b, (a, a, b -> b) -> b
walk2 = \list, state, fn ->
    when list is
        [fst, snd, ..] -> walk2 (List.dropFirst list) (fn fst snd state) fn
        _ -> state
