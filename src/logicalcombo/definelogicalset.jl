function definelogicalset(logicset::LogicalCombo, command::String)::LogicalCombo

    m = match(r"^\s*(.+?)(?:\b|\s)(?:in|∈)(?:\b|\s)([a-zA-Z0-9,._ :\"']+)(?:\|\|(.*?)){0,1}$", command)
    left, right, condition = strip.((x -> x === nothing ? "" : x).(m.captures))
    vars   = split(left, ",")  .|> strip
    values = split(right, ",") .|> strip

    for v in vars
        m = match.(r"(\s|\"|\')", v)
        (m != nothing) && throw("Variable names cannot have {$(m.captures[1])}.")
    end

    for v in values
        m = match.(r"(\"|\')", v)
        (m != nothing) && throw("Variable values cannot be defined with {$(m.captures[1])}.")
    end

    varnames = string.(vars)

    if length(values) == 1 && occursin(r"^[0-9]+:[0-9]+$", values[1])
        values = collect(range(values[1]))
    elseif all([occursin(r"^[0-9]+$", i) for i in values])
        values =  [integer(i) for i in values]
    else
        values = string.(values)
    end

    if condition == ""
        logicset  = expand(logicset, varnames, values)
    else # Loops through conditionals and sets restrictions on data as it is generated
        for i in 1:length(varnames)
          logicset  = expand(logicset, [varnames[i]], values)
          try
            templogicset = operatorspawn(condition, logicset, verbose=false)
            logicset = templogicset
          catch
          end
        end
    end

  logicset
end

definelogicalset(command::String) = definelogicalset(LogicalCombo(), command)
