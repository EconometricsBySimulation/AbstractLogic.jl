
# Global set variables logicset, Υ hold
integer(x::AbstractString) = parse(Int, strip(x))
Base.range(x::AbstractString) = range(integer(match(r"^[0-9]+", x).match),
                               stop = integer(match(r"[0-9]+$", x).match))
logicaloccursin(y::Symbol) = any( [ y ∈ keys(logicset[i]) for i in 1:length(logicset) ] )
logicaloccursin(x::LogicalCombo, y::Symbol) = y ∈ keys(x)

"""
    logicalparse

Takes a command and parses it into logical calls that either assigning
additional feasible variable ranges or constrain the relationship between
variables.

```julia
logicalparse(command::String; logicset::LogicalCombo = LogicalCombo(), verbose=true)
logicalparse(command::String, logicset::LogicalCombo; ...)
logicalparse(commands::Array{String,1}, logicset::LogicalCombo; ...)
logicalparse(commands::Array{String,1}; ...)
```
### Arguments
* `verbose` : specifies to print to screen or not

### Operators
There are numerous operators available to be used in the logical parse command.

### Examples
```julia
julia> myset = logicalparse("a, b, c in 1:3")
a,b,c in 1:3             feasible outcomes 27 ✓          :3 3 3

julia> myset = logicalparse("a == b", myset)
a == b                   feasible outcomes 9 ✓           :1 1 2

julia> myset = logicalparse("a > c", myset)
a > c                    feasible outcomes 3 ✓           :3 3 1

julia> myset = logicalparse("c != 1", myset)
c != 1                   feasible outcomes 1 ✓✓          :3 3 2
```
"""
function logicalparse(
    commands::Array{String,1};
    logicset::LogicalCombo = LogicalCombo(),
    verbose=true)

  verbose && println("")

  any(occursin.(";", commands)) &&
    (commands = split.(commands, ";") |> Iterators.flatten |> collect .|> strip .|> string)

  for command in commands
      logicset = logicalparse(command, logicset=logicset, verbose=verbose)
  end
  logicset
end

function logicalparse(
    command::String;
    logicset::LogicalCombo = LogicalCombo(),
    verbose=true)

    # A vector of non-standard operators to ignore
    generators = "in"
    superset = "xor|iff|if|then"
    metaset = "XOR|IFF|IF|THEN|AND|OR"

    exclusions = join([generators, superset, metaset],"|")

    occursin(";", command) &&
      return logicalparse(string.(strip.(split(command, ";"))),
        logicset=logicset, verbose=verbose)

    verbose && print(command)

    (strip(command) == "" || command[1] == '#') && return logicset

    occursin(r"∈|\bin\b", command) &&
      return definelogicalset(logicset, command) |>
        reportfeasible(command, verbose)  |>
        (x -> (push!(x.commands, command); return x))

    # Check for the existance of any symbols in logicset
    varcheck = eachmatch(r"[a-zA-Z][0-9a-zA-Z_.]*", command)

    # Checks if any of the variables does not exist in logicset
    for S in [Symbol(s.match) for s in varcheck if !(s.match ∈ split(exclusions, "|"))]
      if (occursin("{{", string(S))) && (!logicaloccursin(logicset, S))
        println("\t Warning! In {$command} variable {:$S} not found in logicset")
      end
    end

    # Replace command
    commandout = command |>
     x -> replace(x, r"(\b|\s)true(\b|\s)" =>" 1=1 ") |>
     x -> replace(x, r"(\b|\s)false(\b|\s)"=>" 1=0 ") |>
     x -> replace(x, r"^(IF|if|If)"=>"")

    if occursin(Regex("([><=|!+\\-^&]{1,4})"), commandout)
      return metaoperator(commandout, logicset, verbose = verbose) |>
        reportfeasible(command, verbose) |>
        (x -> (push!(x.commands, command); return x))
    end

    println("\t Warning! { $command } not interpreted!")
end

logicalparse(commands::Array{String,1}, logicset::LogicalCombo; I...) =
  logicalparse(commands, logicset=logicset, I...)

