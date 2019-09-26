"""
    metaoperator

Top level operator.
**jula> help("Metaoperator")
"""
function metaoperator(command, logicset::LogicalCombo; verbose = true)
    counter!()

    logicsetcopy = deepcopy(logicset)

    metaset = "XOR|IFF|IF|THEN|AND|OR"

    (sum(logicset[:]) == 0) && return logicset
    !occursin(Regex("(?:\b| )([><=|!+\\-^&]{4}|$metaset)(?:\b| )"), command) &&
      return superoperator(command, logicset, verbose=verbose)

    m = match(Regex("(^.*)(?:\b| )([><=|!+\\-^&]{4}|$metaset)(?:\b| )(.*?\$)"), command)
    left, operator, right = m.captures

    ℧left  = metaoperator(left , logicset, verbose=verbose)[:]
    ℧right = metaoperator(right, logicset, verbose=verbose)[:]
    ℧η = logicsetcopy[:]

    (operator ∈ ["&&&&", "AND"]) && (℧η = logicset[:] .& (℧left .& ℧right))
    (operator ∈ ["====", "IFF"]) && (℧η = logicset[:] .& (℧left .== ℧right))
    (operator ∈ ["===>", "THEN"]) && (℧η[℧left] = logicset[:][℧left]  .& ℧right[℧left])
    (operator ∈ ["!==>"]) && (℧η[.!℧left] = logicset[:][.!℧left]  .& ℧right[.!℧left])
    (operator ∈ ["<===", "IF"]) && (℧η[℧right] = logicset[:][℧right] .& ℧left[℧right])
    (operator ∈ ["||||", "OR"]) && (℧η = logicset[:] .& (℧left .| ℧right))

    (operator ∈ ["^^^^", "XOR", "!==="]) &&
      (℧η = logicset[:] .& ((℧left .& .!℧right) .| (.!℧left .& ℧right)))

    logicsetcopy[:] = ℧η
    logicsetcopy
end
