function definelogicalset(logicset::LogicalCombo, command::String)::LogicalCombo
    counter!()
    m = match(r"^\s*(.+?)(?:\b|\s)(?:in|∈)(?:\b|\s)([a-zA-Z0-9,._ :\"']+)(?:\|\|(.*?)){0,1}$", command)
    left, right, condition = strip.((x -> x === nothing ? "" : x).(m.captures))
    vars   = split(left, ",")  .|> strip
    values = split(right, ",") .|> strip

    occursin(r"\[*unique(\s|\])*$", command) && return defineuniquelogicalset(logicset, command)

    (logicset.type == "UniquePermutation") && throw("Unique sets cannot have variables added to them!")

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

function defineuniquelogicalset(logicset::LogicalCombo, command::String)::LogicalCombo
  (nfeasible(logicset) > 0) && throw("Unique Permutation Sets must be generated from scratch")

  command = replace(command, r"\|*\s*unique\s*$" => "")

  m = match(r"^\s*(.+?)(?:\b|\s)(?:in|∈)(?:\b|\s|)([a-zA-Z0-9,._ :\"']*)(?:\|\|(.*?)){0,1}$", command)
  left, right, condition = strip.((x -> x === nothing ? "" : x).(m.captures))
  vars   = split(left , ",")  .|> strip
  values = split(right, ",")  .|> strip

  if length(values) == 1 && occursin(r"^[0-9]+:[0-9]+$", values[1])
      values = collect(range(values[1]))
  elseif all([occursin(r"^[0-9]+$", i) for i in values])
      values =  [integer(i) for i in values]
  else
      values = string.(values)
  end

  mykeys    = [Symbol(v) for v in vars]

  (right == "") && (mydomain = 1:length(mykeys))
  (length(values) > 1)  && (mydomain = values)

  (length(mydomain) != length(mykeys)) && throw("Variable Lengths Need to Equal Number of Variables")

  mylogical = fill(true, factorial(length(mydomain)))
  LogicalCombo(mykeys, mydomain, mylogical, permutationuniquelookup, "UniquePermutation")
end
