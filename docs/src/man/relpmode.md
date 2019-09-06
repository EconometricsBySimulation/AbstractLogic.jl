# REPL mode

`AbstractLogic` provides a REPL mode (thanks to `ReplMaker.jl`) for interacting with the parser. It is initiated by typing `=` in the `julia` console. Relp mode is an efficient method for rapidly evaluating problem sets as it is syntactically more concise.

The `REPL` can be interacted with programmatically by calling the function `abstractlogicrepl("command"; returnactive = false)`. Setting `returnactive=true` will return the most recent active LogicalCombo.

```julia
julia> abstractlogicrepl("clear")
Clear Workspace

julia> abstractlogicrepl("a, b, c ∈ 1:3")
a, b, c ∈ 1:3        feasible outcomes 27 ✓      :2 2 3

julia> myset = abstractlogicrepl("a = b|c", returnactive = true)
a = b|c              feasible outcomes 15 ✓      :1 1 2

julia> showfeasible(myset)
15×3 Array{Int64,2}:
 1  1  1
 1  1  2
 ⋮      
 3  3  3
```
