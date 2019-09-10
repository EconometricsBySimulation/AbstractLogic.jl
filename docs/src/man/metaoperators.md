# Metaoperators

*Metaoperators* allow *AbstractLogic* to the conditional truth of the *superoperators* and *operator* expressions below them. Common type of expressions to be evaluated in this way are if (`===>` or `<===`) and if and only if (`<==>`/`====`) statements. Generally *metaoperators* can be identified by noting that they have four symbols together making up the operator or are strings in UPPERCASE.

When *AbstractLogic* encounters a *metaoperator* it evaluates any expressions on either side of the *metaoperator* before attempting to evaluate the joint *metaoperator*. These expressions are returned as `true` or `false`. Then it follows the rules of the *metaoperators* to evaluate the joint expression.

In many cases using a *metaoperator* will return the exact same results as a *superoperator*, yet when hierarchical evaluation is required *metaoperators* provide a valuable tool.

A Simple example. (Activate the `abstractlogic repl` by typing `=` in console).
```julia
abstractlogic> a ∈ 1
a ∈ 1                    feasible outcomes 1 ✓✓          :1

abstractlogic> true &&& false |||| false ||| true
true &&& false |||| false ||| true       feasible outcomes 1 ✓✓          :1
```
*AbstractLogic* evaluated the command as follows `(true & false) | (false | true)` which became `(false) | (true)` which became `true`.

**Note** *Metaoperators* are less visually appealing when compared with *superoperators* and should be refrained from in favor of *superoperators* when they are available.

## Operators
Notationally `x`, `y`, and `z` will refer to operations composed of at least
one *operator* or *superoperator*.

---
#### `x &&&& y`
Both x and y must be `true`. Command end operator `;` is often preferred to joint evaluators since it is more efficient. In `x ; y` efficiency is gained by evaluating `x` first, reducing the feasible set, then evaluating `y`.
**Note** `x AND y` is an equivalent expression.

###### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
abstractlogic> a > b &&&& b > c
a > b &&&& b > c                  feasible outcomes 1 ✓✓          :3 2 1
```

---
#### `x |||| y`
either x or y must be `true`. If both are `false` then total expression will return false.
**Note** `x OR y` is equivalent

###### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
abstractlogic> a > b |||| b > c
a > b |||| b > c                  feasible outcomes 17 ✓          :2 2 1
```

---
#### `x !=== y`
Either x or y must be `true` but not both. If both are `false` or both are `true` then it will return false.
**Note** `x XOR y` and `x ^^^^ y` are equivalent (`x` and `y` can only be `true` or `false`)

###### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
abstractlogic> a > b !=== b > c
a > b !=== b > c                  feasible outcomes 16 ✓          :3 3 2
```

---
#### `x ==== y`
If `x = true` then `y = true` or if `x = false` then `y = false`.
**Note** `x IFF y` and `x <==> y` are equivalent

###### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
abstractlogic> a > b ==== b > c
a > b ==== b > c                  feasible outcomes 11 ✓          :1 3 3
```

---
#### `x ===> y`
If `x = true` then `y` must be `true`.
**Note** `IF x THEN y` is equivalent

###### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
abstractlogic> a > b ===> b > c
a > b ===> b > c                  feasible outcomes 19 ✓          :3 3 3
```

---
#### `x !==> y`
If `x = false` then `y` must be `true`.

###### Example
```julia
abstractlogic> a,b,c ∈ 1:3; a > b !==> b > c

a,b,c ∈ 1:3              Feasible Outcomes: 27   Perceived Outcomes: 27 ✓        :1 3 3
a > b !==> b > c         Feasible Outcomes: 17   Perceived Outcomes: 27 ✓        :1 3 2
```


---
#### `x <=== y`
If `y = true` then `x` must be `true`.
**Note** `x IF y` is equivalent

###### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
abstractlogic> a > b <=== b > c
a > b <=== b > c                  feasible outcomes 19 ✓          :3 1 1
```


### Chaining Operators
*Metaoperators* can be chained and when evaluated are evaluated from left to right.

**Note** `true` and `false` are replaced dynamically in *AbstractLogic* with `1==1` and `1==0`.

Activate the `abstractlogic repl` by typing `=` in console.
```julia
abstractlogic> a,b ∈ 1,2
a,b ∈ 1,2                feasible outcomes 4 ✓           :2 1

abstractlogic> true
true                     feasible outcomes 4 ✓           :2 1

abstractlogic> false
false                    feasible outcomes 0 X            [empty set]

abstractlogic> back
Last command: "true" - Feasible Outcomes: 4     :1 1

abstractlogic> true |||| false &&&& true
true |||| false &&&& true        feasible outcomes 4 ✓           :1 1

abstractlogic> true !=== false
true !=== false                  feasible outcomes 4 ✓           :2 1

abstractlogic> true !=== false !=== true
true !=== false !=== true        feasible outcomes 0 X            [empty set]
```

**Note** *Wildcards* are spawned on the level below *metaoperators*. This allows multiple sets of *wildcards* to be evaluated separately.
