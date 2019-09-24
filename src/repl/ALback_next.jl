
function ALback(; verbose=true)
    (activehistory.current == 1) && (replthrow("Nothing to go back to"); return)

    back!(activehistory)
    replset = activelogicset(activehistory)
    verbose && println(activecommand(activehistory) * " - " * reportfeasible())

end

function ALnext(; verbose=true)
    (activehistory.current == length(activehistory.logicsets)) && (replthrow("Nothing to go forward to"); return)

    next!(activehistory)
    replset = activelogicset(activehistory)
    verbose &&  println(activecommand(activehistory) * " - " * reportfeasible())

end
