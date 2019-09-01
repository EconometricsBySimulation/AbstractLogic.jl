# Generators

## The ∈ (in) Generator

Abstract logic currently only has one generator. This generator takes variable names to the left separated with commas and assigns them possible values taken from the right seperated with commas or specified as a range.

```julia
julia> logicalparse("a, b, c ∈ 1, 2, 3")
a, b, c ∈ 1, 2, 3        feasible outcomes 27 ✓          :3 1 3

julia> logicalparse("a, b, c ∈ 1:3")
a, b, c ∈ 1:3            feasible outcomes 27 ✓          :1 1 1

julia> logicalparse("a, b, c ∈ A,B,C")
a, b, c ∈ A,B,C                  feasible outcomes 27 ✓          :C B A
```
