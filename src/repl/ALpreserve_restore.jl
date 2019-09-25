
function ALpreserve(; verbose = true)
    setpreserver!(activehistory)
    verbose && println("Preserving State")
end

function ALrestore(; verbose = true)
    (preserver === missing) && (println("Nothing to restore"); return)

    ((length(replset.commands)==0) || (replset.commands[end]=="#Session Started"))
        popsessionhistory!()

    setreplset!(activelogicset(preserver))

    setactivehistory!(preserver)

    pushsessionhistory!(replset)

    verbose && println("Restoring State - " * reportfeasible())
end
