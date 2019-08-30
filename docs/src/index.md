# AbstractLogic.jl

Welcome to AbstractLogic documentation!

This resource aims at teaching you everything you will need for using
the intuitive Abstract Logic problem solver in the Julia language.

## Introduction

### What is an abstract logic solver?

Abstract logic problems come in many forms. This solver specifically is built
to handle verbal abstract logic problems which have a finite number of possible
permutations. A typical kind of problem which one might have encountered
in an aptitude test at some point in ones life might look like the following.

#### Simple Example

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
From this we can see that Susan is the oldest.

`Who must be is the youngest?`
To check who is the youngest we can do the same but this time setting
`verbose=false` to reduce the printing.
```jldoctest
julia> search("{{i}} < {{!i}}", myls, verbose=false)
5-element Array{Float64,1}:
 0.0
 0.0
 0.0
 0.0
 1.0
 ```
The search function returns a ratio of feasible outcomes for each column
relative to total outcomes. A zero means no feasible combination exist that
match while a 1 indicates a 100% match.

`Who could be the same age as Li?`
```jldoctest
julia> search("{{i}} = Li", myls)
Checking: Peter = Li
Checking: Susan = Li
Checking: Sam = Li
Checking: Li = Li
Checking: Ali = Li

:Peter is a not match with 0 feasible combinations out of 13.
:Susan is a not match with 0 feasible combinations out of 13.
:Sam is a possible match with 5 feasible combinations out of 13.
:Li is a match with 13 feasible combinations out of 13.
:Ali is a not match with 0 feasible combinations out of 13.
 ```
From the results we can see that Sam could share ages with Li.
