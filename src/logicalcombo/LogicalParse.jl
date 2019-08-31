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

function logicalparse(
    commands::Array{String,1};
    logicset::LogicalCombo = LogicalCombo(),
    verbose=true)

  println("")

  any(occursin.(";", commands)) &&
    (commands = split.(commands, ";") |> Iterators.flatten |> collect .|> strip .|> string)

  for command in commands
      print(command)
      logicset = logicalparse(command, logicset=logicset, verbose=verbose)

      feasibleN = sum(logicset.logical)
      filler = repeat("\t", max(1, 3-Integer(floor(length(command)/8))))

      (feasibleN == 0)  && (check = "X ")
      (feasibleN  > 1)  && (check = "✓ ")
      (feasibleN == 1)  && (check = "✓✓")

      ender = (feasibleN>0) ? ":" * join(logicset[rand(1:feasibleN),:,:], " ") : " [empty set]"

      verbose && println(" $filler feasible outcomes $feasibleN $check \t $ender")

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

  (strip(command) == "" || command[1] == '#') && return logicset

  occursin(r"∈|\bin\b", command) && return definelogicalset(logicset, command)

  # Check for the existance of any symbols in logicset
  varcheck = eachmatch(r"[a-zA-Z][0-9a-zA-Z_.]*", command)

  # Checks if any of the variables does not exist in logicset
  for S in [Symbol(s.match) for s in varcheck if !(s.match ∈ exclusionlist)]
      if (occursin("{{", string(S))) && (!logicaloccursin(logicset, S))
          println("   In {$command} variable {:$S} not found in logicset")
      end
  end

  occursin(r"([><=|!+\\-\^\\&]{1,4}|XOR|xor)", command) &&
    return metaoperatoreval(command,logicset)

  println("    Warning! { $command } not interpreted!")
end

logicalparse(commands::Array{String,1}, logicset::LogicalCombo; I...) =
  logicalparse(commands, logicset=logicset, I...)

logicalparse(command::String, logicset::LogicalCombo; I...) =
  logicalparse(command, logicset=logicset, I...)

function definelogicalset(logicset::LogicalCombo, command::String)

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

# definelogicalset(LogicalCombo(), "a,b,c ∈ 1:3")[:,:]
# definelogicalset(LogicalCombo(), "a,b,c ∈ 1,2,3")[:,:]
# definelogicalset(LogicalCombo(), "a,b,c ∈ boy, dog, cat")[:,:]

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

       ℧∇ = superoperatoreval(txtcmd, logicset)[:]

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

function metaoperatoreval(command, logicset::LogicalCombo)
    logicsetcopy = deepcopy(logicset)

    metaset = "XOR|IFF"

    #println("operatoreval($command)")
    (sum(logicset[:]) == 0) && return logicset
    !occursin(Regex("([><=|!+\\-^&]{4}|$metaset)"), command) &&
      return superoperatoreval(command, logicset)

    m = match(Regex("(^.*?)[ ]*([><=|!+\\-^&]{4}|$metaset)[ ]*(.*?\$)"), command)
    left, metaoperator, right = m.captures

    ℧left  = metaoperatoreval(left , logicset)[:]
    ℧right = metaoperatoreval(right, logicset)[:]
    ℧η = logicsetcopy[:]

    (metaoperator == "&&&&") && (℧η = logicset[:] .& (℧left .& ℧right))
    (metaoperator ∈ ["====", "IFF"]) && (℧η = logicset[:] .& (℧left .== ℧right))
    (metaoperator ∈ ["===>"]) && (℧η[℧left] = logicset[:][℧left]  .& ℧right[℧left])
    (metaoperator ∈ ["<==="]) && (℧η[℧right] = logicset[:][℧right] .& ℧left[℧right])
    (metaoperator ∈ ["||||"]) && (℧η = logicset[:] .& (℧left .| ℧right))
    (metaoperator ∈ ["^^^^", "XOR"]) && (℧η = logicset[:] .& ((℧left .& .!℧right) .| (.!℧left .& ℧right)))

    logicsetcopy[:] = ℧η
    logicsetcopy
end

