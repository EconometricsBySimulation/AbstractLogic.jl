

function ALparse(userinput, logicset; verbose = true)
    if (nfeasible(logicset)==0) && !occursin(r"∈", userinput)
      replthrow("You are working with an empty set! Try inputing: a,b,c in 1:3")
      return
    end

    try
      logicset = logicalparse(userinput, logicset = logicset, verbose = verbose)
    catch ex
      replthrow("\ncommand Failed! $ex")
      return
    end

    push!(activehistory, logicset)
    update!(sessionhistory, logicset)
    setreplset!(logicset)

end
