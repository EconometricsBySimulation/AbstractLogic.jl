---
title: 'AbstractLogic.jl A Julia Package for solving Abstract Logic Problems'
tags:
  - Julia
  - item models
  - item evaluation
  - item generation
  - pychometrics
authors:
  - name: Francis Smart
    orcid: 0000-0003-4308-178X
    affiliation: "1, 2"
affiliations:
 - name: Michigan State University, PhD Candidate
   index: 1
 - name: US Department of Transportation, ORISE Fellow
   index: 2
date: 31 August 2019
bibliography: paper.bib
---

# Summary

``AbstractLogic`` is designed to efficiently evaluate complex logical items
in a flexible and intuitive way. It is a package entirely built in `Julia` with
a high degree of semantic flexibility offering many types of logical operators
for the evaluation of complex expressions.

Logical reasoning items have long been a tool for psychological researchers and practitioners seeking to understand human cognitive capabilities. Yet these
items are difficult to create and even more difficult to evaluate. This package
provides a tool for item writers and reviewers who would like to evaluate quickly
and efficiently if their item is specified correctly and if not how to correct it.

# Automated Item Generators

The motivating purpose of ``AbstractLogic`` package is to provide a tool for
aiding in the development of "automated item generators". Automated item
generators are known to be an effective too for generating numerous items.

It is distinctly different from other packages build around generating items
in that these packages already had solvers predefined, such as in the case for
math items in which the construction of the item implies their solution.

An item generator which have achieved some degree of psychometric success include
MathGen[blum:2018] a tool capable of generating math items. IGOR[Gierl:2012]
also seems to have had some success being marketed as a commercial tool for
use by governments and companies for generating large batches of items using
template design.

# Functionality

``AbstractLogic`` has two modes, `Julia` function mode and `REPL`. Using top
level `Julia` functions, ``AbstractLogic`` is capable of interacting effectively
with other `Julia` functions, collecting matrices of feasible results as or as
need be, being modified by external commands. `LogicalCombo` objects are essentially
only collections of three components, a vector of variable names, a vector of
possible values each variable can possess and a bool of length equal to the
possible product values raised to the power lengths of the.

$$BoolVectorLength = (# of possible values)^{Number of Keys}$$

This efficient method for storing logical combinations allows for complex logical
problems with potentially millions of rows to be efficiently stored and evaluated.
This is an important feature for users interacting with the environment who would
like to be able to rapidly generate numerous permutations of a potential item
with limited space and power.

The custom REPL mode also offers additional functionality, allowing users to work
within a single abstract item framework and analyze the item in a  in rapid and
intuitive manner.

```julia
julia> logicalrepl()
...
AL: a, b, c ∈ 1, 2, 3
a, b, c ∈ 1, 2, 3        feasible outcomes 27 ✓          :1 3 3

AL: a = b
a = b                    feasible outcomes 9 ✓           :2 2 1

AL: c = 1 iff a != c
c = 1 iff a != c         feasible outcomes 4 ✓           :2 2 1

AL: back
Last command: "a = b" - Feasible Outcomes: 9             :3 3 3

AL: a > c
a > c                    feasible outcomes 3 ✓           :3 3 2
```
