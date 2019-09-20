
function ALback()
    (activehistory.current == 1) && (replthrow("Nothing to go back to"); return)

    back!(activehistory)
    replset = activelogicset(activehistory)
    println(activecommand(activehistory) * " - " * reportfeasible())

end
