#using Pkg
#cd("c:/Users/francis.smart.ctr/GitDir/AbstractLogicJL")
#Pkg.activate(".")

# Global set variables Ω, Υ hold
integer(x::AbstractString) = parse(Int, strip(x))
Base.range(x::AbstractString) = range(integer(match(r"^[0-9]+", x).match),
                               stop = integer(match(r"[0-9]+$", x).match))
ABoccursin(y::Symbol) = any( [ y ∈ keys(Ω[i]) for i in 1:length(Ω) ] )
ABoccursin(x::Hotcomb, y::Symbol) = y ∈ keys(x)

Base.range(Ω::Hotcomb, ℧) = [Symbol(keys(Ω)[i])=> sort(unique(Ω[℧][:,i])) for i in 1:size(Ω)[2]]


#command = "a,b,c,d ∈ 1:5"
#Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]"]); Ω[℧]

function ABparse(commands::Array{String,1}; Ω::Hotcomb = Hotcomb(0), ℧::AbstractArray{Bool,1} = Bool[0])
  println("")

  for command in commands
      print(command)
      Ω, ℧ = ABparse(command,Ω,℧)

      feasibleoutcomes = (length(℧)>0) ? sum(℧) : 0
      filler = repeat("\t", max(1, 3-Integer(round(length(command)/18))))

      (feasibleoutcomes == 0)  && (check = "X")
      (feasibleoutcomes  > 1)  && (check = "✓")
      (feasibleoutcomes == 1)  && (check = "✓✓")

      println(" $filler feasible outcomes $feasibleoutcomes $check")

  end
  (Ω, ℧)
end

function ABparse(command::String,  Ω::Hotcomb, ℧::AbstractArray{Bool,1})
  # A vector of non-standard operators to ignore
  exclusionlist = ["\bin\b"]

  if occursin(r"∈|\bin\b", command)
      (Ω,℧) = ABassign(command)
      return (Ω,℧)
  end

  # Check for the existance of any symbols in Ω
  varcheck = eachmatch(r"[a-zA-Z][0-9a-zA-Z_.]*", command)

  # Checks if any of the variables does not exist in Ω
  for S in [Symbol(s.match) for s in varcheck if !(s.match ∈ exclusionlist)]
      if (occursin("{{", string(S))) && (!ABoccursin(Ω, S))
          throw("In {$command} variable {:$S} not found in Ω")
      end
  end

  if occursin(r"( |\b)([><=|!+\\-\^\\&]{1,4})(\b| )", command)
      return SuperSuperOperatorEval(command,Ω,℧)
  end
  println("Warning! { $command } not interpretted")
end

function ABassign(command::String)
  vars, valsin = strip.(split(command, r"∈|\bin\b"))
  varsVect = split(vars, ",") .|> strip
  vals0 = split(replace(valsin, r"\[|\]" => ""), ",")

  (length(vals0) > 1) && (vals =  [(occursin(r"^[0-9]+$", i) && integer(i)) for i in vals0])
  (length(vals0) == 1 && occursin(r"^[0-9]+:[0-9]+$", vals0[1])) && (vals = range(vals0[1]))

  outset = (; zip([Symbol(i) for i in varsVect], fill(vals, length(vars)))...)

  Ω  = Hotcomb(outset)
  ℧ = fill(true, size(Ω)[1])

  (Ω ,℧)
end

function grab(argument::AbstractString, Ω::Hotcomb, ℧::AbstractArray{Bool,1}; command = "")
  matcher = r"^([a-zA-z][a-zA-z0-9]*)*([0-9]+)*([+\-*/])*([a-zA-z][a-zA-z0-9]*)*([0-9]+)*$"

  m = match(matcher, argument)
  nvar = 5-sum([i === nothing for i in m.captures])
  (nvar==0) && throw("Argument $argument could not be parsed in $command")

  v1, n1, o1, v2, n2 = m.captures

  !(v1 === nothing) && (left  = Ω[℧, Symbol(v1)])
  !(n1 === nothing) && (left  = fill(integer(n1), length(℧)))

  (nvar==1) && return left

  !(v2 === nothing) && (right = Ω[℧, Symbol(v2)])
  !(n2 === nothing) && (right = fill(integer(n2), length(left)))

  (o1 == "+") && return left .+ right
  (o1 == "-") && return left .- right
  (o1 == "/") && return left ./ right
  (o1 == "*") && return left .* right
end

function OperatorSpawn(command, Ω::Hotcomb, ℧::AbstractArray{Bool,1})
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

    mykeys = keys(Ω)
    domain = 1:length(mykeys)

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
    for i in domain, j in domain
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
           ("i" ∈ iSet) && push!(collection, fill(false, length(℧)))
           continue
       end

       ℧∇ = SuperOperatorEval(txtcmd, Ω, ℧)[2]

       println(">>> $txtcmd")

       push!(collection, ℧∇)
    end

    collector = hcat(collection...)

    if (countrange === missing)
      ℧Δ = ℧ .& [all(collector[i,:]) for i in 1:size(collector)[1]]
    else
      ℧Δ = ℧ .& [sum(collector[i,:]) ∈ countrange for i in 1:size(collector)[1]]
    end
    (Ω, ℧Δ)
