#using Pkg
#cd("c:/Users/francis.smart.ctr/GitDir/AbstractLogicJL")
#Pkg.activate(".")

# Global set variables logicset, Υ hold
integer(x::AbstractString) = parse(Int, strip(x))
Base.range(x::AbstractString) = range(integer(match(r"^[0-9]+", x).match),
                               stop = integer(match(r"[0-9]+$", x).match))
logicaloccursin(y::Symbol) = any( [ y ∈ keys(logicset[i]) for i in 1:length(logicset) ] )
logicaloccursin(x::LogicalCombo, y::Symbol) = y ∈ keys(x)

integer("1")
range("1:5")

#command = "a,b,c,d ∈ 1:5"
#logicset = logicalparse(["a, b, c  ∈  [1,2,3]"]); logicset[℧]

function logicalparse(commands::Array{String,1}; logicset::LogicalCombo = LogicalCombo())
  println("")

  any(occursin.(";", commands)) &&
    (commands = split.(commands, ";") |> Iterators.flatten |> collect .|> strip .|> string)


  for command in commands
      print(command)
      logicset = logicalparse(command,logicset=logicset)

      feasibleoutcomes = sum(logicset[:])
      filler = repeat("\t", max(1, 3-Integer(round(length(command)/18))))

      (feasibleoutcomes == 0)  && (check = "X")
      (feasibleoutcomes  > 1)  && (check = "✓")
      (feasibleoutcomes == 1)  && (check = "✓✓")

      println(" $filler feasible outcomes $feasibleoutcomes $check")

  end
  logicset
end

function logicalparse(command::String; logicset::LogicalCombo = LogicalCombo())
  # A vector of non-standard operators to ignore
  exclusionlist = ["in","xor","XOR", "iff", "IFF"]

  occursin(";", command) &&
    return logicalparse(string.(strip.(split(command, ";"))), logicset=logicset)

  if occursin(r"∈|\bin\b", command)
      logicset = definelogicalset(logicset, command)
      return logicset
  end

  # Check for the existance of any symbols in logicset
  varcheck = eachmatch(r"[a-zA-Z][0-9a-zA-Z_.]*", command)

  # Checks if any of the variables does not exist in logicset
  for S in [Symbol(s.match) for s in varcheck if !(s.match ∈ exclusionlist)]
      if (occursin("{{", string(S))) && (!logicaloccursin(logicset, S))
          throw("In {$command} variable {:$S} not found in logicset")
      end
  end

  occursin(r"( |\b)([><=|!+\\-\^\\&]{1,4}|XOR|xor)(\b| )", command) && return metaoperatoreval(command,logicset)

  println("Warning! { $command } not interpreted!")
end

logicalparse(commands::Array{String,1}, logicset::LogicalCombo) =
  logicalparse(commands=commands, logicset=logicset)

logicalparse(commands::String, logicset::LogicalCombo) =
  logicalparse(commands=commands, logicset=logicset)


function definelogicalset(logicset::LogicalCombo, command::String)
  left, right = strip.(split(command, r"∈|\bin\b"))
  vars = split(left, ",") .|> strip
  values = split(replace(right, r"\[|\]" => ""), ",")

  (length(values) > 1) &&
    (values =  [(occursin(r"^[0-9]+$", i) && integer(i)) for i in values])
  (length(values) == 1 && occursin(r"^[0-9]+:[0-9]+$", values[1])) &&
    (values = range(values[1]))

  outset = (; zip([Symbol(i) for i in vars], fill(values, length(vars)))...)
  outset = [Pair(Symbol(i), values) for i in vars]

  #logicset  = LogicalCombo(outset)
  logicset  = expand(logicset, outset)

  #logicset[:] = fill(true, size(logicset)[1])

  logicset
end


function grab(argument::AbstractString, logicset::LogicalCombo; command = "")
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


