using ReplMaker, Markdown

let
    keys() = println(join(replset.keys, ", "))

    # global showcommandlist()  = commandlist
    # global returnlogicset() = logicset
    # global showcmdlocation() = cmdlocation
    # global showsetlocation() = setlocation
    # global showuserinput() = userinput
    # global showcommandhistory() = commandhistory
    # global showlogichistory() = logichistory

    dashboard = false

    global replset = LogicalCombo()

    global setreplset!(x) = replset = x
    global returnreplset() = replset

    # commandlist  = [String[]]
    # commandlistprint = false

    preserver = missing

    global activehistory = History()
    global setactivehistory!(x) = activehistory = x
    global pushactivehistory!(x) = push!(activehistory, x)

    global sessionhistory = History()
    global setsessionhistory!(x) = sessionhistory = x
    global pushsessionhistory!(x) = push!(sessionhistory, x)

    verboseall = true

    global replerror = false
    global replthrow(x) = (println(x) ; replerror = true)
    global returnreplerror() = replerror

    global preserver = nothing
    global setpreserver!(x) = preserver = x

    global function abstractlogic(replinput; returnactive = false, verbose = true)
        replerror = false
        userinput = replinput |> strip |> tounicode

        verbose &= verboseall
        verbose &= !occursin("[silent]", userinput)
        userinput = replace(userinput, "[silent]"=>"")

        occursin("[clear]", userinput) && ALclear(verbose = verbose)
        userinput = replace(userinput, "[clear]"=>"")

        if occursin(";", userinput)
          for v in split(userinput, ";");
              abstractlogic(v, verbose=verbose)
          end
          userinput = "" # replace with return?
        end

        # println("User input {$userinput}")
        (occursin("t(", userinput)) && (userinput = testcall(userinput))

        if strip(userinput) == ""                         nothing(verbose = verbose)
        elseif occursin(r"^(\?|help)", userinput)         help(userinput)
        elseif occursin(r"^show$", userinput)             ALshow()
        elseif occursin(r"^showall$", userinput)          showall()
        elseif userinput ∈ ["back", "b"]                  ALback()
        elseif occursin(r"compare ", userinput)           ALcompare(userinput)
        elseif userinput ∈ ["discover", "d"]              discover(LogicalCombo())
        elseif occursin(r"^export( as){0,1} ", userinput) ALexport(userinput)
        elseif userinput ∈ ["next", "n", "f"]             ALnext(verbose = verbose)
        elseif occursin(r"^import ", userinput)           ALimport(userinput)
        elseif occursin(r"^dash(board)?$", userinput)     dashboard = !dashboard
        elseif userinput ∈ ["history", "h"]               Alhistory()
        elseif userinput ∈ ["History", "H"]               Alhistory(sessionhistory=true)
        elseif userinput ∈ ["logicset","ls"]              itemprint(logicset)
        elseif userinput ∈ ["clearall", "Clear"]          ALClear()
        elseif occursin(r"^clear[ ]*$", userinput)        ALclear()
        elseif occursin(r"^range", userinput)             ALrange(userinput)
        elseif userinput ∈ ["keys", "k"]                  keys()
        elseif userinput == "preserve"                    ALpreserve()
        elseif userinput == "restore"                     ALrestore()
        elseif userinput == "silence"                     verboseall = false
        elseif userinput == "noisy"                       verboseall = true

        elseif occursin(r"^(prove|all|check|any|✓)", userinput) ALcheck(userinput)
        elseif occursin(r"^search", userinput)            ALsearch(userinput)
        else                                              ALparse(userinput, replset)
        end
        returnactive && return replset
        nothing
    end

end
"""
    abstractlogic(; returnactive = false)

Call the REPL from Julia. Setting returnactive to *true* returns the last active
logicset.

```julia
julia> abstractlogic("a, b, c in 1:3")
a, b, c ∈ 1:3            feasible outcomes 27 ✓          :1 1 3

julia> abstractlogic("a == b")
a == b                   feasible outcomes 9 ✓           :3 3 3

julia> abstractlogic("a > c")
a > c                    feasible outcomes 3 ✓           :3 3 1

julia> abstractlogic("c != 1")
c != 1                   feasible outcomes 1 ✓✓          :3 3 2

```
"""
abstractlogic = abstractlogic
