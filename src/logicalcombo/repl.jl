using ReplMaker, Markdown

function parse_to_expr(s)
   abstractlogic(s)

   if dashboard()
     println("\nCommand Lists:" * string(showsetlocation()))
     for v in showcommandlist()
         println(v)
     end

     println("\nCommand Location:" * string(showcmdlocation()))
     for v in showcommandhistory()
         println(v)
     end

     println("\nLogicSet Lists:" * string(showsetlocation()))
     for v in returnlogicset()
         println(join(collect(string(v))[1:(min(200,end))]))
     end

   end
   nothing
end

printmarkdown(x) = show(stdout, MIME("text/plain"), Markdown.parse(x))
markdownescape(x) = replace(x, "|"=>"\\|") |> (x -> replace(x, "#"=>"\\#"))

initrepl(
    parse_to_expr,
    prompt_text="abstractlogic> ",
    prompt_color = :blue,
    start_key='=',
    mode_name="Abstract Logic")

let

    global showcommandlist()  = commandlist
    global returnlogicset() = logicset
    global returnreplset() = replset
    global showcmdlocation() = cmdlocation
    global showsetlocation() = setlocation
    global showuserinput() = userinput
    global showcommandhistory() = commandhistory
    global showlogichistory() = logichistory

    dashboardshow = false
    global dashboard() = dashboardshow
    global dashboard!() = dashboardshow = !dashboardshow

    userinput = ""

    global replset = LogicalCombo()
    commandlist  = [String[]]

    commandlistprint = false

    preserver = missing
    preservercommandlist = missing
    preservercmdlocation = missing
    preservercommandhistory = missing
    preserverlogichistory = missing
    preserverfeasiblehistory = missing

    commandhistory = String["#Session Initiated"]
    feasiblehistory = [0]
    logichistory = [replset]
    logicset     = [replset]

    cmdlocation = 1
    setlocation = 1

    global replcmdverbose = true
    global replverboseall = true

    global function abstractlogic(replinput; returnactive = false)

        userinput = replinput |> strip |> tounicode

        # println("User input {$userinput}")
        (occursin("t(", userinput)) && (userinput = testcall(userinput))

        replcmdverbose = !occursin("[silent]", userinput)
        userinput = replace(userinput, "[silent]"=>"")

        occursin("[clear]", userinput) && clear()
        userinput = replace(userinput, "[clear]"=>"")

        verbose = replcmdverbose & replverboseall

        if strip(userinput) == ""                         nothing()
        elseif occursin(r"^(\?|help)", userinput)         help(userinput)
        elseif occursin(r"^show$", userinput)             ALshow()
        elseif occursin(r"^showall$", userinput)          showall()
        elseif userinput ∈ ["back", "b"]                  back()
        elseif userinput ∈ ["discover", "d"]              discover(LogicalCombo())
        elseif occursin(r"^export( as){0,1} ", userinput) ALexport(userinput)
        elseif userinput ∈ ["next", "n", "f"]             next()
        elseif occursin(r"^import ", userinput)           ALimport(userinput)
        elseif occursin(r"^dash(board)?$", userinput)     dashboard!()
        elseif userinput ∈ ["history", "h"]               history()
        elseif occursin(r"^command[ ]*list", userinput)   itemprint(commandlist)
        elseif userinput ∈ ["logicset","ls"]              itemprint(logicset)
        elseif userinput == "clear"                       clear()
        elseif userinput == "range"                       println(range(replset))
        elseif userinput == "clearall"                    clearall()
        elseif userinput ∈ ["keys", "k"]                  keys()
        elseif userinput == "preserve"                    ALpreserve()
        elseif userinput == "restore"                     restore()
        elseif userinput == "silence"                     replverboseall = false
        elseif userinput == "noisy"                       replverboseall = true

        elseif occursin(r"^(prove|force|check|any|✓)", userinput) ALcheck(userinput)
        elseif occursin(r"^search", userinput)            ALsearch(userinput)
        else                                              ALparse(userinput, verbose)
        end
        returnactive && return replset
        nothing
    end

    tounicode(x) = replace(x, r"\bin\b"=>"∈")

    nothing() = println(lastcommand()* " - " * reportfeasible())

    keys() = println(join(replset.keys, ", "))

    function back()
        (cmdlocation == 1) && (println("Nothing to go back to"); return)
        cmdlocation -= 1
        replset = logichistory[cmdlocation]
        println(lastcommand() * " - " * reportfeasible())
        pop!(commandlist[setlocation])
    end

    function clear()
        push!(commandlist[setlocation], "#clear")
        replset = LogicalCombo()
        logichistory = [replset]
        commandhistory = ["#Session Cleared"]
        feasiblehistory = [0]
        cmdlocation = 1
        setlocation += 1
        push!(commandlist, String[])
        push!(logicset, replset)

        println("Clear Workspace")
    end

    function clearall()
      commandlist = [String[]]
      replset = LogicalCombo()
      commandhistory = String["#Session Initiated"]
      feasiblehistory = [0]
      logichistory = [replset]
      logicset     = [replset]
      cmdlocation  = 1
      setlocation  = 1
      println("Clearing Everything!")
    end

    function history()
       currentfeasible = [feasiblehistory[1:cmdlocation]..., "...", feasiblehistory[(cmdlocation+1):end]...]
       currentcommand = [commandhistory[1:cmdlocation]..., "<< present >>", commandhistory[(cmdlocation+1):end]...]
       txtout = "| Command | # feasible |\n| --- | --- |\n"
       for i in 1:length(currentcommand)
           txtout *= ("| $(markdownescape(currentcommand[i])) | $(currentfeasible[i]) |\n")
       end
       printmarkdown(txtout)
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

        commandhistory  = [x]
        logichistory    = [replset]
        feasiblehistory = [nfeasible(replset)]
        push!(commandlist, [x])
    end

    function next()
        (cmdlocation == length(commandhistory)) && (println("Nothing to go forward to"); return)
        cmdlocation += 1
        replset = logichistory[cmdlocation]
        push!(commandlist[setlocation], commandhistory[cmdlocation])
        println(lastcommand() * " - " * reportfeasible())
    end

    function ALparse(userinput, verbose)
        if (sum(replset[:])==0) && !occursin(r"∈", userinput)
            print("error: userinput  - ")
            println("You are working with an empty set! Try inputing: a,b,c in 1:3")
            return
        end

        try
          templogicset = logicalparse(userinput, logicset = replset, verbose = verbose)
          replset = templogicset
          push!(commandlist[setlocation], userinput)
          commandhistory      = commandhistory[1:cmdlocation]
          logichistory        = logichistory[1:cmdlocation]
          feasiblehistory     = feasiblehistory[1:cmdlocation]

          cmdlocation += 1
          push!(commandhistory, userinput)
          push!(logichistory, replset)
          push!(feasiblehistory, nfeasible(replset))

          logicset[setlocation] = replset

        catch ex
          println("\tcommand Failed - $ex")
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

        (nrow == 0) && return println("Nothing to Show - [Empty Set]")

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
    global joinsample = (joins ∘ sample)

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
      occursin(r"^check[\\:\\-\\ ]+", userinput) &&
        checkfeasible(string(replace(userinput, r"^check[\\:\\-\\ ]*"=>"")),
        replset, verbose = replcmdverbose & replverboseall)
      occursin(r"^(prove|force)[\\:\\-\\ ]+", userinput) &&
        checkfeasible(string(replace(userinput, r"^prove[\\:\\-\\ ]*"=>"")),
        replset, force=true, verbose = replcmdverbose & replverboseall)
      occursin(r"^any[\\:\\-\\ ]+", userinput) &&
        checkfeasible(string(replace(userinput, r"^any[\\:\\-\\ ]*"=>"")),
        replset, countany=true, verbose = replcmdverbose & replverboseall)
      occursin(r"^✓[\\:\\-\\ ]*", userinput) &&
        checkfeasible(string(replace(userinput, r"^any[\\:\\-\\ ]*"=>"")),
        replset, countany=true, verbose=false)
      # push!(logicset, replset)
    catch
      println("Warning! Check Fail")
      (length(userinput) == 5) && println("Nothing to check")
      println("Typical check has same syntax as a command:")
      println("check: a = 2|3 or prove: a = 2|3")
      println("check: {{i}} != {{i+1}} or prove: {{i}} != {{i+1}}")
    end
end

function ALexport(x)
   y = replace(x, r"^export( as){0,1} " => "")
   Core.eval(Main, Meta.parse("$y = returnreplset()"))
   printmarkdown("`julia>` $y = `returnreplset()`")
   println()
end

function itemprint(x)
   for v in x
      vstring = string(v)
      println(vstring[1:min(90,end)] * (length(vstring) > 90 ? "..." : ""))
   end
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
    catch
      println("Warning! Search Failed")
    end
end