function superoperatoreval(command, logicset::LogicalCombo)
    logicsetcopy = deepcopy(logicset)

    superset = "xor|iff"

    #println("operatoreval($command)")
    (sum(logicset[:]) == 0) && return logicset
    !occursin(Regex("([><=|!+\\-^&]{3}|$superset)"), command) &&
      return operatoreval(command, logicset)
    occursin(r"\{\{.*\}\}", command) && return operatorspawn(command, logicset)

    m = match(Regex("(^.*?)[ ]*([><=|!+\\-\\^&]{3}|$superset)[ ]*(.*?\$)"), command)
    left, superoperator, right = m.captures

    ℧left  = superoperatoreval(left ,logicset)[:]
    ℧right = superoperatoreval(right,logicset)[:]

    ℧ = logicset[:]
    ℧η = deepcopy(℧)

    if superoperator == "&&&"
        ℧η = ℧ .& (℧left .& ℧right)

    elseif superoperator ∈ ["^^^" , "xor"]
        ℧η = ℧ .& ((℧left .& .!℧right) .| (.!℧left .& ℧right))

    # this can be dangerous, false equal to false such as with previous exclusions will cause inconsistencies
    elseif superoperator ∈ ["<=>","===", "iff"]
        ℧η = ℧ .& (℧left .== ℧right)

    #warning this generally will not work
    elseif superoperator == "---"
        ℧η[℧] = (℧left .- ℧right)[℧]

    #warning this generally will not work
    elseif superoperator == "+++"
        ℧η = ℧left .+ ℧right

    elseif superoperator == "|||"
        ℧η = ℧ .& (℧left .| ℧right)

    elseif superoperator ∈ ["|=>","==>"]
        ℧η[℧left] .= ℧[℧left]  .& ℧right[℧left]

    elseif superoperator ∈ ["<=|","<=="]
        ℧η[℧right] = ℧[℧right] .& ℧left[℧right]

    end

    logicsetcopy[:] = ℧η
    logicsetcopy
end