function OperatorSpawn(command, logicset::LogicalCombo)
    logicsetcopy = deepcopy(logicset)

    tempcommand = command
    m = eachmatch(r"(\{\{.*?\}\})", tempcommand)
    matches = [replace(x[1], r"\{|\}"=>"") for x in collect(m)] |> unique

    if occursin(r"^[0-9]+,[0-9]+$", matches[end])
        countrange = (x -> x[1]:x[2])(integer.(split(matches[end], ",")))
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

    println()
    for i in mydomain, j in mydomain
      ((length(wild2)  == 0) || wild2[1][1] ∈ 'i':'j') && (j>1)  && continue
      ("!"   ∈ iSet1)       && (i==j) && continue
      (">"   ∈ iSet1)       && (i>=j) && continue
      ("<"   ∈ iSet1)       && (i<=j) && continue
      (">="  ∈ iSet2)       && (i<j)  && continue
      ("<="  ∈ iSet2)       && (i>j)  && continue
      #println("$i and $j")

       txtcmd = tempcommand

       (length(wild2)==1) && !(wild2[1][1] ∈ 'i':'j') &&  (txtcmd = subout(txtcmd, j, wild2[1], mykeys))
       (length(wild2)==1) &&  (wild2[1][1] ∈ 'i':'j') &&  (txtcmd = subout(txtcmd, i, wild2[1], mykeys))
       (length(wild)  == 1) && (txtcmd = subout(txtcmd, i, wild[1], mykeys))

       if occursin("~~OUTOFBOUNDS~~", txtcmd)
           ("i" ∈ iSet) && push!(collection, fill(false, length(logicset[:])))
           continue
       end

       ℧∇ = SuperOperatorEval(txtcmd, logicset)[:]

       println(">>> $txtcmd")

       push!(collection, ℧∇)
    end

    collector = hcat(collection...)

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

    #println("OperatorEval($command)")
    (sum(logicset[:]) == 0) && return logicset
    (!occursin(Regex("([><=|!+\\-^&]{4}|$metaset)"), command)) && return SuperOperatorEval(command, logicset)

    m = match(Regex("(^.*?)[ ]*([><=|!+\\-^&]{4}|$metaset)[ ]*(.*?\$)"), command)
    left, metaoperator, right = m.captures

    ℧left  = metaoperatoreval(left , logicset)[:]
    ℧right = metaoperatoreval(right, logicset)[:]

    (metaoperator == "&&&&") && (℧η = logicset[:] .& (℧left .& ℧right))
    (metaoperator == "====") && (℧η = logicset[:] .& (℧left .== ℧right))
    (metaoperator ∈ ["||||", "IFF"]) && (℧η = logicset[:] .& (℧left .| ℧right))
    (metaoperator ∈ ["^^^^", "XOR"]) && (℧η = logicset[:] .& ((℧left .& .!℧right) .| (.!℧left .& ℧right)))

    logicsetcopy[:] = ℧η
    logicsetcopy
end

function SuperOperatorEval(command, logicset::LogicalCombo)
    logicsetcopy = deepcopy(logicset)

    superset = "xor|iff"

    #println("OperatorEval($command)")
    (sum(logicset[:]) == 0) && return logicset
    (!occursin(Regex("([><=|!+\\-^&]{3}|$superset)"), command)) && return OperatorEval(command, logicset)
    occursin(r"\{\{.*\}\}", command) && return OperatorSpawn(command, logicset)

    m = match(Regex("(^.*?)[ ]*([><=|!+\\-\\^&]{3}|$superset)[ ]*(.*?\$)"), command)
    left, superoperator, right = m.captures

    ℧left  = SuperOperatorEval(left ,logicset)[:]
    ℧right = SuperOperatorEval(right,logicset)[:]

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

    # elseif superoperator ∈ ["<=>","<=>"] # ???????????????????????????????????
    #     ℧η[℧right]     .=  ℧[℧right]   .&   ℧left[℧right]
    #     ℧η[.!℧right]   .=  ℧[.!℧right] .& .!℧left[.!℧right]
    end

    logicsetcopy[:] = ℧η
    logicsetcopy
end

