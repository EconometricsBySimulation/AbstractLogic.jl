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
    global returnreplset() = replset
    commandlist  = [String[]]

    commandlistprint = false

    preserver = missing
    preservercommandlist = missing
    preservercmdlocation = missing
    preservercommandhistory = missing
    preserverlogichistory = missing
    preserverfeasiblehistory = missing

    commandhistory = String["#Session Initiated"]

    global activehistory = History()
    global sessionhistory = History()

    feasiblehistory = [0]
    logichistory = [replset]
    logicset     = [replset]

    cmdlocation = 1
    setlocation = 1

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
        else                                              replset = ALparse(userinput)
        end
        returnactive && return replset
        nothing
    end

    function ALclear(; verbose = true)
        activehistory = History()

        replset = activelogicset(activehistory)
        push!(sessionhistory, activelogicset(activehistory))

        verbose && replcmdverbose && replverboseall && println("Clearing Activeset")
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


    function ALparse(userinput, logicset)
        (sum(logicset[:])==0) && !occursin(r"∈", userinput) &&
          return replthrow("You are working with an empty set! Try inputing: a,b,c in 1:3")

        try
          logicset = logicalparse(userinput, logicset = replset,
                                      verbose = replcmdverbose & replverboseall)
        catch ex
          replthrow("\ncommand Failed! $ex")
          return logicset
        end

        push!(activehistory, logicset)
        update!(sessionhistory, logicset)

        return logicset

    end

    function ALpreserve()
        # preservercommandlist = copy(commandlist[setlocation])
        # push!(commandlist[setlocation], "#preserve")
        # preserver = replset
        # preservercmdlocation = cmdlocation
        # preservercommandhistory = copy(commandhistory)
        # preserverlogichistory = copy(logichistory)
        # preserverfeasiblehistory = copy(feasiblehistory)
        preserver = activehistory
        println("Preserving State")
    end

    function restore()
        (preserver === missing) && (println("Nothing to restore"); return)
        # push!(commandlist[setlocation], "#restore")
        # push!(commandlist, copy(preservercommandlist))
        # push!(logicset, replset)
        # setlocation += 1
        # replset = preserver
        replset = activelogicset(preserver)

        activehistory = preserver

        push!(sessionhistory, replset)

        println("Restoring State - " * reportfeasible())
        #
        # cmdlocation = preservercmdlocation
        #
        # commandhistory  = copy(preservercommandhistory)
        # logichistory    = copy(preserverlogichistory)
        # feasiblehistory = copy(feasiblehistory)
    end



    global reportfeasible() = "Feasible Outcomes: $(nfeasible(replset)) \t Perceived Outcomes: $(percievedfeasible(replset)) \t:$(joinsample(replset))"
    global lastcommand() = "Last command: \"$(commandhistory[cmdlocation])\""
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
