
function ALrange(userinput; verbose=true)
  verbose && println(userinput)
  inputpass = string(replace(userinput, r"^(range)[\\:\\-\\ ]*"=>"")) |> strip
  (inputpass == "") && return println(range(replset))
  occursin(" ", inputpass) &&
    return replthrow("\n range only takes up to one variable currently!")
  !(inputpass ∈ replset.keys) &&
    return replthrow("\n $inputpass not found in replset!")
  return println(range(replset)[Symbol(inputpass)])
  return println(range(replset, inputpass))
  nothing
end
