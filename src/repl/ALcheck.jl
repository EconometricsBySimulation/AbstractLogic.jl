function ALcheck(userinput; verbose=true)
    try
      inputpass = string(replace(userinput, r"^(check|prove|all|any|✓)[\\:\\-\\ ]*"=>""))
      occursin(r"^(check|✓)[\\:\\-\\ ]+", userinput) &&
        checkfeasible(inputpass, replset, verbose = verbose)
      occursin(r"^(prove|all)[\\:\\-\\ ]+", userinput) &&
        checkfeasible(inputpass, replset, countall=true, verbose = replcmdverbose & replverboseall)
      occursin(r"^any[\\:\\-\\ ]+", userinput) &&
        checkfeasible(inputpass, replset, countany=true, verbose = replcmdverbose & replverboseall)
      # push!(logicset, replset)
  catch er
      replthrow("\nWarning! Check Fail: $er")
      (length(userinput) == 5) && println("Nothing to check")
    end
end
