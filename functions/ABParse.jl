using Pkg
cd("c:/Users/francis.smart.ctr/GitDir/AbstractLogicJL")
Pkg.activate(".")


# Global set variables Ω, Υ hold
integer(x::AbstractString) = parse(Int, strip(x))
Base.range(x::AbstractString) = range(integer(match(r"^[0-9]+", x).match),
                               stop = integer(match(r"[0-9]+$", x).match))
ABoccursin(y::Symbol) = any( [ y ∈ keys(Ω[i]) for i in 1:length(Ω) ] )
ABoccursin(x::Hotcomb, y::Symbol) = y ∈ keys(x)

function ABparse(commands::Array{String,1})
  Ω = Hotcomb(0)
  ℧ = Bool[0]
  println("")

  for command in commands
      print(command)
      Ω, ℧ = ABparse(command, Ω, ℧)

      feasibleoutcomes = (length(℧)>0) ? sum(℧) : 0
      filler = repeat("\t", max(1, 3-Integer(round(length(command)/18))))
      println(" $filler feasible outcomes $feasibleoutcomes ✓")

  end
  (Ω, ℧)
end

commands = ["a, b, c, d  ∈  [1,2,3,4]", "a , b |= c, d"]
commands = ["a, b, c, d  ∈  [1,2,3,4]", "a != b, c, d"]
commands = ["a, b, c  ∈  [1,2,3]", "b != a,c", "c |= 1,2"]
command = commands[1]

function ABparse(command::String,  Ω::Hotcomb, ℧::Array{Bool,1})
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
      !ABoccursin(Ω, S) && throw("In {$command} variable {:$S} not found in Ω")
  end

  if occursin(r"( |\b)([><=|!]{3,4})(\b| )", command)
      (Ω,℧) = ABevaluate2way(command,Ω,℧)
      return (Ω,℧)
  elseif occursin(r"( |\b)([><=|!]{1,2})(\b| )", command)
      (Ω,℧) = ABevaluate(command,Ω,℧)
      return (Ω,℧)
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

function grab(argument::AbstractString, Ω::Hotcomb, ℧::Array{Bool,1}; command = "")
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

command = "a == b ||| a == c+1"



function ABevaluate2way(command, Ω::Hotcomb, ℧::Array{Bool,1})
    #println("ABevaluate($command)")
    (sum(℧) == 0) && return (Ω, ℧)

    m = match(r"(.*)(\b([><=|!]{3,4})\b)(.*)",replace(command, " "=>""))
    left, blank, superoperator, right = m.captures

    υ = copy(℧); ℧η = copy(℧)

    ℧left  = ABevaluate(left ,Ω,℧)[2]
    ℧right = ABevaluate(right,Ω,℧)[2]

    if superoperator == "==="
        ℧η = υ .& (℧left .& ℧right)

    elseif superoperator == "|||"
        ℧η = υ .& (℧left .| ℧right)

    elseif superoperator ∈ ["|=>","==>"]
        ℧η[℧left]  = ℧[℧left]  .& ℧right[℧left]

    elseif superoperator ∈ ["<=|","<=="]
        ℧η[℧right] = ℧[℧right] .& ℧left[℧right]

    elseif superoperator ∈ ["<=>","<==>"] # ???????????????????????????????????
        ℧η[℧right]     .=  ℧[℧right]   .&   ℧left[℧right]
        ℧η[.!℧right]   .=  ℧[.!℧right] .& .!℧left[.!℧right]
    end
    (Ω, ℧η)
end



command = "a == 1 <=> b == 1"

