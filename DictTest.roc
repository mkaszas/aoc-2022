app "dict-test"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [pf.Process, pf.Stdout, pf.Task]
    provides [main] to pf

main =
    myDict : Dict Nat Str
    myDict =
        Dict.single 1 "One"

    _ <- Task.await (Stdout.line "ok")
    Process.exit 0
