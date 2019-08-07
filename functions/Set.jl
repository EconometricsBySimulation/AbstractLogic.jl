# Global set variables Ω, Υ hold
integer(x::AbstractString) = parse(Int, strip(x))
Base.range(x::AbstractString) = range(integer(match(r"^[0-9]+", x).match),
                               stop = integer(match(r"[0-9]+$", x).match))
ABoccursin(y::Symbol) = any( [ y ∈ keys(Ω[i]) for i in 1:length(Ω) ] )
ABoccursin(x::Hotcomb, y::Symbol) = y ∈ keys(x)

function ABparse(commands::Array{String,1})
  println("")

  for i in commands
      print(i)
      ABparse(i)

      feasibleoutcomes = (length(Υ)>0) ? prod(sum.(Υ)) : 0
      filler = repeat("\t", max(1, 3-Integer(round(length(i)/10))))
      println(" $filler feasible outcomes $feasibleoutcomes ✓")

  end
end

function ABparse(command::String)
  exclusionlist = ["in"]
  command == "clear" && return ABclear!()
  occursin(r"∈|\bin\b", command) && return ABassign!(command)

  # Check for the existance of any symbols in Ω
  varcheck = eachmatch(r"[a-zA-Z][0-9a-zA-Z_.]*", command)

  # Checks if any of the variables does not exist in Ω
  for S in [Symbol(s.match) for s in varcheck if !(s.match ∈ exclusionlist)]
      !ABoccursin(S) && throw("In {$command} variable {:$S} not found in Ω")
  end

  occursin(r"(( |\b)+=+( |\b)+)", command) && return ABequal!(command)

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

ABorequal(a,b) = [any([a[j][i] ∈ b[k][i] for j in 1:length(a), k in 1:length(b)]) for i in 1:length(a[1])]

function ABequal(command)

  left, right = strip.(split(command, r"[=]+"))
  #global Υ, Ω
  Υ2 = Υ

  for i in 1:length(Ω)

       Lcheckset = fill(true,  sum(Υ[i]))
       occursin(r"[|]", left) && (Lcheckset = fill(false,  sum(Υ[i])))

           for L in [Symbol(x) for x in strip.(split(left, r"[,|&]"))]
            !ABoccursin(Ω[i], L) && continue
            Lvalues = Ω[i][Υ[i], L]

            (length(Lvalues)==0) && continue
            #(!Lvalues[1]) && throw("In $command $L not found in Ω")

            Rcheckset = fill(true,  length(Lvalues))
            occursin(r"\|", right) && (Rcheckset = fill(false, length(Lvalues)))

            for R in strip.(split(right, r"[,|&]"))
                rsymb = occursin(r"^[a-zA-Z][0-9a-zA-Z]*$",R)

                rsymb && !ABoccursin(Ω[i], Symbol(R)) && continue
                rsymb && (Rvalues = (Ω[i][Υ[i], Symbol(R)]))

                !rsymb && (Rvalues = integer(R))

                if occursin(r"\|", right)
                  Rcheckset = Rcheckset .| (Lvalues .== Rvalues)
                else
                  Rcheckset = Rcheckset .& (Lvalues .== Rvalues)
                end
            end

          occursin(r"\|", right)  && (Υ2[i][Υ[i]] = Lcheckset .| Rcheckset)
          !occursin(r"\|", right) && (Υ2[i][Υ[i]] = Lcheckset .& Rcheckset)

        end
    end
  Υ2
end

function ABclear!()
  global Ω, Υ
  Ω = []
  Υ = []
end

ABclear!(); Ω

ABparse("a, b, c  ∈  [1,2,3]"); Ω
ABparse("a, b, c, d, e  ∈  [1,2,3,4]") ; Ω
ABparse("a, b, c  in [2:3]") ; Ω

ABparse(["clear",
         "a, b, c  ∈  [1,2,3]",
         "b | a = c",
         "c = 1|2"]); Ω[1][Υ2[1],:]


ΩΩΩ[1][:,:]
(; zip([Symbol(i) for i in varsVect], fill(1:2, 3))...)

keys((fill(1:2, 3))) = [Symbol(i) for i in varsVect]