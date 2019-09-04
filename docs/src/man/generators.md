# Generators

## The Basic Generator (∈/in)

Abstract Logic's primary generator is the generic set declaration generator `∈`. This generator takes variable names to the left separated with commas and assigns them possible values taken from the right separated with commas or specified as a range.

```julia
julia> logicalparse("a, b, c ∈ 1, 2, 3")
a, b, c ∈ 1, 2, 3        feasible outcomes 27 ✓          :3 1 3

julia> logicalparse("a, b, c ∈ 1:3")
a, b, c ∈ 1:3            feasible outcomes 27 ✓          :1 1 1

julia> logicalparse("a, b, c ∈ A,B,C")
a, b, c ∈ A,B,C                  feasible outcomes 27 ✓          :C B A
```

## The Conditional Generator (∈/in | condition)

It is possible to place constraints on your data while it is being generated. This is equivalent in function to running the generator followed by specifying a constraint. However, the generator can be much more efficient it checks the constraint after generating each variable. Outcomes that have already been ruled will not need to be reevaluated as additional variables are generated.

Because the solver is evaluating the condition after each time the variable is run, it is not clear without some math when exactly including a conditional in the generator would be more efficient rather than setting up the conditional after the generator has completed. In the following example using the conditional in the generator is equivalent to running the generator then running then specifying constraint.

```julia
julia> logicalparse("a, b, c, d, e ∈ 1:5 | {{i}} != {{!i}}")
a, b, c, d, e ∈ 1:5 | {{i}} != {{>i}}    feasible outcomes 120 ✓         :3 5 1 2 4
```

Number of outcomes A,B = (5*5) = 25
Number of outcomes A,B,C | A != B = 5*(5*4) = 100
Number of outcomes A,B,C,D | A != B, A != C, B != C = 5*(5*4*3) = 300
Number of outcomes A,B,C,D,E | A != B, A != C, D != D, etc. 5*(5*4*3*2) = 600
Total Number of outcomes to evaluate: 25 + 100 + 300 + 600 = 1025

Equivalent to:
```julia
julia> logicalparse("a, b, c, d, e ∈ 1:5; {{i}} != {{!i}}")

a, b, c, d, e ∈ 1:5      feasible outcomes 3125 ✓        :2 5 2 5 3
{{i}} != {{!i}}
...
>>> e != d
feasible outcomes 120 ✓         :1 2 5 3 4
```

If you generate all of the feasible values straightaway then set the conditional the total number is just equal to number of variables V to the power of the number of possible outcomes N. In this case 5^5.
Total Number of outcomes to evaluate: 3125

> Efficiency wise specifying `{{i}} != {{!i}}` is inferior to specifying `{{i}} != {{>i}}` as the first expression will check `a != b` as well as `b != a` while the second will only check `a != b`.
