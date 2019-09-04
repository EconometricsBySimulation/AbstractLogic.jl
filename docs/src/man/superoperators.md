# Superoperators

Standard operators allow `AbstractLogic` to evaluate multiple expressions simultaneously. Common type of expressions to be evaluated in this way are if (`==>` or `<==`) and if and only if (`<=>`/`===`) statements. Generally `superoperators` can be identified by noting that they have three symbols together making up the operator or are strings in lowercase.

When `AbstractLogic` encounters a superoperate it evaluates any expressions on either side of the superoperator. These expressions are returned as true or false. Then it follows the rules of the superoperator to evaluate the joint expression.

Constraint: `a > b ==> c == a` = x ==> y with x = `a > b` and y = `c == a`

Simple example.
|  row  |  `a`  |  `b`  |  `c`  | x=`a > b` | y=`c == a`| x ==> y   |
| :---: | :---: | :---: | :---: |  :---:    |  :---:    |  :---:    |
|   1   |   2   |   1   |   1   |  `true`   |  `false`  |  `false`  |
|   2   |   2   |   1   |   2   |  `true`   |  `true`   |  `true`   |
|   3   |   2   |   2   |   1   |  `false`  |  `false`  |  `true`   |

A right arrow if constraint (`==>`) only holds if the left side is true. x (`a > b`) is true so y (`c == a`) must also be true. In row 1, x is true but y is not so the total statement returns false. In row 2, x is true and y is true so the total statement returns true. In row 3 the conditional statement x is `false` so the constraint does not bind and the total expression returns true.


## Operators
Notationally `x`, `y`, and `z` will refer to operations composed of at least
one operator.

* `x &&& y` both x and y must be `true`. Command end operator `;` is often preferred to joint evaluators since it is more efficient. In `x ; y` efficiency is gained by evaluating `x` first, reducing the feasible set, then evaluating `y`.
> `x and y` is equivalent

* `x ||| y` either x or y must be `true`. If both are `false` then total expression will return false.
> `x or y` is equivalent

* `x ^^^ y` either x or y must be `true` but not both. If both are `false` or both are `true` then it will return false.
> `x xor y` and `x !== y` is equivalent (`x` and `y` can only be `true` or `false`)

* `x === y` if `x = true` then `y = true` or if `x = false` then `y = false`.
> `x iff y` and `x <=> y` is equivalent

* `x ==> y` if `x = true` then `y` must be `true`.
> `x then y` is equivalent

* `x <== y` if `y = true` then `x` must be `true`.
> `x if y` is equivalent


## Chaining Operators
Superoperators can be chained and when evaluated are evaluated from left to right.

> `true` and `false` are replaced dynamically in `AbstractLogic` with `1=1` and `1==0`.

Activate the `abstractlogic repl` by typing `=` in console.
```julia
abstractlogic> a,b ∈ 1,2
a,b ∈ 1,2                feasible outcomes 4 ✓           :2 1

abstractlogic> true
true                     feasible outcomes 4 ✓           :1 1

abstractlogic> false
false                    feasible outcomes 0 X            [empty set]

abstractlogic> back
Last command: "true ||| false &&& true" - Feasible Outcomes: 4  :1 1

abstractlogic> true ||| false ||| true
true ||| false ||| true          feasible outcomes 4 ✓           :2 2

abstractlogic> true ||| false &&& true
true ||| false &&& true          feasible outcomes 4 ✓           :2 2

abstractlogic> true ^^^ false
true ^^^ false           feasible outcomes 4 ✓           :1 2

abstractlogic> true ^^^ false ^^^ true
true ^^^ false ^^^ true          feasible outcomes 0 X            [empty set]
```

## Wildcards

* `&` checks if one or both sides (when two sides are present) is odd. In the case of variables defined 0,1 this asserts that one or more variables is equal to 1. `eg. &a`
* `!` checks if one or both sides (when two sides are present) is even. In the case of variables defined 0,1 this asserts that one or more variables is equal to 0. `eg. !a`
* `^` checks if one side is odd and one side is even. `eg. b ^ a`
