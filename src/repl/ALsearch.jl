function ALsearch(userinput; verbose=true)
    try
      checker = replace(userinput[7:end], r"^[\\:\\-\\ ]+"=>"")
      search(checker, replset, verbose = verbose)
      # push!(logicset, replset)
  catch er
      replthrow("Warning! Search Failed: $er")
    end
end