logicalparse(command::String, logicset::LogicalCombo; I...) =
  logicalparse(command, logicset=logicset, I...)


function reportfeasible(logicset::LogicalCombo;
    command=""::String,
    verbose=true::Bool)::LogicalCombo

    !verbose && return logicset
    filler = repeat("\t", max(1, 3-Integer(floor(length(command)/8))))

    Nfeas = nfeasible(logicset)

    (Nfeas == 0)  && (check = "X ")
    (Nfeas  > 1)  && (check = "✓ ")
    (Nfeas == 1)  && (check = "✓✓")

    ender = (Nfeas>0) ? ":" *
      join(logicset[rand(1:Nfeas),:,:], " ") : " [empty set]"

    println(" $filler feasible outcomes $Nfeas $check \t $ender")
    return logicset
end

reportfeasible(command::String, verbose::Bool)::Function =
  (x -> reportfeasible(x, command=command, verbose=verbose))

function definelogicalset(logicset::LogicalCombo, command::String)::LogicalCombo

    m = match(r"^\s*(.+?)(?:\b|\s)(?:in|∈)(?:\b|\s)([a-zA-Z0-9,._ :\"']+)(?:\|(.*?)){0,1}$", command)
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

function grab(argument::AbstractString, logicset::LogicalCombo; command = "")

  (argument[1:1]=="'") && return fill(replace(argument, "'"=>""), length(logicset[:]))

  matcher = r"^([a-zA-z][a-zA-z0-9.]*)*([0-9]+)*([+\-*/])*([a-zA-z][a-zA-z0-9]*)*([0-9]+)*$"

  m = match(matcher, argument)
  nvar = 5-sum([i === nothing for i in m.captures])
  (nvar==0) && throw("Argument $argument could not be parsed in $command")

  v1, n1, o1, v2, n2 = m.captures

  !(v1 === nothing) && (left  = logicset[:,Symbol(v1),true])
  !(n1 === nothing) && (left  = fill(integer(n1), length(logicset[:])))

  (nvar==1) && return left

  !(v2 === nothing) && (right = logicset[:,Symbol(v2),true])
  !(n2 === nothing) && (right = fill(integer(n2), length(left)))

  (o1 == "+") && return left .+ right
  (o1 == "-") && return left .- right
  (o1 == "/") && return left ./ right
  (o1 == "*") && return left .* right
end

