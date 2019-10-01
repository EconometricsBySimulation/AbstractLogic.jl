"""
    nfeasible(x::LogicalCombo; feasible=true)

    Returns a count of the number of feasible outcomes in x.

* feasible:

#### Example
```
julia> nfeasible(logicalparse("a,b in 1:3; a!=b", verbose = false))
6
julia> nfeasible(logicalparse("a,b in 1:3; a!=b", verbose = false), feasible=false)
3
```
"""
nfeasible(x::LogicalCombo; feasible::Bool=true) =
  (feasible ? sum(x.logical) : size(x,1) - sum(x.logical))

nfeasible(x::LogicalCombo, feasible::Bool) = nfeasible(x::LogicalCombo; feasible=feasible)

variablerange(x::LogicalCombo; feasible=true) = [unique(x[:,i,feasible]) for i in 1:size(x,2)]

"""
    percievedfeasible(x::LogicalCombo)

    Returns a count of the number of feasible outcomes that could be infered if
    one were just looking at the number of possible values each variable can take.

* feasible:

#### Example
```
julia> percievedfeasible(logicalparse("a,b in 1:3; a=b", verbose = false))
9
julia> percievedfeasible(logicalparse("a,b in 1:3; a=1", verbose = false))
3
```
"""
percievedfeasible(x::LogicalCombo) = prod(length.(variablerange(x)))
