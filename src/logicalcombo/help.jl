
fundict = Dict()
catdict = Dict()
equivdict = Dict()

spacer(x) = replace(x, "\n" => " \n \n ")

function funadd(name::String, category)
  x -> (fundict[name] = x; catdict[name] = category; equivdict[name] = [name])
end

function funadd(name::Array{String}, category)
  x -> for n in name
      fundict[n] = x;
      catdict[n] = category;
      equivdict[n] = name
    end
end

"""
`a, b ∈ 1:3`: add `a` and `b` to the feasible space with potential values 1, 2, 3
`a, b ∈ 1,2,3`: add `a` and `b` to the feasible space with potential values 1, 2, 3
`a, b ∈ up, down`: add `a` and `b` to the feasible space with potential values 'up', 'down'
""" |> funadd(["∈","in"], "Generator")

"""
`a, b, c ∈ 1:3` | {{i}} != {{!i}}: add `a`, `b` and `c` to the feasible space while
constraining `a`, `b`, and `c` each to not equal each other.
""" |> funadd("|", "Generator")


"`a > b`  : a is greater than b" |> funadd(">", "Operator")
"`a >= b` : a is greater than or equal to b" |> funadd(">=", "Operator")
"`a == b` : a is equal to b" |> funadd(["==", "="], "Operator")
"`a < b`  : a is less than b" |> funadd("<", "Operator")
"`a <= b` : a is less than or equal to b" |> funadd("<=", "Operator")

"`a >> b`  : a is at least two greater than b. (`3 >> 1`) -> `true`" |>
  funadd(">>", "Operator")
"`a << b`  : a is at least two less than b. (`3 << 1`) -> `true`" |>
  funadd("<<", "Operator")

"`a & : a` is odd.\n`a & b, c`: a, b, and c is odd" |> funadd("&", "Operator")
"`a ! : a` is odd.\n`a ! b, c`: a, b, and c is even" |> funadd("!", "Operator")
"`a ^ b` checks if one side is odd and one side is even" |> funadd("^", "Operator")

"""
`a, b` on the left (or right) is treated as saying that anything on that side
must conform to whatever Operator follows.
""" |> funadd(",", "Operator")

"""
`a|b` on the left (or right) is treated as saying that at least one value on
that side must conform to whatever Operator follows.
""" |> funadd("|", "Operator")

"""
`{#,#}` or `{#}`: it is often helpful to qualify the number of matches that the `or` syntax can make.
Specifying `{#}` at the end of a `a = b|c` match will force `#` matches.
Specifying `{#1,#2}` will force a number of matches no less than `#1` and no more than `#2`.
#### Example
`abstractlogic> a | b | c | d = 1 {2,3}`
Requires that at least two but no more than three of `a`, `b`, `c`, or `d` to equal 1.
""" |> funadd("{", "Operator")

Generatorlist = [v[1] for v in catdict if v[2]=="Generator"]
operatorlist = [v[1] for v in catdict if v[2]=="Operator"]
superoperatorlist = [v[1] for v in catdict if v[2]=="Superoperator"]
metaoperatorlist = [v[1] for v in catdict if v[2]=="Metaoperator"]

function help(x::String)
  x = replace(x, r"^\?"=>"")
  if (haskey(fundict, x))
    also = (length(equivdict[x]) == 1 ? "" : "**variantes:** `" * join(equivdict[x],", ") * "` \n")
    "**$(catdict[x])**: `$x` \n " * also * " \n " * fundict[x] |>
    spacer |>  printmarkdown
    return
  end
  """
  *`$x` not found*. Try
  Generators: `$(join(Generatorlist, " "))`
  Operators: `$(join(operatorlist, " "))`
  Superoperators: `$(join(superoperatorlist, " "))`
  Metaoperators: `$(join(metaoperatorlist, " "))`
  """ |> spacer |> printmarkdown
end

help("=")
help(":")
help("in")
help("{")
