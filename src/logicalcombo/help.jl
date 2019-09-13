
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

## Repl
"Print a table of 10 feasible results (head and tail)." |> funadd(["show", "s"], "REPL")
"Print a table of all feasible results." |> funadd("showall", "REPL")
"Go back one command." |> funadd(["back", "b"], "REPL")
"Go forward one command. Only works if you have gone back first." |> funadd(["next", "n", "f"], "REPL")
"Empty the current variable space." |> funadd("clear", "REPL")
"Empty the current as well as the logicset space." |> funadd("clearall", "REPL")
"Save the current variable space for use with `restore`." |> funadd("preserve", "REPL")
"Restore the last saved variable space." |> funadd("restore", "REPL")
"Show command history with # feasible." |> funadd(["history", "h"], "REPL")
"List variables names." |> funadd(["keys","k"], "REPL")
"Toggles the dashboard printout - primarily used for debugging." |> funadd(["dashboard", "dash"], "REPL")

"""
Show all logical sets currently in working REPL memmory. Exiting the REPL:
`julia> returnactivelogicset()` returns the most recent set
`julia> returnlogicset()` returns a vector of all sets worked on int REPL
""" |> funadd(["logicset","ls"], "REPL")

"""
Returns documentation related to a function or command to the user.

**NOTE** `julia> help(...)` returns identical information.
###### Example
abstractlogic> ? >
  Operator: >

  a > b : a is greater than b
""" |> funadd(["?", "help"], "REPL")


"""
check feasibility of subsequent command
### Example
`abstractlogic>` a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :2 3 3

`abstractlogic>` a > b ; b > c

a > b                    feasible outcomes 9 ✓           :3 2 3
b > c                    feasible outcomes 1 ✓✓          :3 2 1

`abstractlogic>` check a == 3
Check: a == 3 ... a == 3                         feasible outcomes 1 ✓✓          :3 2 1
true, 1 out of 1 possible combinations 'true'.
""" |> funadd("check", "REPL")

"""
search feasibility of {{i}} match
### Example
`abstractlogic>` a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :2 3 3

`abstractlogic>` a > b ; b > c

a > b                    feasible outcomes 9 ✓           :3 2 3
b > c                    feasible outcomes 1 ✓✓          :3 2 1

`abstractlogic>` search == 3

Checking: a == 3
Checking: b == 3
Checking: c == 3

:a is a match with 1 feasible combinations out of 1.
:b is a not match with 0 feasible combinations out of 1.
:c is a not match with 0 feasible combinations out of 1.
""" |> funadd("search", "REPL")



"""
`a, b, c ∈ 1:3` | {{i}} != {{!i}}: add `a`, `b` and `c` to the feasible space while
constraining `a`, `b`, and `c` each to not equal each other.
""" |> funadd("||", "Generator")


## Generators
"""
`a, b ∈ 1:3`: add `a` and `b` to the feasible space with potential values 1, 2, 3
`a, b ∈ 1,2,3`: add `a` and `b` to the feasible space with potential values 1, 2, 3
`a, b ∈ up, down`: add `a` and `b` to the feasible space with potential values 'up', 'down'
""" |> funadd(["∈","in"], "Generator")

"""
`a, b, c ∈ 1:3` | {{i}} != {{!i}}: add `a`, `b` and `c` to the feasible space while
constraining `a`, `b`, and `c` each to not equal each other.
""" |> funadd("||", "Generator")