function operatoreval(command, logicset::LogicalCombo)
    logicsetcopy = deepcopy(logicset)

    #println("operatoreval($command)")
    (sum(logicset[:]) == 0) && return logicset
    occursin(r"\{\{.*\}\}", command) && return operatorspawn(command, logicset)

    n = 1:sum(logicset[:])

    # convert a = b|c to a |= b,c
    if occursin("|", command) & occursin(r"(\b| )[!|]*=+[!|]*(\b| )", command)
      command = replace(command, "|"=>",")
      command = replace(command, r",*=+"=>"|=")
    end

    command = replace(command, r"^(.*?)[ ]*([!&])[ ]*$"=>s"\1 \2 \1")
    command = replace(command, r"^[ ]*([!&])[ ]*(.*?)$"=>s"\2 \1 \2")

    m = match(r"^(.*?)(([><=|!^&]{1,3}))(.*?)(\{([0-9]+),?([0-9]+)*\})?$",command)
    left, right, operator, nmin, nmax  = m.captures[[1,4,3,6,7]]

    (nmin === nothing)  && (nmax === nothing)  && (nrange = 1:999)
    !(nmin === nothing) && (nmax === nothing)  && (nrange = integer(nmin):integer(nmin))
    !(nmin === nothing) && !(nmax === nothing) && (nrange = integer(nmin):integer(nmax))

    leftarg  = strip.(split(left,  r"[,&|!]"))
    rightarg = strip.(split(right, r"[,&|!]"))

    leftvals  = hcat([grab(L, logicset, command=command) for L in leftarg]...)
    rightvals = hcat([grab(R, logicset, command=command) for R in rightarg]...)

    if operator == ""
        throw("No operator found!")

    elseif operator == "|"
        lcheck = [any(isodd.(leftvals[i,:])) for i in n]
        rcheck = [any(isodd.(rightvals[i,:])) for i in n]
        ℧Δ = [all(lcheck[i,:]) | all(rcheck[i,:]) for i in n]

    elseif operator == "&"
        lcheck = [all(isodd.(leftvals[i,:])) for i in n]
        rcheck = [all(isodd.(rightvals[i,:])) for i in n]
        ℧Δ = [all(lcheck[i,:]) & all(rcheck[i,:]) for i in n]

    elseif operator == "^"
        ℧Δ = (isodd.(leftvals[:,1]) .& iseven.(rightvals[:,1])) .|
             (iseven.(leftvals[:,1]) .& isodd.(rightvals[:,1]))

    elseif operator == "!"
        lcheck = [all(iseven.(leftvals[i,:])) for i in n]
        rcheck = [all(iseven.(rightvals[i,:])) for i in n]
        ℧Δ = [all(lcheck[i,:]) & all(rcheck[i,:]) for i in n]

    elseif operator == "^="
         lcheck = [sum(leftvals[i,j]  .== rightvals[i,:]) for i in n, j in 1:size(leftvals)[2]]
         rcheck = [sum(rightvals[i,j] .== leftvals[i,:])  for i in n, j in 1:size(rightvals)[2]]
         ℧Δ = [sum(lcheck[i,:]) + sum(rcheck[i,:]) == 2 for i in n]

    elseif operator  ∈ ["==","="]
        lcheck = [all(leftvals[i,j] .== rightvals[i,:]) for i in n, j in 1:size(leftvals)[2]]
        ℧Δ = [all(lcheck[i,:]) for i in n]

    elseif operator == "!="
        lcheck = [all(leftvals[i,j] .!= rightvals[i,:]) for i in n, j in 1:size(leftvals)[2]]
        ℧Δ = [all(lcheck[i,:]) for i in n]

    elseif operator ∈ ["|=", "=|"]
        lcheck = [any(leftvals[i,j] .== rightvals[i,:]) for i in n, j in 1:size(leftvals)[2]]
        ℧Δ = [sum(lcheck[i,:]) ∈ nrange for i in n]

    elseif operator ∈ ["|!=", "|!", "!|", "!|=", "=|!", "|=!"]
        lcheck = [any(leftvals[i,j] .!= rightvals[i,:]) for i in n, j in 1:size(leftvals)[2]]
        ℧Δ = [sum(lcheck[i,:]) ∈ nrange for i in n]

    elseif operator == "<="
        lcheck = [all(leftvals[i,j] .<= rightvals[i,:]) for i in n, j in 1:size(leftvals)[2]]
        ℧Δ = [all(lcheck[i,:]) for i in n]

    elseif operator == "<"
        lcheck = [all(leftvals[i,j] .< rightvals[i,:]) for i in n, j in 1:size(leftvals)[2]]
        ℧Δ = [all(lcheck[i,:]) for i in n]

    elseif operator == "<<"
        lcheck = [all(leftvals[i,j] .< rightvals[i,:].-1) for i in n, j in 1:size(leftvals)[2]]
        ℧Δ = [all(lcheck[i,:]) for i in n]

    elseif operator == ">="
        lcheck = [all(leftvals[i,j] .>= rightvals[i,:]) for i in n, j in 1:size(leftvals)[2]]
        ℧Δ = [all(lcheck[i,:]) for i in n]

    elseif operator == ">"
        lcheck = [all(leftvals[i,j] .> rightvals[i,:]) for i in n, j in 1:size(leftvals)[2]]
        ℧Δ = [all(lcheck[i,:]) for i in n]

    elseif operator == ">>"
        lcheck = [all(leftvals[i,j] .> rightvals[i,:].+1) for i in n, j in 1:size(leftvals)[2]]
        ℧Δ = [all(lcheck[i,:]) for i in n]
    end

    logicsetcopy.logical[logicsetcopy[:]] = ℧Δ

    logicsetcopy
end



function checkfeasible(command::String,
    logicset::LogicalCombo = LogicalCombo();
    verbose=true, force=false, any=false)

  any && force && throw("Both any and force can't be set to true")

  rowsin = sum(logicset.logical)

  if rowsin == 0
      println("No outcomes feasible outcomes with set!")
      return missing
  end

  print("Check: $command ... ")

  logicsetout = logicalparse(command, logicset=logicset) #, verbose=false)

  rowsout = sum(logicsetout.logical)
  outcomeratio = rowsout/rowsin

  if verbose
        outcomeratio != 1 && print("false,")
        outcomeratio == 1 && print("true,")
  elseif any
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

function search(command::String,
    logicset::LogicalCombo = LogicalCombo();
    verbose=true)

    rowsin = sum(logicset.logical)

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
