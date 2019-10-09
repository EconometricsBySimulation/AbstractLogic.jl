# Getting Started

## Installation

The `AbstractLogic` package is available through gitbub and can be installed using the following commands after entering the package REPL by typeing `]` in the console.
```julia
pkg> add https://github.com/EconometricsBySimulation/AbstractLogic.jl
```

Leave the package REPL by hitting `<backspace>`. Now you can use the `AbstractLogic` package anytime by typing `using AbstractLogic` in Julia.

## Interacting with AbstractLogic
There are two basic methods of interacting with the solver: `logicalparse` and the `REPL`. `logicalparse` is generally preferred when programmatically interacting with the solver while `REPL` is convenient when interacting with the solver less formally.

## Julia AbstractLogic Functions:
One method is using `Julia` functions mainly `logicalparse`, `checkfeasible`, and `search`. This method relies primarily on `LogicalCombo` objects which are generated from and can be passed into `logicalparse`.

### `logicalparse()`
This which evaluates `abstractlogic` commands to either generate data or constrain the data. The `REPL` will attempt to match any special `REPL` commands input into the `REPL`, if no matches are found the command is passed to `logicalparse` for evaluation.

### `checkfeasible()`
Is called when the user would like to check if a command produces a valid result, possible result, or invalid result. The result is returned as a decimal from 0.0 to 1.0. With 0.0 being no matches and 1.0 being all matches.

### `search()`
Searches for a possible match among a `LogicalCombo` in which the wildcard term is true. Search requires the use of a wildcard. In the event that a wildcard is missing, search will insert a `{{i}}` to the left of the command. `{{i+1}}` can be used to search for relationships between the ith column and the column one step to the right.

### `help()`
Searches the `AbstractLogic` package for matches.
```julia
help()
`` not found. Search any of the following:

  REPL Commands: ?, b, back, check, clear, clearall, dash, dashboard, f, h, help, history, k, keys, logicset, ls, n, next, preserve, restore, s, search, show, showall

  Generators: in, ||, ∈

  Operators: !, &, ,, <, <<, <=, =, ==, >, >=, >>, ^, {, |

  Superoperators: !==, &&&, <==, <=>, ===, ==>, ^^^, and, if, if...then, iff, or, then, xor, |||

  Metaoperators: !===, &&&&, <===, <==>, ====, ===>, AND, IF, IF...THEN, IFF, OR, THEN, XOR, ^^^^, ||||

  Wildcards: !i, ,n2, <<i, <i, >>i, >i, N, i, i+n, i+n!, i-n, i-n!, j, n1,, n1,n2, {{!i}}, {{<<i}}, {{<i}}, {{>>i}}, {{>i}}, {{N}}, {{i+n!}}, {{i+n}}, {{i-n!}}, {{i-n}}, {{i}}, {{j}}, {{n1,n2}}
```

### Setting up a logical set
To set up an initial logical set. Pass a text command to logicalparse with the variable names on the left and range of possible values on the left with the ∈ or `in` operator in between.

```julia
julia> logicalset = logicalparse("a, b, c ∈ 1, 2, 3")
a, b, c ∈ 1, 2, 3        feasible outcomes 27 ✓          :3 1 3
```

