# Command Flow
Command flow follows a first in last out functional ruling with standard relational operators are evaluated first, then *superoperators*, then *metaoperators*. When *wildcards* are used, they generate code at the *superoperator* level which is evaluated.

## Line Break `;`
Including `;` in a command will break the command into two or more separate commands.

## Type of Operators
`logicalparse` takes four types operators. Generators, standard operators, superoperators, and metaoperators.

*Generators*: `∈` and `in` are used to create or add to a `LogicalCombo`.
```julia
abstractlogic> a, b, c, d ∈ 0:2 [clear]
Clear Workspace
a, b, c, d ∈ 0:2         Feasible Outcomes: 81   Perceived Outcomes: 81 ✓        :1 0 0 2
```

*Standard Operators*: Take the form of one or two symbol operators and are often easily identified: `>, <, =, ==, !=` though there are many non-standard operators worth taking a look at.

*Superoperators*: Evaluate the returns from operator expressions and hold three characters or lowercase strings `==>, <==, <=>, ===, !==, |||, &&&, ^^^, !=>` as well as `iff`, `if`, `then`, `and`, `or`, and `xor`

*Metaoperators*: Are made up of four characters or UPPERCASE characters `===>, <===, <==>, ====, !===, ||||, &&&&, ^^^^, !==>`

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
The `✓` is shorthand for `abstract logic> check ... [silent]`
calls silent check same
```julia
abstractlogic> a ∈ 1
a ∈ 1                    Feasible Outcomes: 1    Perceived Outcomes: 1 ✓✓        :1

abstractlogic> ✓ true ==> false
false

abstractlogic> ✓ true &&& false ==> false
true

abstractlogic> ✓ true &&& false ==> false &&& false
false
```

Formulating a problem. Let's say we would like a constraint specifies the only time
`a` is less than or equal to `b` or `c`, is when `a`, `b`, and `c` are all equal.
```julia
abstractlogic> a, b, c ∈ 1:3; a <= b ||| a <= c ==> a = b, c [clear]
Clear Workspace

a, b, c ∈ 1:3            Feasible Outcomes: 27   Perceived Outcomes: 27 ✓        :3 3 2
a <= b ||| a <= c ==> a = b, c   Feasible Outcomes: 8    Perceived Outcomes: 27 ✓        :3 2 2

abstractlogic> show
a b c
– – –
1 1 1
2 1 1
2 2 2
3 1 1
3 1 2
3 2 1
3 2 2
3 3 3
```

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
