
let

    global showcommandlist()  = commandlist
    global showlogicset() = logicset
    global showcmdlocation() = cmdlocation
    global showsetlocation() = setlocation
    global showuserinput() = userinput
    global showcommandhistory() = commandhistory
    global showlogichistory() = logichistory

    userinput = ""

    activelogicset = LogicalCombo()
    commandlist  = [String[]]

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

    global function logicalrepl(; preserve=false)

      if   !preserve
          commandlist = [String[]]
          activelogicset = LogicalCombo()
          logicset = [LogicalCombo()]
      end

      println("Welcome to the abstract logic solver interactive mode!")
      # println("Please note this in not a true REPL and will not store commands.")
      # println("in the same manner as the JuliaShell (so ↑ will not work)")
      # println("'?' for a list of operators.")
      println("Type 'exit' to exit.")
      println("'clear' to clear the environment space")
      println("'search {followed by search}' to search the environment space")
      println("'back' to return to previous state or 'next' to move forward")
      # println("'check' {followed by command} check the environment space")

      while 1==1
        print("\nAL: ")
        !testmode && (userinput = readline(stdin) |> strip |> tounicode)

        (occursin("()", userinput) || testmode) && (userinput = testcall(userinput))

        if strip(userinput) == ""                   nothing()
        elseif occursin(r"^show$", userinput)       alshow()
        elseif occursin(r"^showall$", userinput)    showall()
        elseif userinput == "back"                  back()
        elseif userinput == "forward"               forward()
        elseif userinput == "history"               history()
        elseif userinput == "commandlist"           itemprint(commandlist)
        elseif userinput == "logicset"              itemprint(logicset)
        elseif userinput == "clear"                 clear()
        elseif userinput == "keys"                  keys()
        elseif occursin(r"^check", userinput)       alcheck(userinput)
        elseif occursin(r"^search", userinput)       alsearch(userinput)
        elseif userinput == "preserve"              alpreserve()
        elseif userinput == "restore"               restore()
        elseif userinput == "exit"                  exit(); break
        else                                        alparse(userinput)
        end

      end

      commandlist, logicset
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
            testcount = 0
            testmode = true
            testingset = "t1"
            return "a,b,c ∈ 1:4"
        elseif testingset == "t1"
            testcount += 1
            (testcount == 1) && return "a|c = 1"
            (testcount == 2) && return "a > b"
            (testcount == 3) && (testreset(); return "b > c")
        end
        return userinput

    end

    function exit()
        push!(logicset, activelogicset)
        push!(commandlist[setlocation], "#exit")
        println("\nExiting")
    end

    function alparse(userinput)
        if (sum(activelogicset[:])==0) && !occursin(r"∈", userinput)
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

    function alpreserve()
        preservercommandlist = copy(commandlist[setlocation])
        push!(commandlist[setlocation], "#preserve")
        preserver = activelogicset
        preservercmdlocation = cmdlocation
        preservercommandhistory = copy(commandhistory)
        preserverlogichistory = copy(logichistory)
        preserverfeasiblehistory = copy(feasiblehistory)
        println("Preserving State")
    end

    function alcheck(userinput)
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

    function alsearch(userinput)
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

    function forward()
        (cmdlocation == length(commandhistory)) && (println("Nothing to go forward to"); return )
        cmdlocation += 1
        activelogicset = logichistory[cmdlocation]
        push!(commandlist[setlocation], commandhistory[cmdlocation])
        println(lastcommand() * " - " * reportfeasible(activelogicset))
    end

    function history()
       currentfeasible = [feasiblehistory[1:cmdlocation]..., "...", feasiblehistory[(cmdlocation+1):end]...]
       currentcommand = [commandhistory[1:cmdlocation]..., "<< present >>", commandhistory[(cmdlocation+1):end]...]
       for i in 1:length(currentcommand)
           println("\t $(currentcommand[i]) \t \t $(currentfeasible[i])")
       end
    end

    global function alshow(;n =10)
        nrow = nfeasible(activelogicset)
        printset = unique([(1:min(n÷2,nrow))..., 0, (max(nrow-(n÷2 -1), 1):nrow)...])
        (nrow<=n) && (printset = 1:nrow)

        println(join(activelogicset[0,:], "\t"))
        for setlocation in printset
          (setlocation != 0) && println(join(activelogicset[setlocation,:,:], "\t"))
          (setlocation == 0) && println(join(fill("...",  size(activelogicset, 2)), "\t"))
        end
    end

    reportfeasible(x) = "Feasible Outcomes: $(nfeasible(x)) \t:$(joinpull(x))"
    lastcommand() = "Last command: \"$(commandhistory[cmdlocation])\""
    joins(x) = join(x, " ")
    joinpull = (joins ∘ pull)

    showall() = alshow(n = nfeasible(activelogicset))

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
logicalrepl

lrepl = logicalrepl