`logicalparse` will now generate a lookup object of type `LogicalCombo` which tells `AbstractLogic` what options are feasible as well as which ones have been excluded. Every time `logicalparse` runs it prints the number of feasible outcomes, the number of "percieved" outcomes in terms of (product of the # of options) in the set given the current constraints as well as a random single feasible value that the variables can hold.

While many logical problems do have equivalent value ranges for each variable `AbstractLogic` has no such constraint. Additional variables can be added to a set in an equivalent as those added upon set initiation.

```julia
julia> logicalset = logicalparse("d ∈ 4,5", logicalset)
d ∈ 4,5                          feasible outcomes 54 ✓          :2 1 1 5
```

Variable values need not be of the same type.

```julia
julia> logicalset = logicalparse("bob, ali ∈ old, young", logicalset)
bob, ali ∈ old, young    feasible outcomes 216 ✓         :3 2 3 5 young old
```

### Constraining the logical set
`logicalparse` is also the command used to set constraints on the logical set. These constraints are defined through use of operators expressing relationships between variables or constants.

Forcing variable a to take on the same value as variable c we could write.

```julia
julia> logicalset = logicalparse("a = c", logicalset)
a = c                    feasible outcomes 72 ✓          :2 3 2 5 young young
```

We can also force variables to take the value of a constant.

```julia
julia> logicalset = logicalparse("b = 2", logicalset)
b = 2                    feasible outcomes 24 ✓          :2 2 2 4 old old
```

Though constant strings need be quoted as they would otherwise be attempted to be parsed as variables.

```julia
julia> logicalset = logicalparse("ali = 'old'", logicalset)
ali = 'old'              feasible outcomes 12 ✓          :3 2 3 4 old old
```

Perhaps we would like to force Ali to be a different age than Bob.

```julia
julia> logicalset = logicalparse("ali != bob", logicalset)
ali != bob               feasible outcomes 6 ✓           :2 2 2 4 young old
```

### Checking the Feasibility of a Statement
We might often like to check the feasiblility of a claim. Perhaps we would like to ask if Bob is young.

```julia
julia> checkfeasible("bob == 'young'", logicalset)
Check: bob == 'young' ... bob == 'young'                 feasible outcomes 6 ✓           :3 2 3 4 young old
true, 6 out of 6 possible combinations 'true'.
2-element Array{Any,1}:
 1.0

  LogicalCombo(Symbol[:a, :b, :c, :d, :bob, :ali], Array{T,1} where T[[1, 2, 3], [1, 2, 3], [1, 2, 3], [4, 5], ["old", "young"], ["old", "young"]], Bool[false, false, false, false, false, false, false, false, false, false  …  false, false, false, false, false, false, false, false, false, false])
```

### Search for a Possible Match
We might instead want to ask the question, which variables could take on a value equal to 3.

```julia
julia> search("== 3 ", logicalset)
Checking: a == 3
Checking: b == 3
Checking: c == 3
Checking: d == 3
Checking: bob == 3
Checking: ali == 3

:a is a possible match with 2 feasible combinations out of 6.
:b is a not match with 0 feasible combinations out of 6.
:c is a possible match with 2 feasible combinations out of 6.
:d is a not match with 0 feasible combinations out of 6.
:bob is a not match with 0 feasible combinations out of 6.
:ali is a not match with 0 feasible combinations out of 6.
6-element Array{Float64,1}:
 0.3333333333333333
 0.0
 0.3333333333333333
 0.0
 0.0
 0.0
```

From this we can see that variables a and c are possible matches.

## Julia REPL
Alternatively you can interact with the logical problem solver through the `repl` interface. It is initiated by in julia by typing `=` in `julia>` repl.

```julia
abstractlogic>
```

### Setting up a logical set
The interface is much cleaner to work with.

```julia
abstractlogic> a, b, c ∈ 1, 2, 3
a, b, c ∈ 1, 2, 3        feasible outcomes 27 ✓          :1 3 3

abstractlogic> d ∈ 3, 4, 5
d ∈ 3, 4, 5              feasible outcomes 81 ✓          :2 3 3 4

abstractlogic> e,f in red, green, blue
e,f ∈ red, green, blue   feasible outcomes 729 ✓         :2 3 3 4 red red
```

### Constraining the logical set
Writing contraints within the `repl` is equivalent to that of `logicalparse`.

```julia
abstractlogic> a = c
a = c                    feasible outcomes 243 ✓         :3 1 3 3 red blue

abstractlogic> e != f
e != f                   feasible outcomes 162 ✓         :1 1 1 3 blue green
```

We can also force variables to take the value of a constant.

```julia
abstractlogic> f = 'blue'
f = 'blue'               feasible outcomes 54 ✓          :2 3 2 4 red blue
```

### Checking the Feasibility of a Statement
We might often like to check the feasiblility of a claim. This is done with the check command

```julia
abstractlogic> check a=2
Check: a=2 ... a=2                       feasible outcomes 18 ✓          :2 1 2 4 green blue
possible,  18 out of 54 possible combinations 'true'.
```

### Search for a Possible Match
We might instead want to ask the question, which variables could take on a value equal to 3.

```julia
abstractlogic> search ==3

Checking: a ==3
Checking: b ==3
Checking: c ==3
Checking: d ==3
Checking: e ==3
Checking: f ==3

:a is a possible match with 18 feasible combinations out of 54.
:b is a possible match with 18 feasible combinations out of 54.
:c is a possible match with 18 feasible combinations out of 54.
:d is a possible match with 18 feasible combinations out of 54.
:e is a not match with 0 feasible combinations out of 54.
:f is a not match with 0 feasible combinations out of 54.
```
