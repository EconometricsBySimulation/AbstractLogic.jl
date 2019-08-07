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

  for c in commands
      print(command)
      Ω, ℧ = ABparse(command, Ω, ℧)

      feasibleoutcomes = (length(℧)>0) ? sum(℧) : 0
      filler = repeat("\t", max(1, 3-Integer(round(length(c)/10))))
      println(" $filler feasible outcomes $feasibleoutcomes ✓")

  end
  (Ω, ℧)
end

commands = ["a, b, c, d  ∈  [1,2,3,4]", "a , b |= c, d"]
commands = ["a, b, c, d  ∈  [1,2,3,4]", "a != b, c, d"]

command = commands[2]

function ABparse(command::String,  Ω::Hotcomb, ℧::Array{Bool,1})
  # A vector of non-standard operators to ignore
  exclusionlist = ["\bin\b"]

  occursin(r"∈|\bin\b", command) && ((Ω,℧) = ABassign(command))

  # Check for the existance of any symbols in Ω
  varcheck = eachmatch(r"[a-zA-Z][0-9a-zA-Z_.]*", command)

  # Checks if any of the variables does not exist in Ω
  for S in [Symbol(s.match) for s in varcheck if !(s.match ∈ exclusionlist)]
      !ABoccursin(Ω, S) && throw("In {$command} variable {:$S} not found in Ω")
  end

  occursin(r"( |\b)(==|\|=|!=|=)(\b| )", command) && ((Ω,℧) = ABevaluate(command,Ω,℧))

  (Ω,℧)
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

ABorequal(a,b) = [any([a[j][i] ∈ b[k][i] for j in 1:length(a), k in 1:length(b)]) for i in 1:length(a[1])]


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
  !(n2 === nothing) && (right = fill(integer(n2), length(℧)))

  (o1 == "+") && return left .+ right
  (o1 == "-") && return left .- right
  (o1 == "/") && return left ./ right
  (o1 == "*") && return left .* right
end

function ABevaluate(command, Ω::Hotcomb, ℧::Array{Bool,1})
    (sum(℧) == 0) && return (Ω, ℧)

    n = 1:sum(℧)

    m = match(r"(.*)(\b(==|\|!=)\b)(.*)",replace(command, " "=>""))
    left, blank, operator, right = m.captures

    leftarg  = strip.(split(left,  r"[,|&]"))
    rightarg = strip.(split(right, r"[,|&]"))

    leftvals  = hcat([grab(L, Ω, ℧, command=command) for L in leftarg]...)
    rightvals = hcat([grab(R, Ω, ℧, command=command) for R in rightarg]...)

    if operator == "!="
        lcheck = [any(leftvals[i,j] .== rightvals[i,:]) for i in n, j in 1:size(leftvals)[2]]
        ℧Δ = [!all(lcheck[i,:]) for i in n]

    elseif (operator == "==") | (operator == "=")
        lcheck = [all(leftvals[i,j] .== rightvals[i,:]) for i in n, j in 1:size(leftvals)[2]]
        ℧Δ = [all(lcheck[i,:]) for i in n]

    elseif operator == "|="
        lcheck = [any(leftvals[i,j] .== rightvals[i,:]) for i in n, j in 1:size(leftvals)[2]]
        ℧Δ = [any(lcheck[i,:]) for i in n]
    end

    ℧[℧] = ℧Δ

    (Ω, ℧)
end

ABclear!(); Ω

ABparse("a, b, c  ∈  [1,2,3]"); Ω
ABparse("a, b, c, d, e  ∈  [1,2,3,4]") ; Ω
ABparse("a, b, c  in [2:3]") ; Ω

a,b = ABparse(["a, b, c  ∈  [1,2,3]",
         "b , a == c-1",
         "c |= 1|2"]);
a[b,:]

a,b = ABparse(["a, b, c ∈  [1,2,3]", "a == c+b"]);
a[b,:]

a,b = ABparse(["a, b, c, d  ∈  [1,2,3,4]", "a , b |= c, d"]);
a[b,:]

a,b = ABparse(["a, b, c, d  ∈  [1,2,3,4]", "a != b, c, d", "b != c,d", "c != d"]);
a[b,:]

a,b = ABparse(["a, b, c, d  ∈  [1,2,3,4]", "a != b, c, d", "b != c,d", "c != d", "a == c+1"]);
a[b,:]

ΩΩΩ[1][:,:]
(; zip([Symbol(i) for i in varsVect], fill(1:2, 3))...)

keys((fill(1:2, 3))) = [Symbol(i) for i in varsVect]