function operatorspawn(command,
    logicset::LogicalCombo;
    returnlogical=false,
    prefix=">>> ",
    verbose=true)

    logicsetcopy = deepcopy(logicset)

    tempcommand = command
    m = eachmatch(r"(\{\{.*?\}\})", tempcommand)
    matches = [replace(x[1], r"\{|\}"=>"") for x in collect(m)] |> unique

    # Check if a {{j}}. structure or {{J}}. structure exists
    m_dot = eachmatch(r"(\{\{[jJ]\}\})(\.[a-zA-Z0-9_.])", tempcommand)
    matches_dot = string.([x.captures[2] for x in collect(m_dot)]) |> unique

    if occursin(r"^[0-9]+,[0-9]+$", matches[end])
        countrange = (x -> x[1]:x[2])(integer.(split(matches[end], ",")))
        tempcommand = replace(tempcommand, "{{$(matches[end])}}"=>"") |> strip
        matches = matches[1:(end-1)]
    elseif occursin(r"^[0-9]+,$", matches[end])
        countrange = integer(matches[end][1:(end-1)]):size(logicset,2)^2
        tempcommand = replace(tempcommand, "{{$(matches[end])}}"=>"") |> strip
        matches = matches[1:(end-1)]
    elseif occursin(r"^,[0-9]+$", matches[end])
        countrange = 0:integer(matches[end][2:end])
        tempcommand = replace(tempcommand, "{{$(matches[end])}}"=>"") |> strip
        matches = matches[1:(end-1)]
    elseif occursin(r"^[0-9]+$", matches[end])
        countrange = (x -> x[1]:x[1])(integer(matches[end]))
        tempcommand = replace(tempcommand, "{{$(matches[end])}}"=>"") |> strip
        matches = matches[1:(end-1)]
    else
        countrange = missing
    end


    iSet  = [m for m in matches if m[end:end] ∈ ["i", "j", "J"]]
    iSet1 = [m[1:1] for m in iSet]
    iSet2 = [m[1:2] for m in iSet if length(m)>=2]

    iSetend = unique([m[end:end] for m in iSet])

    (length(iSet)>2) && throw("Only one !i, >i, >=i, <=i, <i wildcard allowed with i (or j/J)")
    (length(iSetend)>1) && throw("Only one type i or j wildcard allowed")

    mykeys   = keys(logicset)
    any(occursin.("J", iSet)) && (mykeys = [v for v in mykeys if !occursin(".", string(v))])
    any(occursin.("j", iSet)) &&
      (mykeys = unique([Symbol(replace(v, r"\..*$"=>"")) for v in string.(mykeys)]))

    mydomain = 1:length(mykeys)

    wild  = matches[length.(matches) .== 1]
    wild2 = matches[length.(matches) .!= 1]

    collection = []

    verbose && println()

    iset = Symbol[]

    for i in mydomain, j in mydomain
      ((length(wild2)  == 0) || wild2[1][1] ∈ ["i","j","J"]) && (j>1)  && continue
      ("!"   ∈ iSet1)       && (i==j) && continue
      (">"   ∈ iSet1)       && (i>=j) && continue
      ("<"   ∈ iSet1)       && (i<=j) && continue
      (">="  ∈ iSet2)       && (i<j)  && continue
      ("<="  ∈ iSet2)       && (i>j)  && continue
      #println("$i and $j")

       txtcmd = tempcommand

       # Sub out the j match in the command
       (length(wild2)==1) && !(wild2[1][1] ∈ ["i","j","J"]) &&
         (txtcmd = subout(txtcmd, j, wild2[1], mykeys))

       # Sub out the i match in the command
       (length(wild2)==1) &&  (wild2[1][1] ∈ ["i","j","J"]) &&
         (txtcmd = subout(txtcmd, i, wild2[1], mykeys))

       (length(wild)  == 1) && (txtcmd = subout(txtcmd, i, wild[1], mykeys))

       if occursin("~~OUTOFBOUNDS~~", txtcmd)
           # ("i" ∈ iSet) && push!(collection, fill(false, length(logicset[:])))
           continue
       end

       ℧∇ = logicset[:]
       try
           ℧∇ = superoperator(txtcmd, logicset, verbose=verbose)[:]
           verbose &&  println(prefix * "$txtcmd")
       catch
       end

       push!(collection, ℧∇)
       (length(matches_dot)==0) && push!(iset, mykeys[i])
       (length(matches_dot)>0)  && push!(iset, Symbol(string(mykeys[i]) * matches_dot[1]))
    end

    collector = hcat(collection...)

    returnlogical && return [collector, iset]

    if (countrange === missing)
      ℧Δ = logicset[:] .& [all(collector[i,:]) for i in 1:size(collector)[1]]
    else
      ℧Δ = logicset[:] .& [sum(collector[i,:]) ∈ countrange for i in 1:size(collector)[1]]
    end

    logicsetcopy[:] = ℧Δ
    logicsetcopy
end

function subout(txtcmd, i, arg, mykeys)
  lookup(vect, i) = i ∈ 1:length(vect) ? vect[i] : "~~OUTOFBOUNDS~~"

  (arg[end] ∈ ['i', 'j', 'J'])  && return replace(txtcmd, "{{$arg}}"=>lookup(mykeys,i))

  mod = integer(match(r"([0-9]+$)", arg).match)

  occursin("+", arg) && return replace(txtcmd, "{{$arg}}"=>lookup(mykeys,i+mod))
  occursin("-", arg) && return replace(txtcmd, "{{$arg}}"=>lookup(mykeys,i-mod))

  txtcmd
end



