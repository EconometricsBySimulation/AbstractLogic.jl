"""
    showfeasible

Collects a matrix of only feasible outcomes given the parameter space and the
constraints. Use `collect` to output a matrix of all possible matches for
parameter space.

### Examples
```julia
julia> myset = logicalparse("a, b, c in 1:3")
a,b,c in 1:3             feasible outcomes 27 ✓          :3 3 3

julia> myset = logicalparse("a == b; c > b", myset)
a == b                   feasible outcomes 9 ✓           :1 1 3
c > b                    feasible outcomes 3 ✓           :2 2 3

julia> showfeasible(myset)
3×3 Array{Int64,2}:
 1  1  2
 1  1  3
 2  2  3
```
"""
showfeasible(x::LogicalCombo) = x[:,:,:]
