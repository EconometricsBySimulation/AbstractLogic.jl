# Getting Started

## Installation

The AbstractLogic package is available through gitbub and can be installed using the following commands after entering the package REPL by typeing `]` in the console.
```julia
dev https://github.com/EconometricsBySimulation/AbstractLogic.jl
```

Leave the package REPL by hitting `<backspace>`. Now you can use the `AbstractLogic` package anytime by typing `using AbstractLogic` in Julia.

## Interacting with AbstractLogic
There are two basic methods of interacting with the solver: `logicalparse` and `logicalrepl`. `logicalparse` is generally preferred when programmatically interacting with the solver while `logicalrepl` is convenient when interacting with the solver less formally.

### logicalparse
One method is using
`Julia` functions mainly `logicalparse`, `checkfeasible`, and `search`. This method relies primarily on `LogicalCombo` objects which are generated from and can be passed into `logicalparse`.

To set up an initial logical set. Pass a text command to logicalparse with the variable names on the left and range of possible values on the left with the ∈ or `in` operator in between.
```julia
julia> logicalset = logicalparse("a, b, c ∈ 1, 2, 3")
a, b, c ∈ 1, 2, 3        feasible outcomes 27 ✓          :3 1 3
```
`logicalparse` will now generate a lookup object of type `LogicalCombo` which tells `AbstractLogic` options what combinations feasible as well as which ones have been excluded. Every time `logicalparse` runs it prints the number of feasible outcomes in the set given the current constraints as well as a random single feasible value that the variables can hold.

While many logical problems do have equivalent value ranges for each variable `AbstractLogic` has no such constraint. Additional variables can be added to a set in an equivalent as those added upon set initiation.
```julia
julia> logicalset = logicalparse("d ∈ 4,5", logicalset)
d ∈ 4,5                          feasible outcomes 54 ✓          :2 1 1 5
```
Variable values need not be of the same type.
```julia
julia> logicalset = logicalparse("bob, ali ∈ old, young", logicalset)
bob, ali ∈ old, young    feasible outcomes 216 ✓         :3 2 3 5 young old
```
