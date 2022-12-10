app "day-7"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [Aoc]
    provides [main] to pf

main = Aoc.solveDay { day: 7, parse: parse, part1, part2 }

FileTree : [Directory Str (List FileTree), File Str U64]
Cmd : [Cd [Up, Down Str], Ls (List FileTree)]

parse : Str -> FileTree
parse = \s ->
    Str.split s "\n$"
    |> List.dropFirst
    |> List.map Str.trim
    |> List.keepOks parseCommand
    |> buildFileTree

parseCommand : Str -> Result Cmd _
parseCommand = \s ->
    if Str.startsWith s "ls" then
        items = Str.split s "\n" |> List.dropFirst

        Ok (Ls (List.keepOks items parseItem))
    else
        arg <- Result.map (Str.replaceFirst s "cd " "")
        Cd (if arg == ".." then Up else Down arg)

parseItem : Str -> Result FileTree _
parseItem = \s ->
    when Str.split s " " is
        ["dir", dirName] -> Ok (Directory dirName [])
        [fileSize, fileName] -> Result.map (Str.toU64 fileSize) (\size -> File fileName size)
        _ -> Err BadItemFormat

buildFileTree : List Cmd -> FileTree
buildFileTree = \cmds ->
    List.walk cmds { workingDir: [], fileTree: Directory "/" [] } processCommand
    |> .fileTree

State : { workingDir : List Str, fileTree : FileTree }

processCommand : State, Cmd -> State
processCommand = \{ workingDir, fileTree }, cmd ->
    when cmd is
        Cd Up -> { workingDir: List.dropLast workingDir, fileTree }
        Cd (Down dirName) -> { workingDir: List.append workingDir dirName, fileTree }
        Ls items -> { workingDir, fileTree: setChildrenAt fileTree workingDir items }

setChildrenAt : FileTree, List Str, List FileTree -> FileTree
setChildrenAt = \fileTree, workingDir, items ->
    when workingDir is
        [topLevel, ..] ->
            subDir <- updateSubdir fileTree topLevel
            setChildrenAt subDir (List.dropFirst workingDir) items

        [] -> updateChildren fileTree (\_ -> List.concat [] items)

updateSubdir : FileTree, Str, (FileTree -> FileTree) -> FileTree
updateSubdir = \fileTree, dirName, update ->
    children <- updateChildren fileTree
    childTree <- List.map children
    when childTree is
        Directory subDirName _ if subDirName == dirName -> update childTree
        _ -> childTree

updateChildren : FileTree, (List FileTree -> List FileTree) -> FileTree
updateChildren = \fileTree, update ->
    when fileTree is
        File _ _ -> fileTree
        Directory dirName children -> Directory dirName (update children)

getFileSize = \fileTree ->
    when fileTree is
        File _ size -> size
        Directory _ _ -> 0

subDirectorySizes : FileTree -> List U64
subDirectorySizes = \fileTree ->
    when fileTree is
        File _ _ -> []
        Directory _ children ->
            subDirs = List.map children subDirectorySizes
            topLevelSizes = List.keepOks subDirs List.last
            fileSizes = List.map children getFileSize
            thisDirSize = List.sum topLevelSizes + List.sum fileSizes

            List.join subDirs
            |> List.append thisDirSize

part1 = \fileTree ->
    subDirectorySizes fileTree
    |> List.keepIf (\n -> n <= 100_000)
    |> List.sum
    |> Num.toStr

part2 = \fileTree ->
    diskSpace = 70_000_000
    updateSize = 30_000_000
    allSizes = subDirectorySizes fileTree
    rootDirSize = allSizes |> List.last |> Result.withDefault 0
    freeSpace = diskSpace - rootDirSize
    minimumNeeded = updateSize - freeSpace

    allSizes
    |> List.keepIf (\n -> n >= minimumNeeded)
    |> List.min
    |> Result.withDefault 0
    |> Num.toStr
