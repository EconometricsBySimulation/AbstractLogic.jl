function superoperator(command, logicset::LogicalCombo; verbose=true)
    counter!()

    logicsetcopy = deepcopy(logicset)

    superset = "xor|iff|if|or|and|notthen|then"

    #println("operatoreval($command)")
    (sum(logicset[:]) == 0) && return logicset
    !occursin(Regex("(\b| )([><=|!+\\-^&]{3}|$superset)(\b| )"), command) &&
      return operatoreval(command, logicset, verbose=verbose)
    occursin(r"\{\{.*\}\}", command) &&
      return operatorspawn(command, logicset, verbose=verbose)

    m = match(Regex("(^.*)(?:\b| )([><=|!+\\-\\^&]{3}|$superset)(?:\b| )(.*?\$)"), command)
    left, operator, right = m.captures

    ℧left  = superoperator(left ,logicset, verbose=verbose)[:]
    ℧right = superoperator(right,logicset, verbose=verbose)[:]

    ℧ = logicset[:]
    ℧η = deepcopy(℧)

    if operator ∈ ["&&&", "and"]
        ℧η = ℧ .& (℧left .& ℧right)

    elseif operator ∈ ["^^^" , "xor", "!=="]
        ℧η = ℧ .& ((℧left .& .!℧right) .| (.!℧left .& ℧right))

    # this can be dangerous, false equal to false such as with previous exclusions will cause inconsistencies
    elseif operator ∈ ["<=>","===", "iff"]
        ℧η = ℧ .& (℧left .== ℧right)

    elseif operator ∈ ["|||", "or"]
        ℧η = ℧ .& (℧left .| ℧right)

    elseif operator ∈ ["==>", "then"]
        ℧η[℧left] .= ℧[℧left]  .& ℧right[℧left]

    elseif operator ∈ ["!=>"]
        ℧η[.!℧left] .= ℧[.!℧left]  .& ℧right[.!℧left]

    elseif operator ∈ ["<==", "if"]
        ℧η[℧right] = ℧[℧right] .& ℧left[℧right]

    end

    logicsetcopy[:] = ℧η
    logicsetcopy
end
