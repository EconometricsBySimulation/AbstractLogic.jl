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
    global showcmdlocation() = cmdlocation
    global showsetlocation() = setlocation
    global showuserinput() = userinput
    global showcommandhistory() = commandhistory
    global showlogichistory() = logichistory

    dashboardshow = false
    global dashboard() = dashboardshow
    global dashboard!() = dashboardshow = !dashboardshow
    global returnactivelogicset() = activelogicset

    userinput = ""

    activelogicset = LogicalCombo()
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
    logichistory = [activelogicset]
    logicset     = [activelogicset]

    cmdlocation = 1
    setlocation = 1

    global function abstractlogic(replinput; returnactive = false)

        userinput = replinput |> strip |> tounicode
        # println("User input {$userinput}")
        (occursin("t(", userinput)) && (userinput = testcall(userinput))

        if strip(userinput) == ""                       nothing()
        elseif occursin(r"^(\?|help)", userinput)       help(userinput)
        elseif occursin(r"^show$", userinput)           ALshow()
        elseif occursin(r"^showall$", userinput)        showall()
        elseif userinput ∈ ["back", "b"]                back()
        elseif userinput ∈ ["discover", "d"]            discover(LogicalCombo())
        elseif userinput ∈ ["next", "n", "f"]           next()
        elseif occursin(r"^import ", userinput)         ALimport(userinput)
        elseif occursin(r"^dash(board)?$", userinput)   dashboard!()
        elseif userinput ∈ ["history", "h"]             history()
        elseif occursin(r"^command[ ]*list", userinput) itemprint(commandlist)
        elseif userinput ∈ ["logicset","ls"]            itemprint(logicset)
        elseif userinput == "clear"                     clear()
        elseif userinput == "clearall"                  clearall()
        elseif userinput ∈ ["keys", "k"]                keys()
        elseif occursin(r"^check", userinput)           ALcheck(userinput)
        elseif occursin(r"^search", userinput)          ALsearch(userinput)
        elseif userinput == "preserve"                  ALpreserve()
        elseif userinput == "restore"                   restore()
        else                                            ALparse(userinput)
        end
        returnactive && return activelogicset
        nothing
    end

    tounicode(x) = replace(x, r"\bin\b"=>"∈")

    nothing() = println(lastcommand()* " - " * reportfeasible(activelogicset))

    keys() = println(join(activelogicset.keys, ", "))

    function back()
        (cmdlocation == 1) && (println("Nothing to go back to"); return)
        cmdlocation -= 1
        activelogicset = logichistory[cmdlocation]
        println(lastcommand() * " - " * reportfeasible(activelogicset))
        pop!(commandlist[setlocation])
    end

    function clear()
        push!(commandlist[setlocation], "#clear")
        activelogicset = LogicalCombo()
        logichistory = [activelogicset]
        commandhistory = ["#Session Cleared"]
        feasiblehistory = [0]
        cmdlocation = 1
        setlocation += 1
        push!(commandlist, String[])
        push!(logicset, activelogicset)

        println("Clear Workspace")
    end

    function clearall()
      commandlist = [String[]]
      activelogicset = LogicalCombo()
      commandhistory = String["#Session Initiated"]
      feasiblehistory = [0]
      logichistory = [activelogicset]
      logicset     = [activelogicset]
      cmdlocation  = 1
      setlocation  = 1
      println("Clearing Everything!")
    end

    function ALcheck(userinput)
        try
          checker = replace(userinput[6:end], r"^[\\:\\-\\ ]+"=>"")
          checkfeasible(string(checker), activelogicset)
          # push!(logicset, activelogicset)
        catch
          println("Warning! Check Fail")
          (length(userinput) == 5) && println("Nothing to check")
          println("Typical check has same syntax as a command:")
          println("Check: a = 2|3")
          println("Check: {{i}} != {{i+1}}")
        end
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
        logicset[setlocation] = activelogicset
        setlocation += 1
        activelogicset = z
        push!(logicset, activelogicset)

        println("Importing $y - " * reportfeasible(activelogicset))
        cmdlocation = 1

        commandhistory  = [x]
        logichistory    = [activelogicset]
        feasiblehistory = [nfeasible(activelogicset)]
        push!(commandlist, [x])
    end

    function itemprint(x)
       for v in x
          vstring = string(v)
          println(vstring[1:min(90,end)] * (length(vstring) > 90 ? "..." : ""))
       end
    end

    function next()
        (cmdlocation == length(commandhistory)) && (println("Nothing to go forward to"); return)
        cmdlocation += 1
        activelogicset = logichistory[cmdlocation]
        push!(commandlist[setlocation], commandhistory[cmdlocation])
        println(lastcommand() * " - " * reportfeasible(activelogicset))
    end

    function ALparse(userinput)
        if (sum(activelogicset[:])==0) && !occursin(r"∈", userinput)
            print("error: userinput  - ")
            println("You are working with an empty set! Try inputing: a,b,c in 1:3")
            return
        end

        try
          templogicset = logicalparse(userinput, activelogicset)
          activelogicset = templogicset
          push!(commandlist[setlocation], userinput)
          commandhistory      = commandhistory[1:cmdlocation]
          logichistory        = logichistory[1:cmdlocation]
          feasiblehistory     = feasiblehistory[1:cmdlocation]

          cmdlocation += 1
          push!(commandhistory, userinput)
          push!(logichistory, activelogicset)
          push!(feasiblehistory, nfeasible(activelogicset))

          logicset[setlocation] = activelogicset

        catch ex
          println("\tcommand Failed - $ex")
        end
    end

    function ALpreserve()
        preservercommandlist = copy(commandlist[setlocation])
        push!(commandlist[setlocation], "#preserve")
        preserver = activelogicset
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
        push!(logicset, activelogicset)
        setlocation += 1
        activelogicset = preserver

        println("Restoring State - " * reportfeasible(activelogicset))
        cmdlocation = preservercmdlocation

        commandhistory  = copy(preservercommandhistory)
        logichistory    = copy(preserverlogichistory)
        feasiblehistory = copy(feasiblehistory)
    end

    function ALshow(;n =10)
        nrow = nfeasible(activelogicset)

        (nrow == 0) && return println("Nothing to Show - [Empty Set]")

        printset = unique([(1:min(n÷2,nrow))..., 0, (max(nrow-(n÷2 -1), 1):nrow)...])
        (nrow<=n) && (printset = 1:nrow)

        txtout = "| " * join(activelogicset[0,:], " | ") * " | \n"
        txtout *= "| " * join(fill(":---:", size(activelogicset,2) ), " | ") * " | \n"

        for setlocation in printset
          (setlocation != 0) &&
            (txtout *= "| " * join(activelogicset[setlocation,:,:], " | ")*" |\n")
          (setlocation == 0) &&
            (txtout *= "| " * (join(fill("⋮",  size(activelogicset, 2)), " | "))*"|\n")
        end

        printmarkdown(txtout)
    end

    showall() = ALshow(n = nfeasible(activelogicset))

    function ALsearch(userinput)
        try
          checker = replace(userinput[7:end], r"^[\\:\\-\\ ]+"=>"")
          search(checker, activelogicset)
          # push!(logicset, activelogicset)
        catch
          println("Warning! Search Failed")
        end
    end

    function testcall(userinput)
        if userinput == "t(1)"
            clear()
            abstractlogic("a,b,c ∈ 1:4")
            abstractlogic("a|c = 1")
            abstractlogic("a > b")
            return "b > c"
        elseif userinput == "t(hp)"
            clear()
            abstractlogic("a, b, c, d, e, f, g  ∈  NW, MA, MB, PO")
            abstractlogic("{{i}} == 'NW' {{2}}")
            abstractlogic("{{i}} == 'MA' {{1}}")
            abstractlogic("{{i}} == 'MB' {{1}}")
            abstractlogic("{{i}} == 'PO' {{3}}")
            abstractlogic("{{i+1}} == 'NW' ==> {{i}} == 'PO'")
            abstractlogic("a != 'NW'")
            abstractlogic("a != g")
            abstractlogic("a,g != 'MA'")
            abstractlogic("c,f != 'PO'")
            return "b == f"
        end
        return userinput
    end

    reportfeasible(x) = "Feasible Outcomes: $(nfeasible(x)) \t:$(joinsample(x))"
    lastcommand() = "Last command: \"$(commandhistory[cmdlocation])\""
    joins(x) = join(x, " ")
    joinsample = (joins ∘ sample)