## Operators
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
``abstractlogic>` a | b | c | d = 1 {2,3}`
Requires that at least two but no more than three of `a`, `b`, `c`, or `d` to equal 1.
""" |> funadd("{", "Operator")

## Superoperators

"""
`x &&& y`: both x and y must be `true`. Command end operator `;` is often preferred
to joint evaluators since it is more efficient. In `x ; y` efficiency is gained
by evaluating `x` first, reducing the feasible set, then evaluating `y`.
**Note** `x and y` is equivalent
#### Example
`abstractlogic>` a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
`abstractlogic>` a > b &&& b > c
a > b &&& b > c                  feasible outcomes 1 ✓✓          :3 2 1
""" |> funadd(["&&&", "and"], "Superoperator")

"""
`x ||| y` either x or y must be `true`. If both are `false` then total expression will return false.
**Note** `x or y` is equivalent
#### Example
`abstractlogic>` a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
`abstractlogic>` a > b ||| b > c
a > b ||| b > c                  feasible outcomes 17 ✓          :2 2 1
""" |> funadd(["|||", "or"], "Superoperator")

"""
`x !== y` either x or y must be `true` but not both. If both are `false` or
both are `true` then it will return `false`.
**Note** `x xor y` and `x ^^^ y` is equivalent (`x` and `y` can only be `true` or `false`)
#### Example
`abstractlogic>` a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
`abstractlogic>` a > b ^^^ b > c
a > b ^^^ b > c                  feasible outcomes 16 ✓          :3 3 2
""" |> funadd(["^^^","xor","!=="], "Superoperator")

"""
`x === y` if `x = true` then `y = true` or if `x = false` then `y = false`.
**Note** `x iff y` and `x <=> y` are equivalent
#### Example
`abstractlogic>` a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
`abstractlogic>` a > b === b > c
a > b === b > c                  feasible outcomes 11 ✓          :1 3 3
""" |> funadd(["===", "iff", "<=>"], "Superoperator")

"""
`x ==> y` if `x = true` then `y` must be `true`.
**Note** `if x then y` and `x then y` are equivalent
#### Example
`abstractlogic>` a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
`abstractlogic>` a > b ==> b > c
a > b ==> b > c                  feasible outcomes 19 ✓          :3 3 3
""" |> funadd(["==>", "then", "if...then"], "Superoperator")

"""
`x <== y` if `y = true` then `x` must be `true`.
**Note** `x if y` is equivalent
#### Example
`abstractlogic>` a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
`abstractlogic>` a > b <== b > c
a > b <== b > c                  feasible outcomes 19 ✓          :3 1 1
""" |> funadd(["<==", "if"], "Superoperator")

## Metaoperators

"""
`x &&&& y`: both x and y must be `true`. Command end operator `;` is often preferred
to joint evaluators since it is more efficient. In `x ; y` efficiency is gained
by evaluating `x` first, reducing the feasible set, then evaluating `y`.
**Note** `x AND y` is an equivalent expression.
#### Example
`abstractlogic>` a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
`abstractlogic>` a > b &&&& b > c
a > b &&&& b > c                  feasible outcomes 1 ✓✓          :3 2 1
""" |> funadd(["&&&&", "AND"], "Metaoperator")


"""
`x |||| y` either x or y must be `true`. If both are `false` then total expression will return false.
**Note** `x or y` is equivalent
#### Example
`abstractlogic>` a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
`abstractlogic>` a > b |||| b > c
a > b ||| b > c                  feasible outcomes 17 ✓          :2 2 1
""" |> funadd(["||||", "OR"], "Metaoperator")

"""
`x !=== y` either x or y must be `true` but not both. If both are `false` or
both are `true` then it will return `false`.
**Note** `x xor y` and `x ^^^ y` is equivalent (`x` and `y` can only be `true` or `false`)
#### Example
`abstractlogic>` a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
`abstractlogic>` a > b !=== b > c
a > b !=== b > c                  feasible outcomes 16 ✓          :3 3 2
""" |> funadd(["^^^^","XOR","!==="], "Metaoperator")

"""
`x ==== y` if `x = true` then `y = true` or if `x = false` then `y = false`.
**Note** `x IFF y` and `x <==> y` are equivalent
#### Example
`abstractlogic>` a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
`abstractlogic>` a > b ==== b > c
a > b ==== b > c                  feasible outcomes 11 ✓          :1 3 3
""" |> funadd(["====", "IFF", "<==>"], "Metaoperator")

"""
`x ===> y` if `x = true` then `y` must be `true`.
**Note** `IF x THEN y` and `x THEN y` are equivalent
#### Example
`abstractlogic>` a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
`abstractlogic>` a > b ===> b > c
a > b ===> b > c                  feasible outcomes 19 ✓          :3 3 3
""" |> funadd(["===>", "THEN", "IF...THEN"], "Metaoperator")

"""
`x <=== y` if `y = true` then `x` must be `true`.
**Note** `x IF y` is equivalent
#### Example
`abstractlogic>` a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
`abstractlogic>` a > b <=== b > c
a > b <=== b > c                  feasible outcomes 19 ✓          :3 1 1
""" |> funadd(["<===", "IF"], "Metaoperator")

## Wildcards
"""
* `{{i}}` the most basic wildcard reference is `{{i}}`. It can take any variable name from the set of variables so far defined.
#### Example
`abstractlogic>` a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
`abstractlogic>` a > b <=== b > c
a > b <=== b > c                  feasible outcomes 19 ✓          :3 1 1
""" |> funadd(["{{i}}", "i"], "Wildcard")

"""
* `{{!i}}` any variable not `i`.
**NOTE** In general `!i` is not that helpful as there are few operations which `!i` does not return an empty set. And those cases in which it doesn't seem to be more efficiently expressed as `>i` or `<i`.
#### Example
`abstractlogic>` a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
`abstractlogic>` {{i}} == {{!i}}
{{i}} == {{!i}}
`>>>` a == b
`>>>` a == c
`>>>` b == a
`>>>` b == c
`>>>` c == a
`>>>` c == b
                 feasible outcomes 3 ✓           :3 3 3
