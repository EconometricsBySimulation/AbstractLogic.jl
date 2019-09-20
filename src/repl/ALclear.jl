
function ALclear(; verbose = true)
    newhistory = History()
    newreplset = activelogicset(newhistory)

    setactivehistory!(newhistory)
    setreplset!(newreplset)
    pushsessionhistory!(newreplset)

    verbose && println("Clearing Activeset")
end

function ALclearall(; verbose = true)
    ALclear(verbose = false)
    setsessionhistory!(History())

    verbose && println("Clearing Everything!")
end