end



"""
    logicalrepl(;preserve = false)

Enter the psuedo REPL for abstract logical reasoning.

```julia
julia> logicalrepl()
Welcome to the abstract logic solver interactive mode!
'exit' to exit
'clear' to empty the environment space
'search {followed by search}' to search the environment space
'back' to return to previous state or 'forward' to move forward

AL: a, b, c in 1:3
a, b, c ∈ 1:3            feasible outcomes 27 ✓          :1 1 3

AL: a == b
a == b                   feasible outcomes 9 ✓           :3 3 3

AL: a > c
a > c                    feasible outcomes 3 ✓           :3 3 1

AL: c != 1
c != 1                   feasible outcomes 1 ✓✓          :3 3 2

AL: exit
```
"""

function discover(x::LogicalCombo)
   nameset = names(Main)

   logicalcombonames = String[]
   variables         = String[]
   nfeasiblelist     = Int16[]
   ncommands         = Int16[]
   lastcommand       = String[]

   for v in nameset
     # global logicalcombonames, variables, nfeasible, ncommands
     x = getfield(Main, v)
     if isa(x, LogicalCombo)
       push!(logicalcombonames, string(v))
       push!(variables, join(keys(x),", "))
       push!(nfeasiblelist, nfeasible(x))
       push!(ncommands, nfeasible(x))
       push!(lastcommand, last(x.commands))
     end
   end

   txtout = "| Name | Variables | #feasible | #commands | Last Command | \n"
   txtout *= "| :---: | :---: | :---: | :---: | :---: | \n"

   for i in 1:length(logicalcombonames)
       txtout *= "| $(logicalcombonames[i]) | $(variables[i]) | " *
             "$(nfeasiblelist[i]) | $(ncommands[i]) | $(lastcommand[i]) | \n"
   end

   printmarkdown(txtout)
end