""" |> funadd(["{{!i}}", "!i"], "Wildcard")

"""
`{{>i}}` any variable to the right of `i`.
#### Example
`abstractlogic>` a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
`abstractlogic>` {{i}} == {{>i}}
{{i}} == {{>i}}
`>>>` a == b
`>>>` a == c
`>>>` b == c
                 feasible outcomes 3 ✓           :3 3 3
""" |> funadd(["{{>i}}", ">i"], "Wildcard")

"""
`{{<i}}` any variable to the left of `i`.
#### Example
`abstractlogic>` a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
`abstractlogic>` {{i}} == {{<i}}
{{i}} == {{<i}}
`>>>` b == a
`>>>` c == a
`>>>` c == b
                 feasible outcomes 3 ✓           :3 3 3
""" |> funadd(["{{<i}}", "<i"], "Wildcard")

"""
`{{<<i}}` any variable at least two to the left of `i`.
#### Example
`abstractlogic>` a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
`abstractlogic>` {{i}} == {{<<i}}
{{i}} == {{<<i}}
`>>>` c == a
         feasible outcomes 9 ✓           :3 1 3
""" |> funadd(["{{<<i}}", "<<i"], "Wildcard")

"""
`{{>>i}}` any variable at least two to the right of `i`.
#### Example
`abstractlogic>` a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
`abstractlogic>` {{i}} == {{>>i}}
{{i}} == {{>>i}}
`>>>` a == c
         feasible outcomes 9 ✓           :2 1 2
""" |> funadd(["{{>>i}}", ">>i"], "Wildcard")

"""
`{{i+n}}`, `{{i-n}}` takes n steps right `+` or left `-` of `i`.
#### Example
`abstractlogic>` a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
`abstractlogic>` {{i}} != {{i+1}}
{{i}} != {{i+1}}
`>>>` a != b
`>>>` b != c
         feasible outcomes 12 ✓          :1 2 1
""" |> funadd(["{{i+n}}", "{{i-n}}", "i+n", "i-n"], "Wildcard")

"""
* `{{i+n!}}`, `{{i-n!}}` forces n steps right `+` or left `-` of `i`. If that
step cannot be taken the variable is replaced by `999` which with numeric
comparisons this will have different effects.
#### Example
`abstractlogic>` a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
`abstractlogic>` {{i}} = 1 ==> {{i+1!}} = 2
{{i}} = 1 ==> {{i+1!}} = 2
`>>>` a = 1 ==> b = 2
`>>>` b = 1 ==> c = 2
`>>>` c = 1 ==> 999 = 2
         feasible outcomes 12 ✓          :1 2 3
""" |> funadd(["{{i+n!}}", "{{i-n!}}", "i+n!", "i-n!"], "Wildcard")

"""
`{{N}}` evaluates every permutation given the wildcard set and evaluates the entire
expression as `true` only if the number of values across wildcards is equal to `N`.
**Note** `{{N}}` must appear at the end of the *superoperator* expression.
#### Example
`abstractlogic>` a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
`abstractlogic>` {{i}} = 2 {{2}}
{{i}} = 2 {{2}}
`>>>` a = 2
`>>>` b = 2
`>>>` c = 2
                 feasible outcomes 6 ✓           :2 2 3
