using ReplMaker, Markdown

mutable struct History
    logicsets::Array
    current::Integer
end

function Base.push!(x::History, logicset::LogicalCombo)
  x.logicsets = [x.logicsets[1:x.current]..., logicset]
  x.current = x.current+1
  x
end

activelogicset(x::History) = x.logicsets[x.current]
priorlogicsets(x::History) = x.logicsets[1:x.current]
futurelogicsets(x::History) = x.logicsets[(x.current+1):end]

back!(x::History) = x.current = (x.current > 0 ? x.current - 1 : 0)
next!(x::History) = x.current = (x.current < length(x.logicsets) ? x.current + 1 : x.current)

activecommand(x::History)  = activelogicset(x).commands[end]
priorcommands(x::History)  = priorlogicsets(x) .|> z -> z.commands[end]

function futurecommands(x::History)
  y = futurelogicsets(x)
  (length(y) == 0) && return String[]
  y .|> z -> z.commands[end]
end

History() = History([logicalparse("#Session Started")], 1)

# active = History()
# priorcommands(active)
# futurecommands(active)
#
# push!(active, logicalparse("x in 1:4", activelogicset(active) ) )
# push!(active, logicalparse("y in 1:4", activelogicset(active) ) )
# push!(active, logicalparse("z in 1:4", activelogicset(active) ) )
#
# activelogicset(active)
# priorlogicsets(active)
#
# activecommand(active)
# priorcommands(active)
#
# back!(active)
# back!(active)
# futurecommands(active)
# priorcommands(active)
#
# next!(active)
# push!(active, logicalparse("q in 1:4", activelogicset(active) ) )
# priorcommands(active)


printmarkdown(x) = show(stdout, MIME("text/plain"), Markdown.parse(x))
markdownescape(x) = replace(x, "|"=>"\\|") |> (x -> replace(x, "#"=>"\\#"))

