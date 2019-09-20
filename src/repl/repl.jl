using ReplMaker, Markdown

let
    keys() = println(join(replset.keys, ", "))

    global showcommandlist()  = commandlist
    global returnlogicset() = logicset
    global showcmdlocation() = cmdlocation
    global showsetlocation() = setlocation
    global showuserinput() = userinput
    global showcommandhistory() = commandhistory
    global showlogichistory() = logichistory

    dashboardshow = false
    global dashboard() = dashboardshow
    global dashboard!() = dashboardshow = !dashboardshow

    global replset = LogicalCombo()

    global setreplset!(x) = replset = x
    global returnreplset() = replset

    commandlist  = [String[]]
    commandlistprint = false

    preserver = missing

    global activehistory = History()
    global setactivehistory!(x) = activehistory = x
    global pushactivehistory!(x) = push!(activehistory, x)
    global returnactivehistory() = activehistory

    global sessionhistory = History()
    global setsessionhistory!(x) = sessionhistory = x
    global pushsessionhistory!(x) = push!(sessionhistory, x)
    global returnsessionhistory() = sessionhistory

    global replcmdverbose = true
    global replverboseall = true

    global replerror = false
    global replthrow(x) = (println(x) ; replerror = true)
    global returnreplerror() = replerror

    global function abstractlogic(replinput; returnactive = false)
        replerror = false
        userinput = replinput |> strip |> tounicode

        occursin("[clear]", userinput) && ALclear()
        userinput = replace(userinput, "[clear]"=>"")

        replcmdverbose = !occursin("[silent]", userinput)
        userinput = replace(userinput, "[silent]"=>"")

        if occursin(";", userinput)
          for v in split(userinput, ";");
              abstractlogic(v)
          end
          userinput = ""
        end

        # println("User input {$userinput}")
        (occursin("t(", userinput)) && (userinput = testcall(userinput))

        if strip(userinput) == ""                         nothing()
        elseif occursin(r"^(\?|help)", userinput)         help(userinput)
        elseif occursin(r"^show$", userinput)             ALshow()
        elseif occursin(r"^showall$", userinput)          showall()
        elseif userinput ∈ ["back", "b"]                  ALback()
        elseif occursin(r"compare ", userinput)           ALcompare(userinput)
        elseif userinput ∈ ["discover", "d"]              discover(LogicalCombo())
        elseif occursin(r"^export( as){0,1} ", userinput) ALexport(userinput)
        elseif userinput ∈ ["next", "n", "f"]             ALnext()
        elseif occursin(r"^import ", userinput)           ALimport(userinput)
        elseif occursin(r"^dash(board)?$", userinput)     dashboard!()
        elseif userinput ∈ ["history", "h"]               Alhistory()
        elseif occursin(r"^command[ ]*list", userinput)   itemprint(commandlist)
        elseif userinput ∈ ["logicset","ls"]              itemprint(logicset)
        elseif userinput == "clearall"                    ALclearall()
        elseif occursin(r"^clear[ ]*$", userinput)        ALclear()
        elseif occursin(r"^range", userinput)             ALrange(userinput)
        elseif userinput ∈ ["keys", "k"]                  keys()
        elseif userinput == "preserve"                    ALpreserve()
        elseif userinput == "restore"                     restore()
        elseif userinput == "silence"                     replverboseall = false
        elseif userinput == "noisy"                       replverboseall = true

        elseif occursin(r"^(prove|all|check|any|✓)", userinput) ALcheck(userinput)
        elseif occursin(r"^search", userinput)            ALsearch(userinput)
        else                                              ALparse(userinput, replset)
        end
        returnactive && return replset
        nothing
    end

    function ALclearall()
        ALclear(verbose = false)
        sessionhistory = History()

        println("Clearing Everything!")
    end

    function ALimport(userinput)

        imports = Symbol(strip(replace(userinput, r"^import "=>"")))

        !(imports ∈ names(Main)) && (println("$imports not found!"); return)

        imported = getfield(Main, imports)
        !isa(imported, LogicalCombo) && (println("$imports not a LogicalCombo!"); return)

        replset = imported

        activehistory = History()

        push!(activehistory, replset)
        push!(sessionhistory, imported)

        println("Importing $imported - " * reportfeasible())
    end


    function ALpreserve(; verbose = true)
        preserver = activehistory
        verbose && println("Preserving State")
    end

    function restore(; verbose = true)
        (preserver === missing) && (println("Nothing to restore"); return)

        replset = activelogicset(preserver)

        activehistory = preserver

        push!(sessionhistory, replset)

        verbose && println("Restoring State - " * reportfeasible())
    end



    global reportfeasible() = "Feasible Outcomes: $(nfeasible(replset)) \t Perceived Outcomes: $(percievedfeasible(replset)) \t:$(joinsample(replset))"
    global lastcommand() = "Last command: \"$(replset.commands[end])\""
    joins(x) = length(x) > 0 ? join(x, " ") : x
    joinsample = (joins ∘ sample)

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