"""

"""
function metaoperator(command, logicset::LogicalCombo; verbose = true)
    logicsetcopy = deepcopy(logicset)

    metaset = "XOR|IFF|IF|THEN|AND|OR"

    (sum(logicset[:]) == 0) && return logicset
    !occursin(Regex("([><=|!+\\-^&]{4}|$metaset)"), command) &&
      return superoperator(command, logicset, verbose=verbose)

    m = match(Regex("(^.*?)[ ]*([><=|!+\\-^&]{4}|$metaset)[ ]*(.*?\$)"), command)
    left, operator, right = m.captures

    ℧left  = metaoperator(left , logicset, verbose=verbose)[:]
    ℧right = metaoperator(right, logicset, verbose=verbose)[:]
    ℧η = logicsetcopy[:]

    (operator ∈ ["&&&&", "AND"]) && (℧η = logicset[:] .& (℧left .& ℧right))
    (operator ∈ ["====", "IFF"]) && (℧η = logicset[:] .& (℧left .== ℧right))
    (operator ∈ ["===>", "THEN"]) && (℧η[℧left] = logicset[:][℧left]  .& ℧right[℧left])
    (operator ∈ ["<===", "IF"]) && (℧η[℧right] = logicset[:][℧right] .& ℧left[℧right])
    (operator ∈ ["||||", "OR"]) && (℧η = logicset[:] .& (℧left .| ℧right))
    (operator ∈ ["^^^^", "XOR", "!==="]) && (℧η = logicset[:] .& ((℧left .& .!℧right) .| (.!℧left .& ℧right)))

    logicsetcopy[:] = ℧η
    logicsetcopy
end

##########################################################################
##########################################################################


function superoperator(command, logicset::LogicalCombo; verbose=true)
    logicsetcopy = deepcopy(logicset)

    superset = "xor|iff|if|then|or|and"

    #println("operatoreval($command)")
    (sum(logicset[:]) == 0) && return logicset
    !occursin(Regex("([><=|!+\\-^&]{3}|$superset)"), command) &&
      return operatoreval(command, logicset, verbose=verbose)
    occursin(r"\{\{.*\}\}", command) &&
      return operatorspawn(command, logicset, verbose=verbose)

    m = match(Regex("(^.*?)[ ]*([><=|!+\\-\\^&]{3}|$superset)[ ]*(.*?\$)"), command)
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

    elseif operator ∈ ["<==", "if"]
        ℧η[℧right] = ℧[℧right] .& ℧left[℧right]

    end

    logicsetcopy[:] = ℧η
    logicsetcopy
end

##########################################################################
##########################################################################




##########################################################################
##########################################################################


"""
    checkfeasible(command::String, logicset::LogicalCombo; verbose=true, force=false, countany=false)

Is called when the user would like to check if a command produces a valid result,
possible result, or invalid result. The result is returned as a decimal from 0.0
to 1.0. With 0.0 being no matches and 1.0 being all matches.

### Arguments
* `verbose` : controls print
* `force` : all sets have to be feasible or return 0
* `countany` : any set can be non-zero to return 1

### Examples
```julia
julia> myset = logicalparse("a, b, c ∈ red, blue, green")
a, b, c ∈ red, blue, green       feasible outcomes 27 ✓          :red blue blue

julia> myset = logicalparse("a != b,c; b = c ==> a = 'blue'", myset)
a != b,c                 feasible outcomes 12 ✓          :green blue blue
b = c ==> a = 'blue'     feasible outcomes 8 ✓           :blue green green

julia> checkfeasible("a = 'green' ==> b = 'red'", myset)
Check: a = 'green' ==> b = 'red' ... a = 'green' ==> b = 'red'   feasible outcomes 17 ✓          :blue red green
possible,  17 out of 21 possible combinations 'true'.
```
"""
function checkfeasible(command::String,
    logicset::LogicalCombo = LogicalCombo();
    verbose=true, force=false, countany=false)

  countany && force && throw("Both any and force can't be set to true")

  rowsin = sum(logicset.logical)

  if rowsin == 0
      println("No outcomes feasible outcomes with set!")
      return missing
  end

  print("Check: $command ... ")

  logicsetout = logicalparse(command, logicset=logicset) #, verbose=false)

  rowsout = sum(logicsetout.logical)
  outcomeratio = rowsout/rowsin

  if force
        outcomeratio != 1 && print("false,")
        outcomeratio == 1 && print("true,")
  elseif countany
        outcomeratio == 0 && print("false,")
        outcomeratio != 0 && print("true,")
  else
      outcomeratio == 1 && print("true,")
      outcomeratio == 0 && print("false,")
      (1 > outcomeratio > 0) && print("possible, ")
  end

  println(" $rowsout out of $rowsin possible combinations 'true'.")

  return [outcomeratio, logicsetout]
