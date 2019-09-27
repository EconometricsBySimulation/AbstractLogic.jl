function testcall(userinput; verbose=true)

    testname = match(r"t(?:est)?\((.*)\)", userinput).captures[1]

    folders = readdir()
    ("examples" ∈ folders) && (testfiles = readdir("examples/repl/"))
    !("examples" ∈ folders) && (testfiles = readdir("../examples/repl/"))

    testfiles = testfiles .|> x -> replace(x, r".jl$"=>"") |> lowercase

    occursin(r"^[0-9]{1,2}$", testname) && (testname = testfiles[parse(Int64, testname)])

    (testname == "") && return printmarkdown("Tests available: `" * join(testfiles, "`, `") *
        "`\n \n `abstractlogic> t(testname)`")

    !(testname ∈ testfiles) &&
      return replthrow("\"$testname\" not found. Tests available: " * join(testfiles, ", "))

    ("examples" ∈ folders) && (testread = readlines("examples/repl/$testname.jl"))
    !("examples" ∈ folders) && (testread = readlines("../examples/repl/$testname.jl"))

    testread = (testread.|> x -> strip(x)) |> x -> x[x .!= ""] |> x -> x[(x .|> y -> y[1]) .!= '#']

    codestart = findall(y -> occursin(r"^Start the repl", y), testread)

    (length(codestart) == 0) && return replthrow("\"Start the repl\" not found!")
    (length(codestart) > 1 ) && return replthrow("Multiple \"Start the repl\" found!")

    testlines = testread[(codestart[1]+1):end]

    for v in testlines
        abstractlogic(v)
        replerror && throw("")
    end
end
