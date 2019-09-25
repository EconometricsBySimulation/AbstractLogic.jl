
function ALclear(; verbose = true)
    (length(replset.commands) || (replset.commands[end]=="#Session Started")) &&
      (verbose && println("Activeset already clear"); return)

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