let

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

        occursin("[clear]", userinput) && clear()
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
        elseif userinput ∈ ["back", "b"]                  back()
        elseif occursin(r"compare ", userinput)           compare(userinput)
        elseif userinput ∈ ["discover", "d"]              discover(LogicalCombo())
        elseif occursin(r"^export( as){0,1} ", userinput) ALexport(userinput)
        elseif userinput ∈ ["next", "n", "f"]             next()
        elseif occursin(r"^import ", userinput)           ALimport(userinput)
        elseif occursin(r"^dash(board)?$", userinput)     dashboard!()
        elseif userinput ∈ ["history", "h"]               history()
        elseif occursin(r"^command[ ]*list", userinput)   itemprint(commandlist)
        elseif userinput ∈ ["logicset","ls"]              itemprint(logicset)
        elseif userinput == "clearall"                    clearall()
        elseif occursin(r"^clear[ ]*$", userinput)         clear()
        elseif occursin(r"^range", userinput)             ALrange(userinput)
        elseif userinput ∈ ["keys", "k"]                  keys()
        elseif userinput == "preserve"                    ALpreserve()
        elseif userinput == "restore"                     restore()
        elseif userinput == "silence"                     replverboseall = false
        elseif userinput == "noisy"                       replverboseall = true

        elseif occursin(r"^(prove|all|check|any|✓)", userinput) ALcheck(userinput)
        elseif occursin(r"^search", userinput)            ALsearch(userinput)
        else                                              ALparse(userinput)
        end
        returnactive && return replset
        nothing
    end

    tounicode(x) = replace(x, r"\bin\b"=>"∈")

    nothing() = println(lastcommand()* " - " * reportfeasible())

    keys() = println(join(replset.keys, ", "))



    function clear()
        push!(commandlist[setlocation], "#clear")
        replset = LogicalCombo()

        activehistory = History()

        setlocation += 1
        push!(commandlist, String[])
        push!(logicset, replset)

        replcmdverbose && replverboseall && println("Clear Workspace")
    end

    function clearall()
      commandlist = [String[]]
      replset = LogicalCombo()
      commandhistory = String["#Session Initiated"]
      feasiblehistory = [0]

      activehistory = History()

      logichistory = [replset]
      logicset     = [replset]
      cmdlocation  = 1
      setlocation  = 1
      println("Clearing Everything!")
    end


    function ALimport(x)

        y = Symbol(strip(replace(x, r"^import "=>"")))

        !(y ∈ names(Main)) && (println("$y not found!"); return)

        z = getfield(Main, y)
        !isa(z, LogicalCombo) && (println("$y not a LogicalCombo!"); return)

        push!(commandlist[setlocation], "#$x")
        # push!(commandlist, copy(preservercommandlist))
        logicset[setlocation] = replset
        setlocation += 1
        replset = z
        push!(logicset, replset)

        println("Importing $y - " * reportfeasible())
        cmdlocation = 1
        activehistory.current = 1

        commandhistory  = [x]
        logichistory    = [replset]
        feasiblehistory = [nfeasible(replset)]
        push!(commandlist, [x])
    end


    function ALparse(userinput)
        if (sum(replset[:])==0) && !occursin(r"∈", userinput)
            replthrow("You are working with an empty set! Try inputing: a,b,c in 1:3")
            return
        end

        try
          templogicset = logicalparse(userinput, logicset = replset,
                                      verbose = replcmdverbose & replverboseall)
          replset = templogicset

          push!(activehistory, replset)

          logicset[setlocation] = replset

        catch ex
          replthrow("\tcommand Failed - $ex")
        end
    end

    function ALpreserve()
        preservercommandlist = copy(commandlist[setlocation])
        push!(commandlist[setlocation], "#preserve")
        preserver = replset
        preservercmdlocation = cmdlocation
        preservercommandhistory = copy(commandhistory)
        preserverlogichistory = copy(logichistory)
        preserverfeasiblehistory = copy(feasiblehistory)
        println("Preserving State")
    end

    function restore()
        (preserver === missing) && (println("Nothing to restore"); return)
        push!(commandlist[setlocation], "#restore")
        push!(commandlist, copy(preservercommandlist))
        push!(logicset, replset)
        setlocation += 1
        replset = preserver

        println("Restoring State - " * reportfeasible())
        cmdlocation = preservercmdlocation

        commandhistory  = copy(preservercommandhistory)
        logichistory    = copy(preserverlogichistory)
        feasiblehistory = copy(feasiblehistory)
    end

    function ALshow(;n =10)
        nrow = nfeasible(replset)

        (nrow == 0) && return replthrow("Nothing to Show - [Empty Set]")

        printset = unique([(1:min(n÷2,nrow))..., 0, (max(nrow-(n÷2 -1), 1):nrow)...])
        (nrow<=n) && (printset = 1:nrow)

        txtout = ""
        (nrow > n) && (txtout *= "*Showing $n of $nrow rows*\n\n")

        txtout *= "| " * join(replset[0,:], " | ") * " | \n"
        txtout *= "| " * join(fill(":---:", size(replset,2) ), " | ") * " | \n"

        for setlocation in printset
          (setlocation != 0) &&
            (txtout *= "| " * join(replset[setlocation,:,:], " | ")*" |\n")
          (setlocation == 0) &&
            (txtout *= "| " * (join(fill("⋮",  size(replset, 2)), " | "))*"|\n")
        end

        printmarkdown(txtout)
    end

    showall() = ALshow(n = nfeasible(replset))


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

function ALcheck(userinput)
    try
      inputpass = string(replace(userinput, r"^(check|prove|all|any|✓)[\\:\\-\\ ]*"=>""))
      occursin(r"^check[\\:\\-\\ ]+", userinput) &&
        checkfeasible(inputpass, replset, verbose = replcmdverbose & replverboseall)
      occursin(r"^(prove|all)[\\:\\-\\ ]+", userinput) &&
        checkfeasible(inputpass, replset, countall=true, verbose = replcmdverbose & replverboseall)
      occursin(r"^any[\\:\\-\\ ]+", userinput) &&
        checkfeasible(inputpass, replset, countany=true, verbose = replcmdverbose & replverboseall)
      occursin(r"^✓[\\:\\-\\ ]*", userinput) &&
        checkfeasible(inputpass, replset, countany=true, verbose=false)
      # push!(logicset, replset)
  catch er
      replthrow("\nWarning! Check Fail: $er")
      (length(userinput) == 5) && println("Nothing to check")
    end
