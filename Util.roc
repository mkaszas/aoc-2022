interface Util
    exposes [groupsOf]
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
