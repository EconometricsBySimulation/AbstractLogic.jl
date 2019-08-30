function LogicalRepl()
  println("Welcome to the abstract logic solver interactive mode!")
  # println("Please note this in not a true REPL and will not store commands.")
  # println("in the same manner as the JuliaShell (so ↑ will not work)")
  # println("'?' for a list of operators.")
  println("Type 'exit' to exit.")
  println("'clear' to clear the environment space")
  println("'search {followed by search}' to search the environment space")
  println("'back' to return to previous state or 'next' to move forward")
  # println("'check' {followed by command} check the environment space")

  activelogicset = LogicalCombo()
  commandlist  = [String[]]
  logicsetlist = []

  preserver = missing
  preservercommandlist = missing
  preserverj = missing
  preservercommandhistory = missing
  preserverlogichistory = missing

  commandhistory = String["#Session Initiated"]
  logichistory = [activelogicset]

  j = 1
  i = 1
  joins(x) = join(x, " ")
  joinpull = (joins ∘ pull)
  reportfeasible(x) = "Feasible Outcomes: $(nfeasible(x)) \t:$(joinpull(x))"

  while 1==1
    print("\nAL> ")
    userinput = readline(stdin) |> strip
    userinput = replace(userinput, r"\bin\b"=>"∈")

    println(length(commandlist))
    println(length(logicsetlist))

    if strip(userinput) == ""
      println(reportfeasible(activelogicset))
      continue

    elseif userinput == "show"
      println(join(activelogicset[0,:], "\t"))
      for i in 1:nfeasible(activelogicset)
        println(join(activelogicset[i,:,:], "\t"))
      end

    elseif userinput == "back"
      (j == 1) && (println("Nothing to go back to"); continue)
      j -= 1
      activelogicset = logichistory[j]
      println("Last Command: \"$(commandhistory[j])\" - " * reportfeasible(activelogicset))
      pop!(commandlist[i])

    elseif userinput == "next"
      (j == length(commandhistory)) && (println("Nothing to go forward to"); continue)
      j += 1
      activelogicset = logichistory[j]
      push!(commandlist[i], commandhistory[j])
      println("Last Command: \"$(commandhistory[j])\" - " * reportfeasible(activelogicset))

    elseif userinput == "clear"
      activelogicset = LogicalCombo()
      i += 1
      push!(commandlist, String[])
      push!(logicsetlist, activelogicset)
      println("Clear Workspace")
      continue

    elseif userinput == "keys"
      println(join(activelogicset.keys, ", ", "and"))
      continue

    elseif occursin("check", userinput)
      try
        checker = replace(userinput[6:end], r"^[\\:\\-\\ ]+"=>"")
        checkfeasible(checker, activelogicset)
        push!(logicsetlist, activelogicset)
      catch
        println("Warning! Check Fail")
        (length(userinput) == 5) && println("Nothing to check")
        println("Typical check has same syntax as a command:")
        println("Check: a = 2|3")
        println("Check: {{i}} != {{i+1}}")
        continue
      end

    elseif userinput == "preserve"
      preservercommandlist = copy(commandlist[i])
      #push!(commandlist[i], "#preserve")
      preserver = activelogicset
      preserverj = j
      preservercommandhistory = copy(commandhistory)
      preserverlogichistory = copy(logichistory)
      println("Preserving State")
      continue

    elseif userinput == "restore"
      (preserver === missing) && (println("Nothing to restore"); continue)
      #push!(commandlist[i], "#restore")
      push!(commandlist, copy(preservercommandlist))
      push!(logicsetlist, activelogicset)
      i += 1
      activelogicset = preserver
      println("Restoring State - " * reportfeasible(activelogicset))
      j = preserverj
      commandhistory = copy(preservercommandhistory)
      logichistory = copy(preserverlogichistory)
      continue

    elseif userinput == "exit"
      push!(logicsetlist, activelogicset)
      println("\nExiting")
      break

    else
      (sum(activelogicset[:])==0) && !occursin(r"∈", userinput) &&
        println("You are working with an empty set! Try inputing: a,b,c in 1:3")

      try
        activelogicset = logicalparse([userinput], activelogicset)
        push!(commandlist[i], userinput)

        commandhistory = commandhistory[1:j]
        j += 1
        push!(commandhistory, userinput)
        push!(logichistory, activelogicset)

      catch
        println("Command Failed")
        continue
      end

    end
  end

  commandlist, logicsetlist
end

# commands, logicset = LogicalRepl()
