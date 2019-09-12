# Generators

## The Basic Generator (∈/in)

Abstract Logic's primary generator is the generic set declaration generator `∈`. This generator takes variable names to the left separated with commas and assigns them possible values taken from the right separated with commas or specified as a range.

**Hint** Initiate the repl with `=`.
```julia
abstractlogic> a, b, c ∈ 1, 2, 3 [clear]
Clear Workspace
a, b, c ∈ 1, 2, 3        Feasible Outcomes: 27   Perceived Outcomes: 27 ✓        :3 2 3

abstractlogic> a, b, c ∈ 1:3 [clear]
Clear Workspace
a, b, c ∈ 1:3            Feasible Outcomes: 27   Perceived Outcomes: 27 ✓        :1 2 1

abstractlogic> a, b, c ∈ A1, A2, A3 [clear]
Clear Workspace
a, b, c ∈ A1, A2, A3     Feasible Outcomes: 27   Perceived Outcomes: 27 ✓        :A3 A3 A1
```

## The Conditional Generator (∈/in || condition)

It is possible to place constraints on your data while it is being generated. This is equivalent in function to running the generator followed by specifying a constraint. However, the generator can be much more efficient it checks the constraint after generating each variable. Outcomes that have already been ruled will not need to be reevaluated as additional variables are generated.

Because the solver is evaluating the condition after each time the variable is run, it is not clear without some math when exactly including a conditional in the generator would be more efficient rather than setting up the conditional after the generator has completed. In the following example using the conditional in the generator is equivalent to running the generator then running then specifying constraint.

```julia
abstractlogic> a, b, c, d, e ∈ 1:5 || {{i}} != {{!i}} [clear]
Clear Workspace
a, b, c, d, e ∈ 1:5 || {{i}} != {{!i}}           Feasible Outcomes: 120          Perceived Outcomes: 3125 ✓      :1 2 5 3 4
```

Number of outcomes A, B = (5*5) = 25.
Number of outcomes A, B, C | A != B = 5*(5*4) = 100.
Number of outcomes A, B, C, D | A != B, A != C, B != C = 5*(5*4*3) = 300.
Number of outcomes A, B, C, D, E | A != B, A != C, D != D, etc. 5*(5*4*3*2) = 600.
Total Number of outcomes to evaluate: 25 + 100 + 300 + 600 = 1025.

Equivalent to:
```julia
abstractlogic> a, b, c, d, e ∈ 1:5; {{i}} != {{!i}}
 a, b, c, d, e ∈ 1:5      Feasible Outcomes: 3125         Perceived Outcomes: 3125 ✓      :2 5 4 5 4
{{i}} != {{!i}}
>>> a != b ✔
...
>>> e != d ✔
                 Feasible Outcomes: 120          Perceived Outcomes: 3125 ✓      :4 1 5 2 3
```

If you generate all of the feasible values straightaway then set the conditional the total number is just equal to number of variables V to the power of the number of possible outcomes N. In this case 5^5.
Total Number of outcomes to evaluate: 3125

**Note** Efficiency wise specifying `{{i}} != {{!i}}` is inferior to specifying `{{i}} != {{>i}}` as the first expression will check `a != b` as well as `b != a` while the second will only check `a != b`.

## The Unique Generator (∈/in unique)

The unique generator specifies an alternative `lookup` function for `LogicalCombo`. This `lookup` function generates a matrix in which every item in every row occurs once and only once. These items by default have values `1, 2, ..., n` though they can take alternative values by specifying them on generation.

```julia
abstractlogic> a, b, c, d, e ∈ unique [clear]
Clear Workspace
a, b, c, d, e ∈ unique           Feasible Outcomes: 120          Perceived Outcomes: 3125 ✓      :4 2 5 1 3

abstractlogic> a, b, c, d, e ∈ 0:4 unique [clear]
Clear Workspace
a, b, c, d, e ∈ 0:4 unique       Feasible Outcomes: 120          Perceived Outcomes: 3125 ✓      :1 0 2 4 3

abstractlogic> a, b, c, d, e ∈ A, B, C, D, E unique [clear]
Clear Workspace
a, b, c, d, e ∈ A, B, C, D, E unique     Feasible Outcomes: 120          Perceived Outcomes: 3125 ✓      :C D B A E
```

**Note** Efficiency wise using `unique` is much more efficient if your data takes the form of unique values which are all used in every row. However, if your data has additional values which do not fit this