end

##########################################################################
##########################################################################


"""
    search(command::String, logicset::LogicalCombo; verbose=true)

Searches for a possible match among a LogicalCombo in which the wildcard term
is true. Search requires the use of a wildcard. In the event that a wildcard
is missing, search will insert a {{i}} to the left of the command.*{{i+1}}* can
be used to search for relationships between the ith column and another
column.

### Examples
```julia
julia> myset = logicalparse("v1, v2, v3 ∈ 1:10")
v1, v2, v3 ∈ 1:10        feasible outcomes 1000 ✓        :6 6 10

julia> myset = logicalparse("{{i}} >> {{i+1}}", myset)
{{i}} >> {{i+1}}
>>> v1 >> v2
>>> v2 >> v3
         feasible outcomes 56 ✓          :10 7 3

julia> search("{{i}} == 4", myset)
Checking: v1 == 4
Checking: v2 == 4
Checking: v3 == 4

:v1 is a not match with 0 feasible combinations out of 56.
:v2 is a possible match with 10 feasible combinations out of 56.
:v3 is a possible match with 6 feasible combinations out of 56.

julia> search("== 4", myset, verbose=false) == search("{{i}} == 4", myset, verbose=false)
true

julia> search("{{i}} > {{!i}}", myset)
Checking: v1 > v2
Checking: v1 > v3
Checking: v2 > v1
Checking: v2 > v3
Checking: v3 > v1
Checking: v3 > v2

:v1 is a match with 56 feasible combinations out of 56.
:v2 is a not match with 0 feasible combinations out of 56.
:v3 is a not match with 0 feasible combinations out of 56.
```
"""
function search(command::String, logicset::LogicalCombo; verbose=true)

    rowsin = nfeasible(logicset)

    if rowsin == 0
        println("No outcomes feasible outcomes with set!")
        return missing
    end

    !occursin(raw"{{", command) &&
      !occursin(r"^[><=|!^&]", command) &&
      throw("No syntax match. Enter form '{{i}} = ...' or '= ...'")

    !occursin(raw"{{", command) &&
      occursin(r"^[><=|!^&]", command) &&
      (command = "{{i}} " * command)

    colcheck = operatorspawn(command,
      logicset,
      returnlogical=true,
      prefix="Checking: ",
      verbose=verbose)

    colcount = Any[]

    for i in 1:size(logicset, 2)
      select = colcheck[1][:, colcheck[2] .== logicset.keys[i]]
      (size(select,2) == 0) && push!(colcount,missing)
      (size(select,2) > 0 ) && push!(colcount, [all(select[j,:]) for j in 1:size(select,1)] |> sum)
    end

    # colcount = [sum(colcheck[:,i]) for i in 1:size(colcheck,2)]

    if verbose
        println()
        for i in 1:size(logicset,2)
          if colcount[i] === missing
              println(":$(logicset.keys[i]) could not be evaluated at $command.")
              continue
          end
          (colcount[i] == rowsin) && print(":$(logicset.keys[i]) is a match")
          (colcount[i] == 0) && print(":$(logicset.keys[i]) is a not match")
          (colcount[i] > 0) && (colcount[i] < rowsin) &&
            print(":$(logicset.keys[i]) is a possible match")
          println(" with $(colcount[i]) feasible combinations out of $rowsin.")
        end
    end

    return colcount ./ rowsin
end


function back(logicset::LogicalCombo; verbose=false)
  (length(logicset.commands)==0) && (println("Nothing to go back to!"); return logicset)
  commandlist = copy(logicset.commands)
  pop!(commandlist)
  return logicalparse(commandlist, verbose=verbose)
end
