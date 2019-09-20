function ALnext()
    (activehistory.current == length(activehistory.logicsets)) && (replthrow("Nothing to go forward to"); return)

    next!(activehistory)
    replset = activelogicset(activehistory)
    println(activecommand(activehistory) * " - " * reportfeasible())

end
