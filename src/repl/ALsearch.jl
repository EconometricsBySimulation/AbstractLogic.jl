function ALsearch(userinput)
    try
      checker = replace(userinput[7:end], r"^[\\:\\-\\ ]+"=>"")
      search(checker, replset, verbose = replcmdverbose & replverboseall)
      # push!(logicset, replset)
  catch er
      replthrow("Warning! Search Failed: $er")
    end
end
