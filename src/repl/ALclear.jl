
function ALclear(; verbose = true)
    ((length(replset.commands)==0) || (replset.commands[end]=="#Session Started")) &&
      ((verbose && println("Activeset Already Empty")); return)

    newhistory = History()
    newreplset = activelogicset(newhistory)

    setactivehistory!(newhistory)
    setreplset!(newreplset)
    pushsessionhistory!(newreplset)
    verbose && println("Clearing Activeset")

end

function ALClear(; verbose = true)
    ALclear(verbose = false)
    setsessionhistory!(History())

    verbose && println("Clearing Everything!")
end