function OperatorEval(command, logicset::LogicalCombo)
    logicsetcopy = deepcopy(logicset)

    #println("OperatorEval($command)")
    (sum(logicset[:]) == 0) && return logicset
    occursin(r"\{\{.*\}\}", command) && return OperatorSpawn(command, logicset)

    n = 1:sum(logicset[:])

    # convert a = b|c to a |= b,c
    if occursin("|", command) & occursin(r"(\b| )[|]*=+[|]*(\b| )", command)
      command = replace(command, "|"=>",")
      command = replace(command, r",*=+,*"=>"|=")
    end

    m = match(r"^(.*?)(([><=|!^&]{1,2})\b)(.*?)(\{([0-9]+),?([0-9]+)*\})?$",replace(command, " "=>""))
    left, right, operator, nmin, nmax  = m.captures[[1,4,3,6,7]]

    (nmin === nothing)  && (nmax === nothing)  && (nrange = 1:999)
    !(nmin === nothing) && (nmax === nothing)  && (nrange = integer(nmin):integer(nmin))
    !(nmin === nothing) && !(nmax === nothing) && (nrange = integer(nmin):integer(nmax))

    leftarg  = strip.(split(left,  r"[,&|!]"))
    rightarg = strip.(split(right, r"[,&|!]"))

    leftvals  = hcat([grab(L, logicset, command=command) for L in leftarg]...)
    rightvals = hcat([grab(R, logicset, command=command) for R in rightarg]...)

    if operator == "!="
        lcheck = [any(leftvals[i,j] .== rightvals[i,:]) for i in n, j in 1:size(leftvals)[2]]
        ℧Δ = [!all(lcheck[i,:]) for i in n]

    elseif operator == "|"
        lcheck = [any(leftvals[i,:]  .== 1) for i in n]
        rcheck = [any(rightvals[i,:] .== 1) for i in n]
        ℧Δ = [all(lcheck[i,:]) | all(rcheck[i,:]) for i in n]

    elseif operator == "&"
        lcheck = [all(leftvals[i,:]  .== 1) for i in n]
        rcheck = [all(rightvals[i,:] .== 1) for i in n]
        ℧Δ = [all(lcheck[i,:]) & all(rcheck[i,:]) for i in n]

    elseif operator == "^"
        ℧Δ = (isodd.(leftvals[:,1]) .& iseven.(rightvals[:,1])) .|
             (iseven.(leftvals[:,1]) .& isodd.(rightvals[:,1]))

    elseif operator == "!"
        lcheck = [all(leftvals[i,:]  .== 0) for i in n]
        rcheck = [all(rightvals[i,:] .== 0) for i in n]
        ℧Δ = [all(lcheck[i,:]) & all(rcheck[i,:]) for i in n]

    elseif operator == "^="
         lcheck = [sum(leftvals[i,j]  .== rightvals[i,:]) for i in n, j in 1:size(leftvals)[2]]
         rcheck = [sum(rightvals[i,j] .== leftvals[i,:])  for i in n, j in 1:size(rightvals)[2]]
         ℧Δ = [sum(lcheck[i,:]) + sum(rcheck[i,:]) == 2 for i in n]

    elseif operator  ∈ ["==","="]
        lcheck = [all(leftvals[i,j] .== rightvals[i,:]) for i in n, j in 1:size(leftvals)[2]]
        ℧Δ = [all(lcheck[i,:]) for i in n]

    elseif operator ∈ ["|=", "=|"]
        lcheck = [any(leftvals[i,j] .== rightvals[i,:]) for i in n, j in 1:size(leftvals)[2]]
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

logicset = logicalparse("a, b, c ∈ 1:3")
logicset |> showfeasible

logicalparse("a ∈ 1:3; b ∈ 1:2; c ∈ 2:3") |> showfeasible

logicalparse("a, b, c ∈ 1:3; a == b; a != c")[:,:,:]

logicalparse("a, b, c ∈ 1:3; a == b XOR a == c") |> showfeasible
logicalparse("a, b, c ∈ 1:3; a == b ^^^^ a == c")|> showfeasible
logicalparse("a, b, c ∈ 1:3; a == b xor a == c")|> showfeasible
logicalparse("a, b, c ∈ 1:3; a == b ^^^ a == c")|> showfeasible
logicalparse("a, b, c ∈ 1:3; a ^= b , c ")|> showfeasible

logicalparse("a, b, c ∈ 1:3; a, b ^= 1")|> showfeasible

logicalparse("a, b ∈ 0:1; a ^ b") |> showfeasible

logicalparse("a, b, c ∈ 1:3; a == b === a != c")|> showfeasible
logicalparse("a, b, c ∈ 1:3; a == b <=> a != c")|> showfeasible

function sum_add(x, y)
  s = 0
  for i in (x)[y]
      s += 1
  end
  return s
end

function sum_add2(x, y)
  s = 0
  for i in x
      y[i] && (s += 1)
  end
  return s
end

n = 1000^2
@time sum_add(1:n,  [true, fill(false, n-1)...])
@time sum_add2(1:n, [true, fill(false, n-1)...])

@time sum_add(1:n,  sparse([true, fill(false, n-1)...]))
@time sum_add2(1:n, sparse([true, fill(false, n-1)...]))


logicalparse(["a, b, c, d, e ∈ 1:5", "{{i}} != {{!i}}"])|> showfeasible
logicalparse(["a, b, c, d, e ∈ 1:5", "{{i}} != {{>i}}"])|> showfeasible

#logicset = logicalparse(["a, b, c, d, e, f  ∈ 6"]); logicset[℧]

logicalparse(["a, b, c ∈ 1:6", "{{i}} == {{!i}}"])|> showfeasible
logicalparse(["a, b, c ∈ 1:6", "{{i}} != {{>i}}"])|> showfeasible

logicalparse(["a, b, c ∈ 1:6", "{{i}} > {{!i}}"])|> showfeasible

logicalparse(["a, b, c  ∈  [1,2,3]", "b != a,c", "c =| 1,2"])|> showfeasible

logicalparse(["a, b, c  ∈  [1,2,3]", "{{i}} != {{!i}}"])|> showfeasible

logicalparse(["a, b, c  ∈  [1,2,3]", "a|b = 1"])|> showfeasible
logicalparse(["a, b, c ∈ 1:3", "a | b"])|> showfeasible

