
function ALrange(userinput; verbose=true)
    inputpass = string(replace(userinput, r"^(range)[\\:\\-\\ ]*"=>"")) |> strip
    (inputpass == "") && (inputpass = join(string.(replset.keys),","))

    for v in strip.(split(inputpass, r",| "))
        !(Symbol(v) ∈ replset.keys) && return replthrow("\n $v not found in replset!")
        verbose && println(v * " = {" * join(range(replset)[Symbol(v)], ",") * "}")
    end
end
