function superoperator(command, logicset::LogicalCombo)
    logicsetcopy = deepcopy(logicset)

    superset = "xor|iff"

    #println("operatoreval($command)")
    (sum(logicset[:]) == 0) && return logicset
    !occursin(Regex("([><=|!+\\-^&]{3}|$superset)"), command) &&
      return operatoreval(command, logicset)
    occursin(r"\{\{.*\}\}", command) && return operatorspawn(command, logicset)

    m = match(Regex("(^.*?)[ ]*([><=|!+\\-\\^&]{3}|$superset)[ ]*(.*?\$)"), command)
    left, operator, right = m.captures

    ℧left  = superoperator(left ,logicset)[:]
    ℧right = superoperator(right,logicset)[:]

    ℧ = logicset[:]
    ℧η = deepcopy(℧)

    if operator == "&&&"
        ℧η = ℧ .& (℧left .& ℧right)

    elseif operator ∈ ["^^^" , "xor"]
        ℧η = ℧ .& ((℧left .& .!℧right) .| (.!℧left .& ℧right))

    # this can be dangerous, false equal to false such as with previous exclusions will cause inconsistencies
    elseif operator ∈ ["<=>","===", "iff"]
        ℧η = ℧ .& (℧left .== ℧right)

    #warning this generally will not work
    elseif operator == "---"
        ℧η[℧] = (℧left .- ℧right)[℧]

    #warning this generally will not work
    elseif operator == "+++"
        ℧η = ℧left .+ ℧right

    elseif operator == "|||"
        ℧η = ℧ .& (℧left .| ℧right)

    elseif operator ∈ ["|=>","==>"]
        ℧η[℧left] .= ℧[℧left]  .& ℧right[℧left]

    elseif operator ∈ ["<=|","<=="]
        ℧η[℧right] = ℧[℧right] .& ℧left[℧right]

    end

    logicsetcopy[:] = ℧η
    logicsetcopy
end