function ABevaluate(command, Ω::Hotcomb, ℧::Array{Bool,1})
    #println("ABevaluate($command)")

    (sum(℧) == 0) && return (Ω, ℧)

    n = 1:sum(℧); ℧Δ = copy(℧); ℧η = copy(℧)

    # convert a = b|c to a |= b,c
    if occursin("|", command) &  occursin(r"(\b| )[|]*=+[|]*(\b| )", command)
      command = replace(command, "|"=>",")
      command = replace(command, r",*=+,*"=>"|=")
    end

    m = match(r"(.*)(\b([><=|!]{1,2})\b)(.*)",replace(command, " "=>""))
    left, blank, operator, right = m.captures

    leftarg  = strip.(split(left,  r"[,&]"))
    rightarg = strip.(split(right, r"[,&]"))

    leftvals  = hcat([grab(L, Ω, ℧, command=command) for L in leftarg]...)
    rightvals = hcat([grab(R, Ω, ℧, command=command) for R in rightarg]...)

    if operator == "!="
        lcheck = [any(leftvals[i,j] .== rightvals[i,:]) for i in n, j in 1:size(leftvals)[2]]
        ℧Δ = [!all(lcheck[i,:]) for i in n]

    elseif operator  ∈ ["==","="]
        lcheck = [all(leftvals[i,j] .== rightvals[i,:]) for i in n, j in 1:size(leftvals)[2]]
        ℧Δ = [all(lcheck[i,:]) for i in n]

    elseif operator ∈ ["|=", "=|"]
        lcheck = [any(leftvals[i,j] .== rightvals[i,:]) for i in n, j in 1:size(leftvals)[2]]
        ℧Δ = [any(lcheck[i,:]) for i in n]

    elseif operator == "<="
        lcheck = [all(leftvals[i,j] .<= rightvals[i,:]) for i in n, j in 1:size(leftvals)[2]]
        ℧Δ = [all(lcheck[i,:]) for i in n]

    elseif operator ∈ ["<<","<"]
        lcheck = [all(leftvals[i,j] .< rightvals[i,:]) for i in n, j in 1:size(leftvals)[2]]
        ℧Δ = [all(lcheck[i,:]) for i in n]

    elseif operator == ">="
        lcheck = [all(leftvals[i,j] .>= rightvals[i,:]) for i in n, j in 1:size(leftvals)[2]]
        ℧Δ = [all(lcheck[i,:]) for i in n]

    elseif operator ∈ [">>",">"]
        lcheck = [all(leftvals[i,j] .> rightvals[i,:]) for i in n, j in 1:size(leftvals)[2]]
        ℧Δ = [all(lcheck[i,:]) for i in n]


    end

    ℧η[℧η] = ℧Δ

    (Ω, ℧η)
end

Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "b != a,c", "c =| 1,2"]); Ω[℧,:]
Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "b != a,c", "c == 1|2"]); Ω[℧,:]
Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "a < b,c",  "c |= 1,2"]);Ω[℧,:]
Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "b < 3 |=> a = b"]); Ω[℧,:]
Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "a == b <=| b << 3"]); Ω[℧,:]
Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "a == 1 <=> b == c"]); Ω[℧,:]
Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "a <= b,c", "c |= 1,2"]); Ω[℧,:]

Ω,℧ = ABparse(["a, b, c  ∈  [1,2,3]", "b , a == c-1", "c |= 1,2"]); Ω[℧,:]
Ω,℧ = ABparse(["a, b, c ∈  [1,2,3]", "a == c+b"]); Ω[℧,:]
Ω,℧ = ABparse(["a, b, c, d  ∈  [1,2,3,4]", "a , b |= c, d"]); Ω[℧,:]
Ω,℧ = ABparse(["a, b, c, d  ∈  [1,2,3,4]", "a != b, c, d", "b != c,d", "c != d"]); Ω[℧,:]
Ω,℧ = ABparse(["a, b, c, d  ∈  [1,2,3,4]", "a != b, c, d", "b != c,d", "c != d", "a == c+1", "d == a*2"]); Ω[℧,:]

ΩΩΩ[1][:,:]
(; zip([Symbol(i) for i in varsVect], fill(1:2, 3))...)

keys((fill(1:2, 3))) = [Symbol(i) for i in varsVect]
