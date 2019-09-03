using ReplMaker, Markdown

function parse_to_expr(s)
   abstractlogic(s)
   nothing
   println("\n")
   activecommandshow() &&
     for i in 1:length(showcommandlist())
         println(showcommandlist()[i])
     end
   showcmdlocation()
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
    global showlogicset() = logicset
    global showcmdlocation() = cmdlocation
    global showsetlocation() = setlocation
    global showuserinput() = userinput
    global showcommandhistory() = commandhistory
    global showlogichistory() = logichistory

    activeshow = false
    global activecommandshow() = activeshow
    global activecommandshow!() = activeshow = !activeshow
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
    testcount = 0
    testmode = false
    testingset = ""
    testreset() = (testmode = false; testset = ""; testcount = 0)

    global function abstractlogic(replinput)

        userinput = replinput |> strip |> tounicode
        # println("User input {$userinput}")
        (occursin("()", userinput) || testmode) && (userinput = testcall(userinput))

        if strip(userinput) == ""                       nothing()
        elseif occursin(r"^show$", userinput)           ALshow()
        elseif occursin(r"^showall$", userinput)        showall()
        elseif userinput ∈ ["back", "b"]                back()
        elseif userinput ∈ ["next", "n"]                next()
        elseif occursin(r"^show[ ]*active", userinput)  activecommandshow!()
        elseif userinput ∈ ["history", "h"]             history()
        elseif occursin(r"^command[ ]*list", userinput) itemprint(commandlist)
        elseif userinput == "logicset"                  itemprint(logicset)
        elseif userinput == "clear"                     clear()
        elseif userinput == "keys"                      keys()
        elseif occursin(r"^check", userinput)           ALcheck(userinput)
        elseif occursin(r"^search", userinput)          ALsearch(userinput)
        elseif userinput == "preserve"                  ALpreserve()
        elseif userinput == "restore"                   restore()
        else                                            ALparse(userinput)
        end

    end

    tounicode(x) = replace(x, r"\bin\b"=>"∈")

    nothing() = println(lastcommand()* " - " * reportfeasible(activelogicset))

    keys() = println(join(activelogicset.keys, ", "))
    function itemprint(x)
       for v in x
          vstring = string(v)
          println(vstring[1:min(90,end)] * (length(vstring) > 90 ? "..." : ""))
       end
    end

    function testcall(userinput)
        if userinput == "t1()"
            clear()
            abstractlogic("a,b,c ∈ 1:4")
            abstractlogic("a|c = 1")
            abstractlogic("a > b")
            return "b > c"
        elseif userinput == "hp()"
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

    function ALsearch(userinput)
        try
          checker = replace(userinput[7:end], r"^[\\:\\-\\ ]+"=>"")
          search(checker, activelogicset)
          # push!(logicset, activelogicset)
        catch
          println("Warning! Search Failed")
        end
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

    function back()
        (cmdlocation == 1) && (println("Nothing to go back to"); return)
        cmdlocation -= 1
        activelogicset = logichistory[cmdlocation]
        println(lastcommand() * " - " * reportfeasible(activelogicset))
        pop!(commandlist[setlocation])
    end

    function next()
        (cmdlocation == length(commandhistory)) && (println("Nothing to go forward to"); return)
        cmdlocation += 1
        activelogicset = logichistory[cmdlocation]
        push!(commandlist[setlocation], commandhistory[cmdlocation])
        println(lastcommand() * " - " * reportfeasible(activelogicset))
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

    reportfeasible(x) = "Feasible Outcomes: $(nfeasible(x)) \t:$(joinpull(x))"
    lastcommand() = "Last command: \"$(commandhistory[cmdlocation])\""
    joins(x) = join(x, " ")
    joinpull = (joins ∘ pull)

    showall() = ALshow(n = nfeasible(activelogicset))

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
