
"""
    checkfeasible(command::String, logicset::LogicalCombo; verbose=true, all=false, countany=false)

Is called when the user would like to check if a command produces a valid result,
possible result, or invalid result. The result is returned as a decimal from 0.0
to 1.0. With 0.0 being no matches and 1.0 being all matches.

### Arguments
* `verbose` : controls print
* `countall` : all sets have to be feasible or return 0
* `countany` : any set can be non-zero to return 1

### Examples
```julia
julia> myset = logicalparse("a, b, c ∈ red, blue, green")
a, b, c ∈ red, blue, green       feasible outcomes 27 ✓          :red blue blue

julia> myset = logicalparse("a != b,c; b = c ==> a = 'blue'", myset)
a != b,c                 feasible outcomes 12 ✓          :green blue blue
b = c ==> a = 'blue'     feasible outcomes 8 ✓           :blue green green

julia> checkfeasible("a = 'green' ==> b = 'red'", myset)
Check: a = 'green' ==> b = 'red' ... a = 'green' ==> b = 'red'   feasible outcomes 17 ✓          :blue red green
possible,  17 out of 21 possible combinations 'true'.
```
"""
function checkfeasible(command::String,
    logicset::LogicalCombo = LogicalCombo();
    verbose=true, countall=false, countany=false)

  clearcounter()

  countany && countall && throw("Both any and all can't be set to true")

  rowsin = sum(logicset.logical)

  if rowsin == 0
      println("No outcomes feasible outcomes with set!")
      return missing
  end

  verbose && !countall && !countany && print("check: $command ... ")
  verbose && countall && print("all: $command ... ")
  verbose && countany && print("any: $command ... ")

  logicsetout = logicalparse(command, logicset=logicset, verbose=verbose)

  rowsout = sum(logicsetout.logical)
  outcomeratio = rowsout/rowsin

  if countall
        outcomeratio != 1 && print("false")
        outcomeratio == 1 && print("true")
  elseif countany
        outcomeratio == 0 && print("false")
        outcomeratio != 0 && print("true")
  else
      outcomeratio == 1 && print("true")
      outcomeratio == 0 && print("false")
      (1 > outcomeratio > 0) && print("possible")
  end

  verbose && println(", $rowsout out of $rowsin possible combinations 'true'.")

  return [outcomeratio, logicsetout]
end