end

function subout(txtcmd, i, arg, mykeys)
  lookup(vect, i) = i ∈ 1:length(vect) ? vect[i] : "~~OUTOFBOUNDS~~"

  (arg[end] ∈ ['i', 'j'])  && return replace(txtcmd, "{{$arg}}"=>lookup(mykeys,i))

  mod = integer(match(r"([0-9]+$)", arg).match)

  occursin("+", arg) && return replace(txtcmd, "{{$arg}}"=>lookup(mykeys,i+mod))
  occursin("-", arg) && return replace(txtcmd, "{{$arg}}"=>lookup(mykeys,i-mod))

  txtcmd
end

function SuperSuperOperatorEval(command, Ω::Hotcomb, ℧::AbstractArray{Bool,1})
    #println("OperatorEval($command)")
    (sum(℧) == 0) && return (Ω, ℧)
    (!occursin(r"([><=|!+\\-\^&]{4})", command)) && return SuperOperatorEval(command, Ω, ℧)

    m = match(r"(^.*?)([><=|!+\\-\^&]{4})(.*?$)", replace(command, " "=>""))
    left, supersuperoperator, right = m.captures

    υ = copy(℧); ℧η = copy(℧)

    ℧left  = SuperSuperOperatorEval(left ,Ω,℧)[2]
    ℧right = SuperSuperOperatorEval(right,Ω,℧)[2]

    (supersuperoperator == "====") && (℧η = υ .& (℧left .& ℧right))
    (supersuperoperator == "||||") && (℧η = υ .& (℧left .| ℧right))
    (supersuperoperator == "^^^^") && (℧η = υ .& ((℧left .& .!℧right) .| (.!℧left .& ℧right)))

    (Ω, ℧η)
end

function SuperOperatorEval(command, Ω::Hotcomb, ℧::AbstractArray{Bool,1})
    #println("OperatorEval($command)")
    (sum(℧) == 0) && return (Ω, ℧)
    (!occursin(r"([><=|!+\\-\^&]{3})", command)) && return OperatorEval(command, Ω, ℧)
    occursin(r"\{\{.*\}\}", command) && return OperatorSpawn(command, Ω, ℧)

    m = match(r"(^.*?)([><=|!+\\-\\^&]{3})(.*?$)",replace(command, " "=>""))
    left, superoperator, right = m.captures

    υ = copy(℧); ℧η = copy(℧)

    ℧left  = SuperOperatorEval(left ,Ω,℧)[2]
    ℧right = SuperOperatorEval(right,Ω,℧)[2]

    if superoperator == "&&&"
        ℧η = υ .& (℧left .& ℧right)

    elseif superoperator == "^^^"
        ℧η = υ .& ((℧left .& .!℧right) .| (.!℧left .& ℧right))

    # this can be dangerous, false equal to false such as with previous exclusions will cause inconsistencies
    elseif superoperator == "==="
        ℧η = υ .& (℧left .== ℧right)

    #warning this generally will not work
    elseif superoperator == "---"
        ℧η[υ] = (℧left .- ℧right)[υ]

    #warning this generally will not work
    elseif superoperator == "+++"
        ℧η = ℧left .+ ℧right

    elseif superoperator == "|||"
        ℧η = υ .& (℧left .| ℧right)

    elseif superoperator ∈ ["|=>","==>"]
        ℧η[℧left] .= ℧[℧left]  .& ℧right[℧left]

    elseif superoperator ∈ ["<=|","<=="]
        ℧η[℧right] = ℧[℧right] .& ℧left[℧right]

    elseif superoperator ∈ ["<=>","<=>"] # ???????????????????????????????????
        ℧η[℧right]     .=  ℧[℧right]   .&   ℧left[℧right]
        ℧η[.!℧right]   .=  ℧[.!℧right] .& .!℧left[.!℧right]
    end
    (Ω, ℧η)
end

function OperatorEval(command, Ω::Hotcomb, ℧::AbstractArray{Bool,1})
    #println("OperatorEval($command)")

    (sum(℧) == 0) && return (Ω, ℧)
    occursin(r"\{\{.*\}\}", command) && return OperatorSpawn(command, Ω, ℧)

    n = 1:sum(℧); ℧Δ = copy(℧); ℧η = copy(℧)

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

    leftvals  = hcat([grab(L, Ω, ℧, command=command) for L in leftarg]...)
    rightvals = hcat([grab(R, Ω, ℧, command=command) for R in rightarg]...)

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

    ℧η[℧η] = ℧Δ

    (Ω, ℧η)
end

Ω,℧ = ABparse(["a, b, c, d, e, f  ∈ 1:6", "{{i}} != {{!i}}"]); Ω[℧]

#Ω,℧ = ABparse(["a, b, c, d, e, f  ∈ 6"]); Ω[℧]

