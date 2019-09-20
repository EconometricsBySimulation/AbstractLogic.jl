
function ALpreserve(; verbose = true)
    setpreserver!(activehistory)
    verbose && println("Preserving State")
end

function ALrestore(; verbose = true)
    (preserver === missing) && (println("Nothing to restore"); return)

    setreplset!(activelogicset(preserver))

    setactivehistory!(preserver)

    pushsessionhistory!(replset)

    verbose && println("Restoring State - " * reportfeasible())
end
