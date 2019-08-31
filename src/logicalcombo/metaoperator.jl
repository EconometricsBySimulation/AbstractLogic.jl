"""

"""
function metaoperator(command, logicset::LogicalCombo)
    logicsetcopy = deepcopy(logicset)

    metaset = "XOR|IFF"

    (sum(logicset[:]) == 0) && return logicset
    !occursin(Regex("([><=|!+\\-^&]{4}|$metaset)"), command) &&
      return superoperator(command, logicset)

    m = match(Regex("(^.*?)[ ]*([><=|!+\\-^&]{4}|$metaset)[ ]*(.*?\$)"), command)
    left, operator, right = m.captures

    ℧left  = metaoperator(left , logicset)[:]
    ℧right = metaoperator(right, logicset)[:]
    ℧η = logicsetcopy[:]

    (operator == "&&&&") && (℧η = logicset[:] .& (℧left .& ℧right))
    (operator ∈ ["====", "IFF"]) && (℧η = logicset[:] .& (℧left .== ℧right))
    (operator ∈ ["===>"]) && (℧η[℧left] = logicset[:][℧left]  .& ℧right[℧left])
    (operator ∈ ["<==="]) && (℧η[℧right] = logicset[:][℧right] .& ℧left[℧right])
    (operator ∈ ["||||"]) && (℧η = logicset[:] .& (℧left .| ℧right))
    (operator ∈ ["^^^^", "XOR"]) && (℧η = logicset[:] .& ((℧left .& .!℧right) .| (.!℧left .& ℧right)))

    logicsetcopy[:] = ℧η
    logicsetcopy
end
