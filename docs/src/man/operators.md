# Standard Relational Operators

Standard relational operators are the core functionality of the `AbstractLogic` package. They allow for comparison between variables and comparison between variables and constants.

## Basic Operators

* `=` or `==` checks that the left equals the right.
* `!=` (or `≠` not yet implemented) checks that the left does not equal the right.
* `>` checks that the left is greater than the right.
* `>=` checks that the left is greater than or equal to the right.
* `<` checks that the right is greater than the left.
* `<=` checks that the right is greater than or equal to the left.

## Much Greater Than or Much Less Than

* `>>` checks that the left is greater than the right by at least 2 `eg. a >> b`.
* `<<` checks that the right is greater than the left by at least 2 `eg. a << b`.

## Even and Odd Operators

* `&` checks if one or both sides (when two sides are present) is odd. In the case of variables defined 0,1 this asserts that one or more variables is equal to 1. `eg. &a`
* `!` checks if one or both sides (when two sides are present) is even. In the case of variables defined 0,1 this asserts that one or more variables is equal to 0. `eg. !a`
* `^` checks if one side is odd and one side is even. `eg. b ^ a`

## Grouping Syntax

* `,` on the left (or right) is treated as saying that anything on that side must conform to whatever operator follows. `a, b = 1` forces `a` and `b` to equal 1.
* `|` on the left (or right) is treated as saying that at least one value on that side must conform to whatever operator follows. `a | b = 1` forces `a` or `b` or both to equal 1. Note: `a, b |= 1` is equivalent to `a | b = 1` but not preferred.

## Grouping Constraints
* `{#,#}` or `{#}`: it is often helpful to qualify the number of matches `or` syntax can make. Specifying `{#}` at the end of a `|` set will force a certain number of matches. Specifying `{#1,#2}` will force a number of matches no less than `#1` and no more than `#2`.

For example: `a|b|c|d = 1 {3}` will force at exactly three of the set `a`, `b`, `c`, and `d` to equal 1.
```julia
julia> logicalparse("a, b, c, d, e ∈ 1:6; a|b|c|d = 1 {3}")
a, b, c, d, e ∈ 1:6      feasible outcomes 7776 ✓        :2 5 6 6 1
a|b|c|d = 1 {3}                  feasible outcomes 120 ✓         :1 1 4 1 5
```

## Math Operators
`AbstractLogic` can take a number of standard math operators `+`, `-`, `*`, and `/` (or the rounding operator `÷`). 
