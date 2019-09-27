
function ALback(; verbose=true)
    (activehistory.current == 1) && (replthrow("Nothing to go back to"); return)

    back!(activehistory)
    setreplset!(activelogicset(activehistory))
    verbose && println(activecommand(activehistory) * " - " * reportfeasible(replset))

end

function ALnext(; verbose=true)
    (activehistory.current == length(activehistory.logicsets)) && (replthrow("Nothing to go forward to"); return)

    next!(activehistory)
    setreplset!(activelogicset(activehistory))
    verbose &&  println(activecommand(activehistory) * " - " * reportfeasible(replset))

end
