# Global set variables Ω, Υ hold
integer(x::AbstractString) = parse(Int, strip(x))
Base.range(x::AbstractString) = range(integer(match(r"^[0-9]+", x).match),
                               stop = integer(match(r"[0-9]+$", x).match))
ABoccursin(y::Symbol) = any( [ y ∈ keys(Ω[i]) for i in 1:length(Ω) ] )

function ABparse(commands::Array{String,1})
  println("")

  for i in commands
      print(i)
      ABparse(i)

      sum(sum.(Υ))
      println(" ✓")

  end
end

function ABparse(command::String)
  exclusionlist = ["in"]
  occursin(r"∈|\bin\b", command) && return ABassign!(command)

  # Check for the existance of any symbols in Ω
  varcheck = eachmatch(r"[a-zA-Z][0-9a-zA-Z]*", command)
  smatch = [String(s.match) for s in symbols]

  sym = [Symbol(s.match) for s in varcheck if !(s.match ∈ exclusionlist)]
  for S in sym
      !ABoccursin(S) && throw("In {$command} variable {:$S} not found in Ω")
  end
end

function ABassign!(command::String)
  vars, valsin = strip.(split(command, r"∈|\bin\b"))
  varsVect = split(vars, ",") .|> strip
  vals0 = split(replace(valsin, r"\[|\]" => ""), ",")

  (length(vals0) > 1) && (vals =  [(occursin(r"^[0-9]+$", i) && integer(i)) for i in vals0])
  (length(vals0) == 1 && occursin(r"^[0-9]+:[0-9]+$", vals0[1])) && (vals = range(vals0[1]))

  outset = (; zip([Symbol(i) for i in varsVect], fill(vals, length(vars)))...)

  x = Hotcomb(outset)
  y = fill(true, size(x)[1])

  global Ω, Υ
  (isdefined(Main, :Υ) ? append!(Υ, [y]) : Ω = [[y]])
  (isdefined(Main, :Ω) ? append!(Ω, [x]) : Ω = [x])
end

command = "a,b,d = 1"
# command = "a = 1|2"

ABparse(["a,b,c ∈ [1:3]"])


y=:a

function ABequal(command)
  left, right = strip.(split(command, "="))

  for i in i:length(Ω)
   i=1

   for L in lefts
    Lvalues = occursin(r"^[a-zA-Z][0-9a-zA-Z]*$",L) && (Symbol(L) ∈ keys(Ω[i])) &&
      (Ω[i][Υ[i], Symbol(L)])

    (length(Lvalues)==0) && continue
    #(!Lvalues[1]) && throw("In $command $L not found in Ω")

    if occursin(r"\|", right)
      checkset = fill(false, length(Lvalues))
        for R in (split(right, "|") .|> strip)
          occursin(r"^[a-zA-Z][0-9a-zA-Z]*$",R) && (Symbol(R) ∈ keys(Ω[i])) &&
            (Rvalues = (Ω[i][Υ[i], Symbol(R)]))
        checkset = checkset .| (Rvalues .== Lvalues)
       end
       Υ[i][Υ[i]] = checkset
    elseif occursin(r"&", right)

    else
        checkset = occursin(r"^[0-9]+$",right) &&
          (Rvalues = integer(match(r"^[0-9]+$",right).match))
        occursin(r"^[a-zA-Z][0-9a-zA-Z]*$",R) && (Symbol(R) ∈ keys(Ω[i])) &&
          (Rvalues = (Ω[i][Υ[i], Symbol(R)]))
        checkset = (Rvalues .== Lvalues)
        Υ[i][Υ[i]] = checkset
    end
   end

   occursin(r"^[0-9]+$",j) && (fill())

  end
end

function ABclear()
  global Ω, Υ
  Ω = []
  Υ = []
end

set = [(a=1, b=2), (c=2, d=3), (a=39, n=92)]
[:a ∈ keys(set[i]) for i in 1:length(set)]

ABclear(); Ω

ABparse("a, b, c  ∈  [1,2,3]"); Ω
ABparse("a, b, c, d, e  ∈  [1,2,3,4]") ; Ω
ABparse("a, b, c  in [2:3]") ; Ω

ABparse("a, b, c  ∈  [1,2,3]"); Ω


ΩΩΩ[1][:,:]
(; zip([Symbol(i) for i in varsVect], fill(1:2, 3))...)

keys((fill(1:2, 3))) = [Symbol(i) for i in varsVect]