logicalparse(["a, b, c ∈ 1:3", "a|b|c"])|> showfeasible
logicalparse(["a, b, c ∈ 1:3", "a | b | c"])|> showfeasible

logicalparse(["a, b, c ∈ 1:3", "a,b,c = 1"])|> showfeasible
logicalparse(["a, b, c ∈ 1:3", "a & b & c"])|> showfeasible

logicalparse(["a, b, c ∈ 0:2", "a,b,c = 0"])|> showfeasible
logicalparse(["a, b, c ∈ 0:2", "a ! b ! c"])|> showfeasible


logicalparse(["a, b, c  ∈  [1,2,3]"])|> showfeasible

# At least 2 less/more >> or <<
logicalparse(["a, b, c  ∈  [1,2,3]", "a << b"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3]", "a >> b"])|> showfeasible

logicalparse(["a, b, c  ∈  [1,2,3]", "a,b ^= 1"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3]", "a=1 ^^^ b=1"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3]", "a=1 ^^^^ b=1"])|> showfeasible


# All equal commands
logicalparse(["a, b, c  ∈  [1,2,3]", "a,b |=   1"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3]", "a=1 |||  b = 1"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3]", "a=1 |||| b = 1"])|> showfeasible

# logicalparse(["a, b, c  ∈  [1,2,3]", "a,b ^=   1"])|> showfeasible

logicalparse(["a, b, c  ∈  [1,2,3]", "a|b = 1 ||| c == 1"])|> showfeasible

logicalparse(["a, b, c  ∈  [1,2,3,4]"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3,4]", "{{i}} == {{!i}}"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3,4]", "{{i}} != {{!i}}"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3,4]", "{{i}} > {{>i}}"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3,4]", "{{i}} > {{i+1}} {{2,3}}"])|> showfeasible

logicalparse(["a, b, c  ∈  [1,2,3]", "{{i}} == 1 {{2}}"])|> showfeasible

logicalparse(["a, b, c  ∈  [1,2,3,4]", "{{j}} > {{j+1}}"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3,4]", "{{i}} > {{i+1}} {{0}}"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3,4]", "{{j}} <= {{j+1}}"])|> showfeasible

logicalparse(["a, b, c, d  ∈  [1,2,3,4]", "{{i}} != {{!i}}"])|> showfeasible
logicalparse(["a, b, c, d  ∈  [1,2,3,4]", "{{i}} != {{!i}} {{0}}"])|> showfeasible

logicalparse(["a, b, c, d  ∈  [1,2,3,4]", "{{i}} = 2 {{2,3}}"])|> showfeasible # ??????????????????????
logicalparse(["a, b, c, d  ∈  [1,2,3,4]", "{{i}} != {{!i}} {{1,5}}"])|> showfeasible

logicalparse(["a, b, c  ∈  [1,2,3,4]", "{{j}} > {{j+1}}"])|> showfeasible

logicalparse(["a, b  ∈  [1,2,3]", "a|b = 1 {1}"])|> showfeasible
logicalparse(["a, b  ∈  [1,2,3]", "a|b = 1 {0}"])|> showfeasible

logicalparse(["a, b, c  ∈  [1,2,3]", "b != a,c", "c =| 1,2 {1}"])|> showfeasible

logicalparse(["a, b, c  ∈  [1,2,3]", "b != a,c", "c == 1|2"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3]", "a < b,c",  "c |= 1,2"]);logicset[℧,:]
logicalparse(["a, b, c  ∈  [1,2,3]", "b < 3 |=> a = b"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3]", "a == b <=| b << 3"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3]", "a == 1 <=> b == c"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3]", "a <= b,c", "c |= 1,2"])|> showfeasible

logicalparse(["a, b, c     ∈  [1,2,3]", "b , a == c-1", "c |= 1,2"])|> showfeasible
logicalparse(["a, b, c     ∈  [1,2,3]", "a == c+b"])|> showfeasible
logicalparse(["a, b, c, d  ∈  [1,2,3,4]", "a , b |= c, d"])|> showfeasible
logicalparse(["a, b, c, d  ∈  [1,2,3,4]", "a != b, c, d", "b != c,d", "c != d"])|> showfeasible
logicalparse(["a, b, c, d  ∈  [1,2,3,4]", "a != b, c, d", "b != c,d", "c != d", "a == c+1", "d == a*2"])|> showfeasible

logicalparse(["a, b, c  ∈  [1,2,3]", "b != a,c", "c =| 1,2"])|> showfeasible

logicalparse(["a, b, c, d, e, f, g  ∈  [1,2,3,4]", "a,b,c,d,e,f,g == 1 +++ a,b,c,d,e,f,g == 1 ==== 2"])|> showfeasible

logicalparse(["a, b, c     ∈  [1,2,3]", "b , a == c-1"])|> showfeasible
