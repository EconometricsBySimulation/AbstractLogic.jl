# Queries

Queries are the most basic method users have to interact with the logical space. Currently there are four types of queries supported.

## Check Feasible

Asks the logical space if an additional constraint would restrict the logical space and if so by how much.

```julia
julia> checkfeasible(command, logicset, verbose=true, countall=false, countany=false)
```
| Option | Description
| :---: | ---: |
|`verbose` |controls print |
|`countall` | all sets have to be feasible or return 0 |
|`countany`| any set can be non-zero to return 1 |

By default the `checkfeasible` function will check the number of outcomes feasible after the constraint / the number outcomes before the constraint.

If the ratio is 1 then the constraint must be true.
If the ratio is 0 then the constraint must be false.
If the ratio is between 0 and 1 then for some combination of variables values the constraint is viable.

Setting `coutall` to true will force any value less then 1 to be evaluated as false. In practice this is the case when a query if worded "x must be equal to y".
Setting `coutany` to true will force any value any value except 0 to be evaluated as true. In practice this is the case when a query if worded "x could be equal to y".

### REPL equivalents

In the `repl` `checkfeabile` can be called through a few different functions.
```julia
abstractlogic> check x = y
abstractlogic> ✓ x = y
```
Is equivalent to `julia> checkfeasible("x = y", replset)`.

Likewise the option `countall` is called
```julia
abstractlogic> prove x = y
abstractlogic> all x = y
```
Is equivalent to `julia> checkfeasible("x = y", replset, countall=true)`.

While the option `countany` is called
```julia
abstractlogic> any x = y
```
Is equivalent to `julia> checkfeasible("x = y", replset, countany=true)`.

## Search

## Dependence/Independence

## Set comparison