end

function ALexport(x)
   y = replace(x, r"^export( as){0,1} " => "")
   Core.eval(Main, Meta.parse("$y = returnreplset()"))
   printmarkdown("`julia>` $y = `returnreplset()`")
   println()
end

function back()
    (activehistory.current == 1) && (replthrow("Nothing to go back to"); return)

    back!(activehistory)
    replset = activelogicset(activehistory)
    println(activecommand(activehistory) * " - " * reportfeasible())

end

function compare(x)

    y = Symbol(strip(replace(x, r"^compare "=>"")))

    !(y ∈ names(Main)) && (replthrow("$y not found!"); return)

    z = getfield(Main, y)

    (replset[:] == z[:]) &&
      (println("replset and $y have the same feasible values. replset[:] == $y[:]"); return)
    (nfeasible(replset) == nfeasible(z)) &&
      (println("replset set and $y have the same number of feasible values. nfeasible(replset) == nfeasible($y)"); return)
    (nfeasible(replset) > nfeasible(z)) &&
      (println("replset set has more feasible values than $y. nfeasible(replset) > nfeasible($y)"); return)
    (nfeasible(replset) < nfeasible(z)) &&
      (println("replset set has less feasible values than $y. nfeasible(replset) < nfeasible($y)"); return)

end

function history()
   currentcommand =
     [priorcommands(activehistory)..., "<< present >>",
     futurecommands(activehistory)...]
   currentfeasible =
     [nfeasible.(priorlogicsets(activehistory))..., "...",
     nfeasible.(futurelogicsets(activehistory))...]


   txtout = "| Command | # feasible |\n| --- | --- |\n"
   for i in 1:length(currentcommand)
       txtout *= ("| $(markdownescape(currentcommand[i])) | $(currentfeasible[i]) |\n")
   end
   printmarkdown(txtout)
end

function itemprint(x)
   for v in x
      vstring = string(v)
      println(vstring[1:min(90,end)] * (length(vstring) > 90 ? "..." : ""))
   end
end


function next()
    (activehistory.current == length(activehistory.logicsets)) && (replthrow("Nothing to go forward to"); return)

    next!(activehistory)
    replset = activelogicset(activehistory)
    println(activecommand(activehistory) * " - " * reportfeasible())

end

function testcall(userinput)
    if userinput == "t(1)"
        abstractlogic("clear")
        abstractlogic("a,b,c ∈ 1:4")
        abstractlogic("a|c = 1")
        abstractlogic("a > b")
        return "b > c"
    elseif userinput == "t(hp)"
        abstractlogic("clear")
        abstractlogic("a, b, c, d, e, f, g  ∈  NW, MA, MB, PO")
        abstractlogic("{{i}} == 'NW' {{2}}")
        abstractlogic("{{i}} == 'MA' {{1}}")
        abstractlogic("{{i}} == 'MB' {{1}}")
        abstractlogic("{{i}} == 'PO' {{3}}")
        abstractlogic("{{i!}} == 'NW' ==> {{i-1}} == 'PO'")
        abstractlogic("a != g")
        abstractlogic("a,g != 'MA'")
        abstractlogic("c,f != 'PO'")
        return "b == f"
    end
    return userinput
end

function ALsearch(userinput)
    try
      checker = replace(userinput[7:end], r"^[\\:\\-\\ ]+"=>"")
      search(checker, replset, verbose = replcmdverbose & replverboseall)
      # push!(logicset, replset)
  catch er
      replthrow("Warning! Search Failed: $er")
    end
end

function ALrange(userinput)
  replcmdverbose && replverboseall && println(userinput)
  inputpass = string(replace(userinput, r"^(range)[\\:\\-\\ ]*"=>"")) |> strip
  (inputpass == "") && return println(range(replset))
  occursin(" ", inputpass) &&
    return replthrow("\n range only takes up to one variable currently!")
  !(inputpass ∈ replset.keys) &&
    return replthrow("\n $inputpass not found in replset!")
  return println(range(replset)[Symbol(inputpass)])
  return println(range(replset, inputpass))
  nothing
end
