#using Pkg
#cd("c:/Users/francis.smart.ctr/GitDir/AbstractLogicJL")
#Pkg.activate(".")

# Global set variables logicset, Υ hold
integer(x::AbstractString) = parse(Int, strip(x))
Base.range(x::AbstractString) = range(integer(match(r"^[0-9]+", x).match),
                               stop = integer(match(r"[0-9]+$", x).match))
logicaloccursin(y::Symbol) = any( [ y ∈ keys(logicset[i]) for i in 1:length(logicset) ] )
logicaloccursin(x::LogicalCombo, y::Symbol) = y ∈ keys(x)

#command = "a,b,c,d ∈ 1:5"
#logicset = logicalparse(["a, b, c  ∈  [1,2,3]"]); logicset[℧]
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

  println("")

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
    exclusionlist = ["in","xor","XOR", "iff", "IFF"]

    occursin(";", command) &&
      return logicalparse(string.(strip.(split(command, ";"))),
        logicset=logicset, verbose=verbose)

    print(command)

    (strip(command) == "" || command[1] == '#') && return logicset

    occursin(r"∈|\bin\b", command) &&
      return definelogicalset(logicset, command) |> reportfeasible(command, verbose)

    # Check for the existance of any symbols in logicset
    varcheck = eachmatch(r"[a-zA-Z][0-9a-zA-Z_.]*", command)

    # Checks if any of the variables does not exist in logicset
    for S in [Symbol(s.match) for s in varcheck if !(s.match ∈ exclusionlist)]
      if (occursin("{{", string(S))) && (!logicaloccursin(logicset, S))
        println("   In {$command} variable {:$S} not found in logicset")
      end
    end

    if occursin(r"([><=|!+\\-\^\\&]{1,4}|XOR|xor)", command)
      return metaoperator(command, logicset) |>
        reportfeasible(command, verbose)
    end

    println("    Warning! { $command } not interpreted!")
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

  left, right = strip.(split(command, r"∈|\bin\b"))
  vars   = split(left, ",") .|> strip
  values = split(right, ",") .|> strip

  if length(values) == 1 && occursin(r"^[0-9]+:[0-9]+$", values[1])
    values = range(values[1])
    outset = (; zip([Symbol(i) for i in vars], fill(values, length(vars)))...)
    outset = [Pair(Symbol(i), values) for i in vars]
    logicset  = expand(logicset, outset)

  elseif all([occursin(r"^[0-9]+$", i) for i in values])
    values =  [integer(i) for i in values]
    logicset  = expand(logicset, string.(vars), values)

  else
    logicset  = expand(logicset, string.(vars), string.(values))
  end

  logicset
end

function grab(argument::AbstractString, logicset::LogicalCombo; command = "")

  (argument[1:1]=="'") && return fill(replace(argument, "'"=>""), length(logicset[:]))

  matcher = r"^([a-zA-z][a-zA-z0-9]*)*([0-9]+)*([+\-*/])*([a-zA-z][a-zA-z0-9]*)*([0-9]+)*$"

  m = match(matcher, argument)
  nvar = 5-sum([i === nothing for i in m.captures])
  (nvar==0) && throw("Argument $argument could not be parsed in $command")

  v1, n1, o1, v2, n2 = m.captures

  !(v1 === nothing) && (left  = logicset[:,:,Symbol(v1)])
  !(n1 === nothing) && (left  = fill(integer(n1), length(logicset[:])))

  (nvar==1) && return left

  !(v2 === nothing) && (right = logicset[:,:,Symbol(v2)])
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

    mykeys = keys(logicset)
    mydomain = 1:length(mykeys)

    iSet  = [m for m in matches if m[end:end] ∈ ["i", "j"]]
    iSet1 = [m[1:1] for m in iSet]
    iSet2 = [m[1:2] for m in iSet if length(m)>=2]
    iSetend = unique([m[end:end] for m in iSet])

    (length(iSet)>2) && throw("Only one !i, >i, >=i, <=i, <i wildcard allowed with i (or j)")
    (length(iSetend)>1) && throw("Only one type i or j allowed")

    wild  = matches[length.(matches) .== 1]
    wild2 = matches[length.(matches) .!= 1]

    collection = []

    verbose && println()

    iset = Symbol[]

    for i in mydomain, j in mydomain
      ((length(wild2)  == 0) || wild2[1][1] ∈ 'i':'j') && (j>1)  && continue
      ("!"   ∈ iSet1)       && (i==j) && continue
      (">"   ∈ iSet1)       && (i>=j) && continue
      ("<"   ∈ iSet1)       && (i<=j) && continue
      (">="  ∈ iSet2)       && (i<j)  && continue
      ("<="  ∈ iSet2)       && (i>j)  && continue
      #println("$i and $j")

       txtcmd = tempcommand

       (length(wild2)==1) && !(wild2[1][1] ∈ 'i':'j') &&
         (txtcmd = subout(txtcmd, j, wild2[1], mykeys))

       (length(wild2)==1) &&  (wild2[1][1] ∈ 'i':'j') &&
         (txtcmd = subout(txtcmd, i, wild2[1], mykeys))

       (length(wild)  == 1) && (txtcmd = subout(txtcmd, i, wild[1], mykeys))

       if occursin("~~OUTOFBOUNDS~~", txtcmd)
           # ("i" ∈ iSet) && push!(collection, fill(false, length(logicset[:])))
           continue
       end

       ℧∇ = superoperator(txtcmd, logicset)[:]

       verbose &&  println(prefix * "$txtcmd")

       push!(collection, ℧∇)
       push!(iset, mykeys[i])
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

  (arg[end] ∈ ['i', 'j'])  && return replace(txtcmd, "{{$arg}}"=>lookup(mykeys,i))

  mod = integer(match(r"([0-9]+$)", arg).match)

  occursin("+", arg) && return replace(txtcmd, "{{$arg}}"=>lookup(mykeys,i+mod))
  occursin("-", arg) && return replace(txtcmd, "{{$arg}}"=>lookup(mykeys,i-mod))

  txtcmd
end
