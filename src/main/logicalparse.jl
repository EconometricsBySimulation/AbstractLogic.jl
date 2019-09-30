
# Global set variables logicset, Υ hold
integer(x::AbstractString) = parse(Int, strip(x))
Base.range(x::AbstractString) = range(integer(match(r"^[0-9]+", x).match),
                               stop = integer(match(r"[0-9]+$", x).match))
# logicaloccursin(y::Symbol) = any( [ y ∈ keys(logicset[i]) for i in 1:length(logicset) ] )
# logicaloccursin(x::LogicalCombo, y::Symbol) = y ∈ keys(x)

"""
    logicalparse

Takes a command and parses it into logical calls that either assigning
additional feasible variable ranges or constrain the relationship between
variables.

```julia
logicalparse(command::String; logicset::LogicalCombo = LogicalCombo(), verbose=true)
logicalparse(command::String, logicset::LogicalCombo; ...)
logicalparse(commands::Array{String,1}, logicset::LogicalCombo; ...)
logicalparse(commands::Array{String,1}; ...)
```
### Arguments
* `verbose` : specifies to print to screen or not

### Operators
There are numerous operators available to be used in the logical parse command.

### Examples
```julia
julia> myset = logicalparse("a, b, c in 1:3")
a,b,c in 1:3             feasible outcomes 27 ✓          :3 3 3

julia> myset = logicalparse("a == b", myset)
a == b                   feasible outcomes 9 ✓           :1 1 2

julia> myset = logicalparse("a > c", myset)
a > c                    feasible outcomes 3 ✓           :3 3 1

julia> myset = logicalparse("c != 1", myset)
c != 1                   feasible outcomes 1 ✓✓          :3 3 2
```
"""
function logicalparse(
    commands::Array{String,1};
    logicset::LogicalCombo = LogicalCombo(),
    verbose=true)

  clearcounter()

  verbose && println("")

  any(occursin.(";", commands)) &&
    (commands = split.(commands, ";") |> Iterators.flatten |> collect .|> strip .|> string)

  for command in commands
      logicset = logicalparse(command, logicset=logicset, verbose=verbose)
  end
  logicset
end

function logicalparse(
    command::String;
    logicset::LogicalCombo = LogicalCombo(),
    verbose=true)

    clearcounter()

    # A vector of non-standard operators to ignore
    generators = "in"
    superset = "xor|iff|if|then|notthen"
    metaset = "XOR|IFF|IF|THEN|AND|OR"

    exclusions = join([generators, superset, metaset],"|")

    occursin(";", command) &&
      return logicalparse(string.(strip.(split(command, ";"))),
        logicset=logicset, verbose=verbose)

    verbose && print(command)
    # verbose && println("\n" * join(logicset.commands), "\n")

    (strip(command) == "" || command[1] == '#') && return logicset |>
      (x -> (((strip(command) != "") && push!(x.commands, command)); return x))

    occursin(r"∈|\bin\b", command) &&
      return definelogicalset(logicset, command) |>
        reportfeasible(command, verbose)  |>
        (x -> (push!(x.commands, command); return x))

    # Check for the existance of any symbols in logicset
    varcheck = eachmatch(r"[a-zA-Z][0-9a-zA-Z_.]*", command)

    # Replace command
    commandout = command |>
     x -> replace(x, r"(\b|\s)true(\b|\s)" =>" 1 = 1 ") |>
     x -> replace(x, r"(\b|\s)false(\b|\s)"=>" 1 = 0 ") |>
     x -> replace(x, r"^(IF|if|If)"=>"")

    if occursin(Regex("([><=|!+\\-^&]{1,4})"), commandout)
      return metaoperator(commandout, logicset, verbose = verbose) |>
        reportfeasible(command, verbose) |>
        (x -> (push!(x.commands, command); return x))
    end

    println("\t Warning! { $command } not interpreted!")
end

logicalparse(commands::Array{String,1}, logicset::LogicalCombo; I...) =
  logicalparse(commands, logicset=logicset, I...)

logicalparse(command::String, logicset::LogicalCombo; I...) =
  logicalparse(command, logicset=logicset, I...)
