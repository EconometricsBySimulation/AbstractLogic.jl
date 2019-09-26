"""
    search(command::String, logicset::LogicalCombo; verbose=true)

Searches for a possible match among a LogicalCombo in which the wildcard term
is true. Search requires the use of a wildcard. In the event that a wildcard
is missing, search will insert a {{i}} to the left of the command.*{{i+1}}* can
be used to search for relationships between the ith column and another
column.

### Examples
```julia
julia> myset = logicalparse("v1, v2, v3 ∈ 1:10")
v1, v2, v3 ∈ 1:10        feasible outcomes 1000 ✓        :6 6 10

julia> myset = logicalparse("{{i}} >> {{i+1}}", myset)
{{i}} >> {{i+1}}
>>> v1 >> v2
>>> v2 >> v3
         feasible outcomes 56 ✓          :10 7 3

julia> search("{{i}} == 4", myset)
Checking: v1 == 4
Checking: v2 == 4
Checking: v3 == 4

:v1 is a not match with 0 feasible combinations out of 56.
:v2 is a possible match with 10 feasible combinations out of 56.
:v3 is a possible match with 6 feasible combinations out of 56.

julia> search("== 4", myset, verbose=false) == search("{{i}} == 4", myset, verbose=false)
true

julia> search("{{i}} > {{!i}}", myset)
Checking: v1 > v2
Checking: v1 > v3
Checking: v2 > v1
Checking: v2 > v3
Checking: v3 > v1
Checking: v3 > v2

:v1 is a match with 56 feasible combinations out of 56.
:v2 is a not match with 0 feasible combinations out of 56.
:v3 is a not match with 0 feasible combinations out of 56.
```
"""
function search(command::String, logicset::LogicalCombo; verbose=true)

    clearcounter()

    rowsin = nfeasible(logicset)

    if rowsin == 0
        println("No outcomes feasible outcomes with set!")
        return missing
    end

    !occursin(raw"{{", command) &&
      !occursin(r"^[><=|!^&]", command) &&
      throw("No syntax match. Enter form '{{i}} = ...' or '= ...'")

    !occursin(raw"{{", command) &&
      occursin(r"^[><=|!^&]", command) &&
      (command = "{{i}} " * command)

    colcheck = operatorspawn(command,
      logicset,
      returnlogical=true,
      prefix="Checking: ",
      verbose=verbose)

    colcount = Any[]

    for i in 1:size(logicset, 2)
      select = colcheck[1][:, colcheck[2] .== logicset.keys[i]]
      (size(select,2) == 0) && push!(colcount, missing)
      (size(select,2) > 0 ) && push!(colcount, [all(select[j,:]) for j in 1:size(select,1)] |> sum)
    end

    # colcount = [sum(colcheck[:,i]) for i in 1:size(colcheck,2)]

    if verbose
        println()
        for i in 1:size(logicset,2)
          if colcount[i] === missing
              println(":$(logicset.keys[i]) could not be evaluated at $command.")
              continue
          end
          (colcount[i] == rowsin) && print(":$(logicset.keys[i]) is a match")
          (colcount[i] == 0) && print(":$(logicset.keys[i]) is a not match")
          (colcount[i] > 0) && (colcount[i] < rowsin) &&
            print(":$(logicset.keys[i]) is a possible match")
          println(" with $(colcount[i]) feasible combinations out of $rowsin.")
        end
    end

    return colcount ./ rowsin
end
