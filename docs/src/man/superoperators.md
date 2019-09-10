# Superoperators

*Superoperators* allow *AbstractLogic* to evaluate multiple expressions simultaneously. Common type of expressions to be evaluated in this way are `if ... then` (`==>`), `if` (`<==`), and if only if (`iff`/`<=>`/`===`) statements. Generally *superoperators* can be identified by noting that they have three symbols together making up the operator or are strings in lowercase.

When *AbstractLogic* encounters a *superoperator* it evaluates any expressions on either side of the *superoperator*. These expressions are returned as true or false. Then it follows the rules of the *superoperator* to evaluate the joint expression.

Constraint: `a > b ==> c == a` = x ==> y with x = `a > b` and y = `c == a`

A simple example.

|  row  |  `a`  |  `b`  |  `c`  | x=`a > b` | y=`c == a`| x ==> y   |
| :---: | :---: | :---: | :---: |  :---:    |  :---:    |  :---:    |
|   1   |   2   |   1   |   1   |  `true`   |  `false`  |  `false`  |
|   2   |   2   |   1   |   2   |  `true`   |  `true`   |  `true`   |
|   3   |   2   |   2   |   1   |  `false`  |  `false`  |  `true`   |

A right arrow if constraint (`==>`) only holds if the left side is true. x (`a > b`) is true so y (`c == a`) must also be true. In row 1, x is true but y is not so the total statement returns false. In row 2, x is true and y is true so the total statement returns true. In row 3 the conditional statement x is `false` so the constraint does not bind and the total expression returns true.


## Operators
Notationally `x`, `y`, and `z` will refer to operations composed of at least
one operator.

---
#### `x &&& y`
Both x and y must be `true`. Command end operator `;` is often preferred to joint evaluators since it is more efficient. In `x ; y` efficiency is gained by evaluating `x` first, reducing the feasible set, then evaluating `y`.

**Note** `x and y` is equivalent
###### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
abstractlogic> a > b &&& b > c
a > b &&& b > c                  feasible outcomes 1 ✓✓          :3 2 1
```

---
#### `x ||| y`
Either x or y must be `true` but not both. If both are `false` or then total expression will return false.

**Note** `x or y` is equivalent
###### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
abstractlogic> a > b ||| b > c
a > b ||| b > c                  feasible outcomes 17 ✓          :2 2 1
```

---
#### `x !== y`
Either x or y must be `true` but not both. If both are `false` or both are `true` then it will return `false`.

**Note** `x xor y` and `x ^^^ y` is equivalent (`x` and `y` can only be `true` or `false`)
###### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
abstractlogic> a > b ^^^ b > c
a > b ^^^ b > c                  feasible outcomes 16 ✓          :3 3 2
```

---
#### `x === y`
If `x = true` then `y = true` or if `x = false` then `y = false`.

**Note** `x iff y` and `x <=> y` are equivalent
###### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
abstractlogic> a > b === b > c
a > b === b > c                  feasible outcomes 11 ✓          :1 2 2
```

---
#### `x ==> y`
If `x = true` then `y` must be `true`.

**Note** `if x then y` and `x then y` are equivalent
###### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
abstractlogic> a > b ==> b > c
a > b ==> b > c                  feasible outcomes 19 ✓          :3 3 3
```

---
#### `x !=> y`
If `x = false` then `y` must be `true`.

###### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
abstractlogic> a > b !=> b > c
a > b !=> b > c                  Feasible Outcomes: 17   Perceived Outcomes: 27 ✓        :3 2 1
```

---
#### `x <== y`
If `y = true` then `x` must be `true`.

**Note** `x if y` is equivalent
###### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
abstractlogic> a > b <== b > c
a > b <== b > c                  feasible outcomes 19 ✓          :3 1 1
```

### Chaining Operators
*Superoperators* can be chained and when evaluated are evaluated from left to right.

**Note** `true` and `false` are replaced dynamically in *AbstractLogic* with `1==1` and `1==0`.

Activate the `abstractlogic repl` by typing `=` in console.
```julia
abstractlogic> a ∈ 1
a ∈ 1                    feasible outcomes 1 ✓✓          :1

abstractlogic> true
true                     feasible outcomes 1 ✓✓          :1

abstractlogic> false
false                    feasible outcomes 0 X            [empty set]

abstractlogic> back
Last command: "true" - Feasible Outcomes: 1     :1

abstractlogic> true or false
true or false            feasible outcomes 1 ✓✓          :1

abstractlogic> true or false and true
true or false and true   feasible outcomes 1 ✓✓          :1

abstractlogic> true xor false
true xor false           feasible outcomes 1 ✓✓          :1

abstractlogic> true xor false xor true
true xor false xor true          feasible outcomes 0 X            [empty set]
```
The last expression returns an empty set (`false`) because it evaluates from left to right `(true xor false) xor true` which becomes `(true) xor true` which is then evaluated at false.

**Note** Wildcards are spawned on the level right above *superoperators*. See *Wildcards* for more information.
