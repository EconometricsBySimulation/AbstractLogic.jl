# AbstractLogic.jl
An Abstract Reasoning Logic Interface for Julia.

## Installation

The AbstractLogic package is available through gitbub and can be installed using the following commands after entering the package REPL by typeing `]` in the console.
```julia
pkg> dev https://github.com/EconometricsBySimulation/AbstractLogic.jl
```

Leave the package REPL by hitting `<backspace>`. Now you can use the `AbstractLogic` package anytime by typing `using AbstractLogic` in Julia.

## Documentation
Please review the extensive documentation.

## A Simple Example

A typical kind of problem which one might have encountered in an aptitude test
at some point in ones life might look like the following.

```
Peter is younger than Susan. Sam is younger than Susan but older than Ali.
Li is older than Ali younger than Peter.

Who must be the oldest?
a) Peter b) Susan c) Sam d) Li e) Ali f) Cannot Tell

Who must be the youngest?
a) Peter b) Susan c) Sam d) Li e) Ali f) Cannot Tell

Who could be the same age as Li?
a) Peter b) Susan c) Sam d) Ali e) Nobody f) Cannot Tell
```

The package AbstractLogic provides a tool for easily evaluating such problems.
First lets load in the feasible matches. Because there are 5 people in the
problem we can assign them 5 age categories which represent cardinal ordered
ages rather than
```jldoctest
julia> myls = logicalparse(["Peter, Susan, Sam, Li, Ali ∈ 1, 2, 3, 4, 5"])
Peter, Susan, Sam, Li, Ali ∈ 1, 2, 3, 4, 5       feasible outcomes 3125 ✓        :4 2 4 3 4

julia> myls = logicalparse("Peter < Susan; Sam < Susan", myls)
Peter < Susan            feasible outcomes 1250 ✓        :2 3 3 4 4
Sam < Susan              feasible outcomes 750 ✓         :4 5 4 5 4

myls = logicalparse("Sam > Ali; Li > Ali; Li < Peter", myls)
Sam > Ali                feasible outcomes 175 ✓         :1 3 2 3 1
Li > Ali                 feasible outcomes 121 ✓         :4 5 2 5 1
Li < Peter               feasible outcomes 13 ✓          :4 5 4 3 2

julia> search("{{i}} > {{!i}}", myls)
Checking: Peter > Susan
Checking: Peter > Sam
Checking: Peter > Li
Checking: Peter > Ali
Checking: Susan > Peter
Checking: Susan > Sam
Checking: Susan > Li
Checking: Susan > Ali
Checking: Sam > Peter
Checking: Sam > Susan
Checking: Sam > Li
Checking: Sam > Ali
Checking: Li > Peter
Checking: Li > Susan
Checking: Li > Sam
Checking: Li > Ali
Checking: Ali > Peter
Checking: Ali > Susan
Checking: Ali > Sam
Checking: Ali > Li

:Peter is a not match with 0 feasible combinations out of 13.
:Susan is a match with 13 feasible combinations out of 13.
:Sam is a not match with 0 feasible combinations out of 13.
:Li is a not match with 0 feasible combinations out of 13.
:Ali is a not match with 0 feasible combinations out of 13.
```

## More Interesting Examples

The best way to see the functionality of `AbstractLogic` is to see it in action.

[*Snape's* potions problem in J.K. Rowling's "Harry Potter"](examples/harrypotter.jl)

[June LSAC 2007 by the Law School Admission Council q1-5](examples/LSATlogicalQ1.jl)

[June LSAC 2007 by the Law School Admission Council q6-10](examples/LSATlogicalQ2.jl)

[June LSAC 2007 by the Law School Admission Council q11-17](examples/LSATlogicalQ3.jl)
