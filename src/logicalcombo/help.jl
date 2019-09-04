
fundict = Dict()
catdict = Dict()

funadd(name::String, category) = x -> (fundict[name] = x; catdict[name] = category)
funadd(name::Array{String}, category) =
  (x -> for n in name; (fundict[n] = x; catdict[n] = category); end)

"`a > b`  : a is greater than b" |> funadd(">", "operator")
"`a >= b` : a is greater than or equal to b" |> funadd(">=", "operator")
"`a == b` : a is equal to b" |> funadd(["==", "="], "operator")
"`a < b`  : a is less than b" |> funadd("<", "operator")
"`a <= b` : a is less than or equal to b" |> funadd("<=", "operator")

"`a >> b`  : a is at least two greater than b. (`3 >> 1`) -> `true`" |>
  funadd(">>", "operator")
"`a << b`  : a is at least two less than b. (`3 << 1`) -> `true`" |>
  funadd("<<", "operator")

"`a & : a` is odd.\n`a & b, c`: a, b, and c is odd" |> funadd("&", "operator")
"`a ! : a` is odd.\n`a ! b, c`: a, b, and c is even" |> funadd("!", "operator")
"`a ^ b` checks if one side is odd and one side is even" |> funadd("^", "operator")

"""
`a, b` on the left (or right) is treated as saying that anything on that side
must conform to whatever operator follows.
""" |> funadd(",", "operator")

"""
`a|b` on the left (or right) is treated as saying that at least one value on
that side must conform to whatever operator follows.
""" |> funadd("|", "operator")

"""
`{#,#}` or `{#}`: it is often helpful to qualify the number of matches that
the grouping syntax can make.
Specifying `{#}` at the end of a `a = b|c` match will force # matches.
Specifying `{#1,#2}` will force a number of matches no less than `#1` and no
more than `#2`.
```julia
a | b | c = 1 {1,2}
```
Requires that at least one but no more than two of a, b, or c is equal to 1.
""" |> funadd("{", "operator")

help(x) = fundict[x] |> printmarkdown

help("=")
