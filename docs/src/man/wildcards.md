# Wildcards

Wildcards allow for constraints which are uniformly applied across variables or sets of variables to be efficiently expressed. Uniform constraints are very common in abstract reasoning problems.

One constraint is that each variable must take on a different values from each other variable. This is expressed typically as `{{i}} != {{!i}}` or more efficiently `{{i}} != {{>i}}`.

The placeholder variable `i` represents all variable names while `!i` represents for any given `i` all variables not named `i`. What *AbstractLogic* does when it encounters wildcards is loop through possible matches *spawning* new constraints based on the wildcards present in the current constraint.

##### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :2 1 1

abstractlogic> {{i}} > {{<i}}
{{i}} > {{<i}}
>>> b > a
>>> c > a
>>> c > b
                 feasible outcomes 1 ✓✓          :1 2 3
```

In the above example we can see that three constraints were spawned from the input `{{i}} > {{<i}}`. This is because `i` is first given the variable name `a` but the right hand side takes value `<i` which means in terms of the variable set this term can take any values to the left of `i` which is this case is no values. So `a` is skipped for the `i` value. Next `i` is set to `b`. `b` only has one variable to the left `a`. This is evaluated. Next we look at `c` which has both `a` and `b` to the left which are evaluated. Finally the parser combined the joint feasibility of the three generated constraints and only keeps values in which all three are true. In this case, `a=1, b=2, c=3`.

## `i` Reference Wildcards

* `{{i}}` the most basic wildcard reference is `{{i}}`. It can take any variable name from the set of variables so far defined.
#### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
abstractlogic> {{i}} == 1
{{i}} == 1
>>> a == 1
>>> b == 1
>>> c == 1
                 feasible outcomes 1 ✓✓          :1 1 1
```

* `{{!i}}` any variable not `i`.
**NOTE** In general `!i` is not that helpful as there are few operations which `!i` does not return an empty set. And those cases in which it doesn't seem to be more efficiently expressed as `>i` or `<i`.
#### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
abstractlogic> {{i}} == {{!i}}
{{i}} == {{!i}}
>>> a == b
>>> a == c
>>> b == a
>>> b == c
>>> c == a
>>> c == b
                 feasible outcomes 3 ✓           :3 3 3
```

* `{{>i}}` any variable to the right of wildcard `i`.
#### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
abstractlogic> {{i}} == {{>i}}
{{i}} == {{<i}}
>>> b == a
>>> c == a
>>> c == b
                 feasible outcomes 3 ✓           :3 3 3
```

* `{{<i}}` any variable to the left of `i`.
#### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
abstractlogic> {{i}} == {{<i}}
{{i}} == {{<i}}
>>> b == a
>>> c == a
>>> c == b
                 feasible outcomes 3 ✓           :3 3 3
```

* `{{<<i}}` any variable at least two to the left of `i`.
#### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
abstractlogic> {{i}} == {{<<i}}
{{i}} == {{<<i}}
>>> c == a
         feasible outcomes 9 ✓           :3 1 3
```

* `{{>>i}}` any variable at least two to the right of `i`.
#### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
abstractlogic> {{i}} == {{>>i}}
{{i}} == {{>>i}}
>>> a == c
         feasible outcomes 9 ✓           :2 1 2
```

## `i` Modifiers - Index Modifiers

* `{{i+n}}`, `{{i-n}}` takes n steps right `+` or left `-` of `i`.
#### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
abstractlogic> {{i}} != {{i+1}}
{{i}} != {{i+1}}
>>> a != b
>>> b != c
         feasible outcomes 12 ✓          :1 2 1
```

* `{{i+n!}}`, `{{i-n!}}` forces n steps right `+` or left `-` of `i`. If that step cannot be taken the variable is replaced by `999` which with numeric comparisons this will have different effects.
#### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
abstractlogic> {{i}} = 1 ==> {{i+1!}} = 2
{{i}} = 1 ==> {{i+1!}} = 2
>>> a = 1 ==> b = 2
>>> b = 1 ==> c = 2
>>> c = 1 ==> 999 = 2
         feasible outcomes 12 ✓          :1 2 3
```

## Variable Reference Wildcards


## Constraints

* `{{N}}` evaluates every permutation given the wildcard set and evaluates the entire expression as `true` only if the number of values across wildcards is equal to `N`.
**Note** `{{N}}` must appear at the end of the *superoperator* expression.
#### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
abstractlogic> {{i}} = 2 {{2}}
{{i}} = 2 {{2}}
>>> a = 2
>>> b = 2
>>> c = 2
                 feasible outcomes 6 ✓           :2 2 3
```
Forces at least two variables from `a`, `b`, and `c` to equal `2`.

* `{{n1,n2}}` evaluates every permutation given the wildcard set and evaluates the entire expression as `true` only if the number of values across wildcards is at least `n1` and no more than `n2`. If `n1` is empty then it is set to zero. If `n2` is empty it is set to a large number.
**Note** `{{n1,n2}}` must appear at the end of the *superoperator* expression.
**Hint** `{{,n2}}` can be read as "at most" while `{{n1,}}` can be read "at least".
#### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :1 1 3
abstractlogic> {{i}} = 3 {{1,2}}
{{i}} = 3 {{1,2}}
>>> a = 3
>>> b = 3
>>> c = 3
         feasible outcomes 18 ✓          :2 3 3
```
Forces at least one or two of the variables to equal `3`.

## Attributes (j)

Variables attributes can be specified as `varname.attribute` and are treated as a variable except that attributes can be ignored by alternative wildcard `j`.

* `{{j}}` `j` is exactly the same as `i` except that it ignores the parts of variable names that come after `.`s. So `a.1` just becomes `a` in the substitution mechanism.
#### Example
```julia
abstractlogic> a.1,a.2 ,b.1 ,b.2, c.1, c.2  ∈ 1:3
a.1,a.2 ,b.1 ,b.2, c.1, c.2  ∈ 1:3       feasible outcomes 729 ✓         :2 3 3 2 3 1
abstractlogic> {{j}}.1 < {{j}}.2
{{j}}.1 < {{j}}.2
>>> a.1 < a.2
>>> b.1 < b.2
>>> c.1 < c.2
         feasible outcomes 27 ✓          :1 2 1 2 1 3

abstractlogic> back
Last command: "a.1,a.2 ,b.1 ,b.2, c.1, c.2  ∈ 1:3" - Feasible Outcomes: 729     :1 3 2 1 2 3

abstractlogic> {{j}}.1 == {{j+1}}.2
{{j}}.1 == {{j+1}}.2
>>> a.1 == b.2
>>> b.1 == c.2
         feasible outcomes 81 ✓          :3 1 1 3 1 1
```
