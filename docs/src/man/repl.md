# REPL mode

`AbstractLogic` provides a REPL mode (thanks to `ReplMaker.jl`) for interacting with the parser. It is initiated by typing `=` in the `julia` console. Relp mode is an efficient method for rapidly evaluating problem sets as it is syntactically more concise.

The `REPL` can be interacted with programmatically by calling the function `abstractlogic("command"; returnactive = false)`. Setting `returnactive=true` will return the most recent active LogicalCombo.

```julia
julia> abstractlogic("clear")
Clear Workspace

julia> abstractlogic("a, b, c ∈ 1:3")
a, b, c ∈ 1:3        feasible outcomes 27 ✓      :2 2 3

julia> myset = abstractlogic("a = b|c", returnactive = true)
a = b|c              feasible outcomes 15 ✓      :1 1 2

julia> showfeasible(myset)
15×3 Array{Int64,2}:
 1  1  1
 1  1  2
 ⋮      
 3  3  3
```

### Basic REPL Interactivity
The `repl` by default will take any command that the parser will take and sent it to the `logicalparser` for evaluation. The primary difference is that `logicalparser` will return a `LogicalCombo` to user while the `repl` will keep it in active memory to be automatically referenced by future commands.
##### Example
```julia
abstractlogic> a, b, c ∈ 1:3; a = b|c

a, b, c ∈ 1:3        feasible outcomes 27 ✓      :2 3 3
a = b|c              feasible outcomes 15 ✓      :2 2 2
```

## REPL Commands
Most commands should be entered directly in the REPL mode after the prompt and are executed with an enter at the end of the line.

---
#### ?... help...
Returns documentation related to a function or command to the user.
**NOTE** `julia> help(...)` returns identical information.
```julia
abstractlogic> ? >
  Operator: >

  a > b : a is greater than b
```

---
#### back b
Go back one command. Command `next` or `n` reverses back.

---
#### check...
Go back one command
check feasibility of subsequent command
```julia
### Example
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :2 3 3

abstractlogic> a > b ; b > c

a > b                    feasible outcomes 9 ✓           :3 2 3
b > c                    feasible outcomes 1 ✓✓          :3 2 1

abstractlogic> check a == 3
Check: a == 3 ... a == 3                         feasible outcomes 1 ✓✓          :3 2 1
true, 1 out of 1 possible combinations 'true'.
```
---
#### clear [clear]
Empty the current variable space.
**Note** Specifying the option `[clear]` in any part of a `REPL` command will call the clear function before processing the rest of the command.
```julia
abstractlogic> a, b, c ∈ 1:3 [clear]
Clear Workspace
a, b, c ∈ 1:3            Feasible Outcomes: 27   Perceived Outcomes: 27 ✓        :1 2 1
```

---
#### clearall
Empty the current as well as the history set space.
**Warning** This cannot be undone!

---
#### dashboard dash
Toggles the dashboard printout - primarily used for debugging.

---
#### discover d
Search `Main` for any `LogicalCombos`.
**See Also** `import` to bring `LogicalCombo` from `Main` and `export` to send `LogicalCombo` to `Main`

---
#### export
send `LogicalCombo` to `Main`
**See Also** `discover` to search `Main` for any `LogicalCombos` and `import` to  bring `LogicalCombo` from `Main`.

---
#### history h
"Show command history with # feasible."

---
#### import
bring `LogicalCombo` from `Main`
**See Also** `discover` to search `Main` for any `LogicalCombos` and `export` to send `LogicalCombo` to `Main`

---
#### keys
List variables names.

---
#### logicset ls
Show all logical sets currently in working REPL memmory.

Exiting the REPL:
`julia> returnactivelogicset()` returns the most recent set
`julia> returnlogicset()` returns a vector of all sets worked on int REPL

---
#### next
Go forward one command. Only works if you have gone back first.

---
#### preserve
Save the current variable space for use with `restore`.

---
#### restore
Restore the last saved variable space.


---
#### search
Search for the feasibility of {{i}} match
##### Example
```julia
abstractlogic> a,b,c ∈ 1:3
a,b,c ∈ 1:3              feasible outcomes 27 ✓          :2 3 3

abstractlogic> a > b ; b > c

a > b                    feasible outcomes 9 ✓           :3 2 3
b > c                    feasible outcomes 1 ✓✓          :3 2 1

abstractlogic> search == 3

Checking: a == 3
Checking: b == 3
Checking: c == 3

:a is a match with 1 feasible combinations out of 1.
:b is a not match with 0 feasible combinations out of 1.
:c is a not match with 0 feasible combinations out of 1.
```
---
#### show s
Print a table of 10 feasible results (head and tail)

---
#### showall
Print a table of all feasible results.
