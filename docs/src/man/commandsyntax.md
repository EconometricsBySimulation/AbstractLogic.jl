# Command Flow

## Line Break `;`
Including `;` in a command will break the command into two or more separate commands.

## Type of Operators
`logicalparse` takes four types operators. Generators, standard operators, superoperators, and metaoperators.

*Generators*: `∈` and `in` are parse first adding to the `LogicalCombo` set.

*Standard Operators*: Take the form of one or two symbol operators and are often easily identified: `>, <, =, ==, !=` though there are many non-standard operators worth taking a look at.

*Superoperators*: Evaluate the returns from operator expressions and hold three characters `==>, <==, <=>, |||, ===, ^^^` as well as `iff`, `if`, `then`, `and`, `or`, and `xor`

*Metaoperators*: Are made up of four characters `===>, <===, <==>, ||||`

## Order of Operations
For most non-trivial problems order of operations is going to be very important for programming `AbstractReasoning` problems.

*Standard operators* are evaluated first with their values returned first to *superoperators* if they exist and then to *metaoperators*.

Lets take a look at a example set, "a, b, c ∈ 1:3". Let's say we wanted to specify that if a is less than b then c must greater than b ("a < b <=> c > b").
```julia
julia> logicalparse("a, b, c ∈ 1:3; a < b <=> c > b") |> showfeasible
a, b, c ∈ 1:3            feasible outcomes 27 ✓          :2 3 1
11×3 Array{Int64,2}:
 1  1  1
 1  2  3
 2  1  1
...
 3  3  1
 3  3  2
 3  3  3
 ```
 From the array above we can see that when a is less than b, c is greater than b and when a is not less than b, c is not greater than b.

 The above statement uses a *superoperator* the `<=>` which is identical to `===` and `iff`. A *metaoperator* could functionally do the same as a *superoperator* in this case. But more complex conditional assertions might exist.

Lets imagine same scenario as before: (if a is less than b then c must greater than b) then (a must be the same as b and c) "a < b <=> c > b ===> a = b, c".

### Chaining Operators
Operators evaluated at the same level are always evaluated from left to right.

Initializing the repl (`julia> =`).
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              Feasible Outcomes: 27   Perceived Outcomes: 27 ✓        :1 3 3

abstractlogic> true &&& true &&& false ==> false
true &&& true &&& false ==> false        Feasible Outcomes: 27   Perceived Outcomes: 27 ✓        :3 3 3

abstractlogic> true &&& true &&& false ==> false &&& false
true &&& true &&& false ==> false &&& false      Feasible Outcomes: 0    Perceived Outcomes: 0 X          [empty set]

abstractlogic> true &&&& true &&&& false ===> false &&& false
true &&&& true &&&& false ===> false &&& false   Feasible Outcomes: 27   Perceived Outcomes: 27 ✓        :3 2 1

abstractlogic> true &&&& true &&&& false ===> false &&&& false
true &&&& true &&&& false ===> false &&&& false          Feasible Outcomes: 0    Perceived Outcomes: 0 X          [empty set]
```

```julia
julia> logicalparse("a, b, c ∈ 1:3; a < b <=> c > b ===> a = b, c") |> showfeasible
a < b <=> c > b ===> a = b, c    feasible outcomes 19 ✓          :1 2 2
19×3 Array{Int64,2}:
 1  1  1
 1  1  2
 1  1  3
...
 3  1  3
 3  2  3
 3  3  3
 ```
 The results above might be surprising as the *metaoperator* on first glance would seem to introduce more constraints. However, this is not the case. Only in the case `a < b < c` or when this is not true is `a == b == c`.

 It need not be the case that *metaoperators* make the constraints less restrictive. `<==>`, `^^^^`, and `&&&&` all impose joint constraints on both side of the operator.

## A Note On Wildcards
Wildcards `{{i}}` are spawned and evaluated at the level right above *superoperator* but below *metaoperators*. This allows mismatching wildcard functions to be handled on either side of a *metaoperator*. Let's say you only wanted values that either ascended monotonically or descended monotonically. You could do that using `{{i}} < {{<i}}` saying that all values to the right of `i` must be greater or `{{i}} > {{<i}}` saying that all values to the right of `i` must be smaller.

```julia
julia>  myset = logicalparse("a, b, c, d, e ∈ 1:6")
a, b, c, d, e ∈ 1:6      feasible outcomes 7776 ✓        :6 2 6 3 4

julia>  logicalparse("{{i}} < {{<i}} |||| {{i}} > {{<i}}", myset) |> showfeasible
logicalparse("{{i}} < {{<i}} |||| {{i}} > {{<i}}", myset) |> showfeasible
{{i}} < {{<i}} |||| {{i}} > {{<i}}
>>> b < a
>>> c < a
...
>>> e > c
>>> e > d
feasible outcomes 12 ✓          :1 2 3 5 6
12×5 Array{Int64,2}:
1  2  3  4  5
1  2  3  4  6
1  2  3  5  6
...
6  5  4  2  1
6  5  4  3  1
6  5  4  3  2
```
