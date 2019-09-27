[![Build Status](https://travis-ci.org/EconometricsBySimulation/AbstractLogic.jl.svg?branch=master)](https://travis-ci.org/EconometricsBySimulation/AbstractLogic.jl)
[![Coverage Status](https://coveralls.io/repos/github/EconometricsBySimulation/AbstractLogic.jl/badge.svg?branch=master)](https://coveralls.io/github/EconometricsBySimulation/AbstractLogic.jl?branch=master)

# AbstractLogic.jl
An Abstract Reasoning Logic Interface for Julia.

## Installation

The AbstractLogic package is available through gitbub and can be installed using the following commands after entering the package REPL by typing `]` in the console.
```julia
pkg> add AbstractLogic
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
ages.

```julia
julia> using AbstractLogic
Start the repl in command prompt by typing `=`.

abstractlogic> Peter, Susan, Sam, Li, Ali ∈ 1, 2, 3, 4, 5
Peter, Susan, Sam, Li, Ali ∈ 1, 2, 3, 4, 5       feasible outcomes 3125 ✓        :4 2 4 3 4

abstractlogic> Peter < Susan; Sam < Susan
Peter < Susan            feasible outcomes 1250 ✓        :2 3 3 4 4
Sam < Susan              feasible outcomes 750 ✓         :4 5 4 5 4

abstractlogic> Sam > Ali; Li > Ali; Li < Peter
Sam > Ali                feasible outcomes 175 ✓         :1 3 2 3 1
Li > Ali                 feasible outcomes 121 ✓         :4 5 2 5 1
Li < Peter               feasible outcomes 13 ✓          :4 5 4 3 2

abstractlogic> search {{i}} > {{!i}}
Checking: Peter > Susan
Checking: Peter > Sam
...
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

[*Snape's* potions problem in J.K. Rowling's "Harry Potter"](examples/repl/harrypotter.jl)

[June LSAC 2007 by the Law School Admission Council q1-5](examples/repl/LSATlogicalQ1.jl)

[June LSAC 2007 by the Law School Admission Council q6-10](examples/repl/LSATlogicalQ2.jl)

[June LSAC 2007 by the Law School Admission Council q11-17](examples/repl/LSATlogicalQ3.jl)
