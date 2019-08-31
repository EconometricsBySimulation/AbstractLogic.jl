
let commandlist = Any[], logicsetlist = Any[]
    global globalcommandlistclear()  = commandlist = Any[]
    global logicsetlistclear()       = logicsetlist = Any[]
    global globalcommandlist(f)  = f(commandlist)
    global globallogiclist(f) = f(logicsetlist)
end

"""
    logicalrepl(;preserve = false)

Enter the psuedo REPL for abstract logical reasoning.
"""
function logicalrepl(; preserve=false)

  !preserve && (globalcommandlistclear(); logicsetlistclear())

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
    print("\nAL: ")
    userinput = readline(stdin) |> strip
    userinput = replace(userinput, r"\bin\b"=>"∈")

    if strip(userinput) == ""
      println("Last Command: \"$(commandhistory[j])\" - " * reportfeasible(activelogicset))
      continue

  elseif occursin(r"^show$", userinput)
      nrow = nfeasible(activelogicset)
      printset = unique([(1:min(5,nrow))..., 0, (max(nrow-4, 1):nrow)...])
      (nrow<=10) && (printset = 1:nrow)

      println(join(activelogicset[0,:], "\t"))
      for i in printset
        (i != 0) && println(join(activelogicset[i,:,:], "\t"))
        (i == 0) && println(join(fill("...",  size(activelogicset, 2)), "\t"))
      end

  elseif occursin(r"^showall$", userinput)
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
      push!(commandlist[i], "#clear")
      globalcommandlist(x -> push!(x, commandlist[i]))
      globallogiclist(x -> push!(x, activelogicset))

      activelogicset = LogicalCombo()
      logichistory = [activelogicset]
      commandhistory = ["#Session Cleared"]
      j = 1
      i += 1
      push!(commandlist, String[])
      push!(logicsetlist, activelogicset)

      println("Clear Workspace")
      continue

    elseif userinput == "keys"
      println(join(activelogicset.keys, ", "))
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
      push!(commandlist[i], "#preserve")
      preserver = activelogicset
      preserverj = j
      preservercommandhistory = copy(commandhistory)
      preserverlogichistory = copy(logichistory)
      println("Preserving State")
      continue

    elseif userinput == "restore"
      (preserver === missing) && (println("Nothing to restore"); continue)
      push!(commandlist[i], "#restore")
      push!(commandlist, copy(preservercommandlist))
      push!(logicsetlist, activelogicset)
      i += 1
      activelogicset = preserver

      println("Restoring State - " * reportfeasible(activelogicset))
      j = preserverj

      commandhistory = copy(preservercommandhistory)
      logichistory = copy(preserverlogichistory)

      globalcommandlist(x -> push!(x, commandlist[i]))
      globallogiclist(x -> push!(x, activelogicset))
      continue

    elseif userinput == "exit"
      push!(logicsetlist, activelogicset)
      push!(commandlist[i], "#exit")
      println("\nExiting")
      globalcommandlist(x -> push!(x, commandlist[i]))
      globallogiclist(x -> push!(x, activelogicset))
      break

    else
      (sum(activelogicset[:])==0) && !occursin(r"∈", userinput) &&
        println("You are working with an empty set! Try inputing: a,b,c in 1:3")

      try
        activelogicset = logicalparse([userinput], activelogicset)
        push!(commandlist[i], userinput)

        commandhistory = commandhistory[1:j]
        logichistory   = logichistory[1:j]
        j += 1
        push!(commandhistory, userinput)
        push!(logichistory, activelogicset)

    catch ex
        println("Command Failed - $ex")
        continue
      end

    end
  end

  commandlist, logicsetlist
end

lrepl = logicalrepl

@doc """
    x,y,z ∈ 1,2,3
    x,y,z ∈ 1:3
    x,y,z ∈ apples, oranges, grapes
"""
Base.:∈(x::LogicalCombo) = ""

# commands, logicset = LogicalRepl()
commandlist() = globalcommandlist(x -> x)
logiclist() = globallogiclist(x -> x)