Forces at least two variables from `a`, `b`, and `c` to equal `2`.
""" |> funadd(["{{N}}", "N"], "Wildcard")

"""
`{{n1,n2}}` evaluates every permutation given the wildcard set and evaluates the entire
expression as `true` only if the number of values across wildcards is at least `n1` and no
more than `n2`. If `n1` is empty then it is set to zero. If `n2` is empty it is set to a
large number.
**Note** `{{n1,n2}}` must appear at the end of the *superoperator* expression.
**Hint** `{{,n2}}` can be read as "at most" while `{{n1,}}` can be read "at least".
#### Example
```julia
`abstractlogic>` a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
`abstractlogic>` {{i}} = 3 {{1,2}}
{{i}} = 3 {{1,2}}
`>>>` a = 3
`>>>` b = 3
`>>>` c = 3
         feasible outcomes 18 ✓          :2 3 3
```
Forces at least one or two of the variables to equal `3`.
""" |> funadd(["{{n1,n2}}", "n1,n2", ",n2", "n1,"], "Wildcard")

"""
`{{j}}` `j` is exactly the same as `i` except that it ignores the parts of variable names that come after `.`s. So `a.1` just becomes `a` in the substitution mechanism.
#### Example
```julia
`abstractlogic>` a.1,a.2 ,b.1 ,b.2, c.1, c.2  ∈ 1:3
a.1,a.2 ,b.1 ,b.2, c.1, c.2  ∈ 1:3       feasible outcomes 729 ✓         :2 3 3 2 3 1
`abstractlogic>` {{j}}.1 < {{j}}.2
{{j}}.1 < {{j}}.2
`>>>` a.1 < a.2
`>>>` b.1 < b.2
`>>>` c.1 < c.2
         feasible outcomes 27 ✓          :1 2 1 2 1 3

`abstractlogic>` back
Last command: "a.1,a.2 ,b.1 ,b.2, c.1, c.2  ∈ 1:3" - Feasible Outcomes: 729     :1 3 2 1 2 3

`abstractlogic>` {{j}}.1 == {{j+1}}.2
{{j}}.1 == {{j+1}}.2
`>>>` a.1 == b.2
`>>>` b.1 == c.2
         feasible outcomes 81 ✓          :3 1 1 3 1 1
""" |> funadd(["{{j}}", "j"], "Wildcard")


## Process the Different files
repllist          = [v[1] for v in catdict if v[2]=="REPL"]     |> sort
generatorlist     = [v[1] for v in catdict if v[2]=="Generator"]     |> sort
operatorlist      = [v[1] for v in catdict if v[2]=="Operator"]      |> sort
superoperatorlist = [v[1] for v in catdict if v[2]=="Superoperator"] |> sort
metaoperatorlist  = [v[1] for v in catdict if v[2]=="Metaoperator"]  |> sort
wildcardlist      = [v[1] for v in catdict if v[2]=="Wildcard"]      |> sort

function help(x::String)
  x = replace(x, r"^(\?|help)"=>"") |> strip
  if (haskey(fundict, x))
    also = (length(equivdict[x]) == 1 ? "" : "**variantes:** `" * join(equivdict[x],", ") * "` \n")
    "**$(catdict[x])**: `$x` \n " * also * " \n " * fundict[x] |>
    spacer |>  printmarkdown
    return
  end
  """
  *`$x` not found*. Search any of the following:
  REPL Commands: `$(join(repllist, "`, `"))`
  Generators: `$(join(generatorlist, "`, `"))`
  Operators: `$(join(operatorlist, "`, `"))`
  Superoperators: `$(join(superoperatorlist, "`, `"))`
  Metaoperators: `$(join(metaoperatorlist, "`, `"))`
  Wildcards: `$(join(wildcardlist, "`, `"))`
 """ |> spacer |> printmarkdown
end

# help("=")
# help(":")
# help("in")
# help("&&&")
# help("&&&")

help() = help("")
