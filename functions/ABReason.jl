
command = "a, b, c  ∈  [1,2,3]"

function ABparse(a::String)
  occursin("∈", a) && ABassign!(a)
end

function ABassign!(command::String)
  vars, valsin = strip.(split(command, "∈"))
  varsVect = split(vars, ",") .|> strip
  vals = parse.(Int, split(replace(valsin, r"\[|\]" => ""), ",") .|> strip)

  outset = (; zip([Symbol(i) for i in varsVect], fill(vals, 3))...)

  x = Hotcomb(outset)
  append!(ΩΩΩ, [x])
end

ΩΩΩ = []

ABparse("a, b, c  ∈  [1,2,3]")[1][:,:]
ABparse("a, b, c, d, e  ∈  [1,2,3,4]")[2][:,:]

ΩΩΩ[1][:,:]
(; zip([Symbol(i) for i in varsVect], fill(1:2, 3))...)

keys((fill(1:2, 3))) = [Symbol(i) for i in varsVect]
