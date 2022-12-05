interface Util
    exposes [groupsOf, updateAt, updateIfFound]
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


updateIfFound : (a -> a) -> ([Present a, Missing] -> [Present a, Missing])
updateIfFound = \f ->
    \element ->
        when element is
            Present a ->
                Present (f a)
            Missing ->
                Missing
