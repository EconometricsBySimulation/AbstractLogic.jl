function ALcheck(userinput; verbose=true)
    try
      inputpass = string(replace(userinput, r"^(check|prove|all|any|✓)[\\:\\-\\ ]*"=>""))
      occursin(r"^(check|✓)[\\:\\-\\ ]+", userinput) &&
        checkfeasible(inputpass, replset, verbose = verbose)
      occursin(r"^(prove|all)[\\:\\-\\ ]+", userinput) &&
        checkfeasible(inputpass, replset, countall=true, verbose = verbose)
      occursin(r"^any[\\:\\-\\ ]+", userinput) &&
        checkfeasible(inputpass, replset, countany=true, verbose = verbose)
      # push!(logicset, replset)
  catch er
      replthrow("\nWarning! Check Fail: $er")
      (length(userinput) == 5) && println("Nothing to check")
    end
end