Ω,℧ = ABparse(["a, b, c ∈ 1:6", "{{i}} != {{!i}}"]); Ω[℧]


Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "b != a,c", "c =| 1,2"]); Ω[℧]

Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "{{i}} != {{!i}}"]); Ω[℧]

Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "a|b = 1"]); Ω[℧]
Ω,℧ = ABparse(["a, b, c ∈ 1:3", "a | b"]); Ω[℧]

Ω,℧ = ABparse(["a, b, c ∈ 1:3", "a|b|c"]); Ω[℧]
Ω,℧ = ABparse(["a, b, c ∈ 1:3", "a | b | c"]); Ω[℧]

Ω,℧ = ABparse(["a, b, c ∈ 1:3", "a,b,c = 1"]); Ω[℧]
Ω,℧ = ABparse(["a, b, c ∈ 1:3", "a & b & c"]); Ω[℧]

Ω,℧ = ABparse(["a, b, c ∈ 0:2", "a,b,c = 0"]); Ω[℧]
Ω,℧ = ABparse(["a, b, c ∈ 0:2", "a ! b ! c"]); Ω[℧]


Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]"]); Ω[℧]

# At least 2 less/more >> or <<
Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "a << b"]); Ω[℧]
Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "a >> b"]); Ω[℧]

Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "a,b ^= 1"]); Ω[℧]
Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "a=1 ^^^ b=1"]); Ω[℧]
Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "a=1 ^^^^ b=1"]); Ω[℧]


# All equal commands
Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "a,b |=   1"]); Ω[℧]
Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "a=1 |||  b = 1"]); Ω[℧]
Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "a=1 |||| b = 1"]); Ω[℧]

# Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "a,b ^=   1"]); Ω[℧]

Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "a|b = 1 ||| c == 1"]); Ω[℧]

Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3,4]"]); Ω[℧]
Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3,4]", "{{i}} == {{!i}}"]); Ω[℧]
Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3,4]", "{{i}} != {{!i}}"]); Ω[℧]
Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3,4]", "{{i}} > {{>i}}"]); Ω[℧]
Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3,4]", "{{i}} > {{i+1}} {{2,3}}"]); Ω[℧]

Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "{{i}} == 1 {{2}}"]); Ω[℧]

Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3,4]", "{{j}} > {{j+1}}"]); Ω[℧]
Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3,4]", "{{i}} > {{i+1}} {{0}}"]); Ω[℧]
Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3,4]", "{{j}} <= {{j+1}}"]); Ω[℧]

Ω,℧ = ABparse(["a, b, c, d  ∈  [1,2,3,4]", "{{i}} != {{!i}}"]); Ω[℧]
Ω,℧ = ABparse(["a, b, c, d  ∈  [1,2,3,4]", "{{i}} != {{!i}} {{0}}"]); Ω[℧]

Ω,℧ = ABparse(["a, b, c, d  ∈  [1,2,3,4]", "{{i}} = 2 {{2,3}}"]); Ω[℧] # ??????????????????????
Ω,℧ = ABparse(["a, b, c, d  ∈  [1,2,3,4]", "{{i}} != {{!i}} {{1,5}}"]); Ω[℧]

Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3,4]", "{{j}} > {{j+1}}"]); Ω[℧]

Ω,℧ = ABparse(["a, b  ∈  [1,2,3]", "a|b = 1 {1}"]); Ω[℧,:]
Ω,℧ = ABparse(["a, b  ∈  [1,2,3]", "a|b = 1 {0}"]); Ω[℧,:]

Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "b != a,c", "c =| 1,2 {1}"]); Ω[℧,:]

Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "b != a,c", "c == 1|2"]); Ω[℧,:]
Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "a < b,c",  "c |= 1,2"]);Ω[℧,:]
Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "b < 3 |=> a = b"]); Ω[℧,:]
Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "a == b <=| b << 3"]); Ω[℧,:]
Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "a == 1 <=> b == c"]); Ω[℧,:]
Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "a <= b,c", "c |= 1,2"]); Ω[℧,:]

Ω,℧ = ABparse(["a, b, c     ∈  [1,2,3]", "b , a == c-1", "c |= 1,2"]); Ω[℧,:]
Ω,℧ = ABparse(["a, b, c     ∈  [1,2,3]", "a == c+b"]); Ω[℧,:]
Ω,℧ = ABparse(["a, b, c, d  ∈  [1,2,3,4]", "a , b |= c, d"]); Ω[℧,:]
Ω,℧ = ABparse(["a, b, c, d  ∈  [1,2,3,4]", "a != b, c, d", "b != c,d", "c != d"]); Ω[℧,:]
Ω,℧ = ABparse(["a, b, c, d  ∈  [1,2,3,4]", "a != b, c, d", "b != c,d", "c != d", "a == c+1", "d == a*2"]); Ω[℧,:]

Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "b != a,c", "c =| 1,2"]); Ω[℧,:]

Ω,℧ = ABparse(["a, b, c, d, e, f, g  ∈  [1,2,3,4]", "a,b,c,d,e,f,g == 1 +++ a,b,c,d,e,f,g == 1 ==== 2"]); Ω[℧,:]

Ω,℧ = ABparse(["a, b, c     ∈  [1,2,3]", "b , a == c-1"]); Ω[℧,:]
