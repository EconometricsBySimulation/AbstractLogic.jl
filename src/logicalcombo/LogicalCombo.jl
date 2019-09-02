"""
    LogicalCombo <: Any

A LogicalCombo stores the variable names, domains, as well as an binary
representation of feasible values given constraints.

**Fields**

*keys : Stores the names of variables.
*domain : Stores the range of possible matches variables can have.
*logical : A binary vector marking feasibility of length equal to every
    possible combination of value which the matrix could take on.
*commandlist : An array collection of the strings input to generate the current
    state of the the object.

**Indexing**

* [x,y] Where x is numeric or : and y is numeric, colon, or symbol will
    return matrix point values regardless of feasibility.
* [:,:] Will collect the entire possible domain and is the same as `collect()`.
* [x,0] Will return the logical vector values
* [x,y,true] Will return the xth feasible value of the
"""
struct LogicalCombo
  keys::Array{Symbol}
  domain::AbstractArray
  logical::Array{Bool}
  commands::Array{String}
end

LogicalCombo(keys, domain, logical) = LogicalCombo(keys, domain, logical, String[])

LogicalCombo() = LogicalCombo(Symbol[],[], Bool[])

function LogicalCombo(; kwargs...)
    if isempty(kwargs)
        return LogicalCombo(Symbol[],[], Bool[])
    else
        keys = []; domain = []
        for (kw, val) in kwargs;
            push!(keys, kw)
            push!(domain, val)
        end
    end
    LogicalCombo(keys, domain, fill(true,*(length.(domain)...)))
end

function LogicalCombo(x::Union{AbstractArray{Pair{Symbol, Any}}, Array{Pair{Symbol,UnitRange{Int64}},1}})
    if length(x) == 0
        return LogicalCombo(Symbol[],[], Bool[0])
    else
        mykeys = []; mydomain = []
        for (kw, val) in x;
            push!(mykeys, kw)
            push!(mydomain, val)
        end
    end
    LogicalCombo(mykeys, mydomain, fill(true,*(length.(mydomain)...)))
end

function expand(x::LogicalCombo, mykeys::Union{Array{String},Array{String,1}}, myvalues::Union{Array{Any},Array{Int},Array{String,1}})
  isempty(mykeys) && return x

  keyset = map(x->Symbol(x), mykeys)
  mydomain = [myvalues for i in 1:length(mykeys)]

  (size(x)[2]==0) && return LogicalCombo(keyset, mydomain, fill(true,*(length.(mydomain)...)))

  foreach(y -> (y ∈ x.keys) && throw("key :$y already defined!") , keyset)

  expander = *(length.(mydomain)...)
  outlogical = fill(x.logical, each = expander)

  LogicalCombo([x.keys..., keyset...], [x.domain..., mydomain...], outlogical)
end

function expand(x::LogicalCombo; kwargs...)
  if isempty(kwargs)
    return x
  elseif size(x)[2]==0
    return LogicalCombo([kwargs...])
  else
    mykeys = []; mydomain = []
    for (kw, val) in kwargs;
        push!(mykeys, kw)
        push!(mydomain, val)
    end
  end

  foreach(y -> (y ∈ x.keys) && throw("key :$y already defined!") , mykeys)

  expander = *(length.(mydomain)...)
  outlogical = fill(x.logical, each = expander)

  LogicalCombo([x.keys..., mykeys...], [x.domain..., mydomain...], outlogical)
end

function expand(logicset::LogicalCombo, x::Union{Array{Pair{Symbol, Any}}, Array{Pair{Symbol,UnitRange{Int64}},1}})

    (length(logicset.keys) == 0) && return LogicalCombo(x)
    (length(x) == 0) && return logicset

    mykeys = []; mydomain = []
    for (kw, val) in x;
        push!(mykeys, kw)
        push!(mydomain, val)
    end

  foreach(y -> (y ∈ logicset.keys) && throw("key :$y already defined!"), mykeys)

  expander = *(length.(mydomain)...)
  outlogical = fill(logicset.logical, each = expander)

  LogicalCombo([logicset.keys..., mykeys...], [logicset.domain..., mydomain...], outlogical)
end

Base.keys(x::LogicalCombo)     = x.keys
domain(x::LogicalCombo)        = x.domain
Base.size(x::LogicalCombo)     = [length(x.logical), length(x.keys)]
Base.size(x::LogicalCombo, y::Integer) = size(x)[y]

function Base.getindex(x::LogicalCombo, row::Integer, col::Integer)
    (col==0) && (row==0) && return :keys
    (row==0) && return keys(x)[col]
    (col==0) && return x.logical[row]
    # Divisor is calculating based on how many values remains how many times to repeat the current value
    divisor = (col+1 > size(x)[2] ? 1 : x.domain[(col+1):size(x)[2]] .|> length |> prod)
    # indexvalue finds the index to select from the column of interest
    indexvalue = (Integer(ceil(row / divisor)) - 1) % length(domain(x)[col]) + 1
    domain(x)[col][indexvalue]
end

Base.collect(x::LogicalCombo; bool::Bool=true, varnames::Bool=true) =
  [x[i,j] for i in !varnames:size(x)[1], j in !bool:size(x)[2]]

Base.getindex(x::LogicalCombo, row::Int, ::Colon; bool::Bool=false) =
  [ x[row,i] for i = !bool:size(x)[2] ]

Base.getindex(x::LogicalCombo, ::Colon, col::Union{Int64,Symbol}; bool::Bool=false) =
  [ x[i,col] for i = 1:size(x)[1]]


function Base.getindex(x::LogicalCombo, row::Integer, col::Symbol)
  keymatch = findall(y -> y == col , x.keys)
  length(keymatch)==0 && throw("Symbol :$col not found")
  x[row, keymatch...]
end

Base.getindex(x::LogicalCombo, ::Colon) =  x.logical
Base.getindex(x::LogicalCombo, y::Union{Int64,UnitRange}) =  x.logical[y]
Base.getindex(x::LogicalCombo, y::Union{BitArray{1},Array{Bool,1}}) =
  [x[i,j] for i in (1:size(x)[1])[x[:] .& y], j in 1:size(x)[2]]

###############################################################################
## Logical Combo [x,y] two index

Base.getindex(x::LogicalCombo, row::Integer, col::String) = x[row, Symbol(col)]

Base.getindex(x::LogicalCombo, ::Colon, col::String) = x[:, Symbol(col)]

Base.getindex(x::LogicalCombo, ::Colon, col::Union{Int64,Symbol}) =
  [ x[i,col] for i = 1:size(x)[1] ]

###############################################################################
## Logical Combo [x,y,z] three index
Base.getindex(x::LogicalCombo, ::Colon, ::Colon, ::Colon)   =
  [x[i,j] for i in (1:size(x)[1])[x[:]], j in 1:size(x)[2]]

Base.getindex(x::LogicalCombo, ::Colon, ::Colon, z::Bool)   =
  [x[i,j] for i in (1:size(x)[1])[x[:] .== z], j in 1:size(x)[2]]

Base.getindex(x::LogicalCombo, ::Colon, y::Union{Int64,Symbol,String}, ::Colon) =
  [x[i,y] for i in (1:size(x)[1])[x[:]]]

Base.getindex(x::LogicalCombo, ::Colon, y::Union{Int64,Symbol,String}, z::Bool) =
  [x[i,y] for i in (1:size(x)[1])[x[:] .== z]]

Base.getindex(x::LogicalCombo, y::Int64 , ::Colon, ::Colon) =
  x[(1:size(x)[1])[x[:]][y],:]

Base.getindex(x::LogicalCombo, y::Int64 , ::Colon, z::Bool) =
  x[(1:size(x)[1])[x[:] .== z][y],:]

Base.getindex(x::LogicalCombo, j::Int64, y::Union{Int64,Symbol,String}, z::Bool) =
  x[(1:size(x,1))[x[:] .== z][j],y]


###############################################################################
## Logical Combo [x,y;] two index with named arguments

Base.getindex(x::LogicalCombo, ::Colon, ::Colon; bool=false, varnames=false) =
  collect(x,bool=bool,varnames=varnames)

###############################################################################
# Set index!
Base.setindex!(x::LogicalCombo, y::Union{Int64,UnitRange}) =  x.logical[y]

Base.setindex!(x::LogicalCombo, y::Bool, z::Integer)   = x.logical[z] = y
Base.setindex!(x::LogicalCombo, y::Bool, z::Union{UnitRange, AbstractArray}) =
  x.logical[z] .= y
Base.setindex!(x::LogicalCombo, y::Union{Array{Bool},Array{Bool,1},BitArray{1}}, ::Colon) = x.logical[:] .= y

Base.setindex!(x::LogicalCombo, y::Union{Array{Bool},Array{Bool,1}}, z::Union{UnitRange, AbstractArray}) =
  x.logical[z] = y

###############################################################################
# Extra Functions

Base.fill(v; each::Integer) = collect(Iterators.flatten([fill(x, each) for x in v]))

function Base.range(x::LogicalCombo)
  p = Dict()
  for i in 1:size(x)[2]; p[x.keys[i]] = sort(unique(x[:,:,i])); end
  p
end


nfeasible(x::LogicalCombo) = sum(x.logical)
pull(x::LogicalCombo) = (nfeasible(x) == 0 ? [] : x[rand(1:nfeasible(x)),:,:])

"""
    showfeasible

Collects a matrix of only feasible outcomes given the parameter space and the
constraints. Use `collect` to output a matrix of all possible matches for
parameter space.

### Examples
```julia
julia> myset = logicalparse("a, b, c in 1:3")
a,b,c in 1:3             feasible outcomes 27 ✓          :3 3 3

julia> myset = logicalparse("a == b; c > b", myset)
a == b                   feasible outcomes 9 ✓           :1 1 3
c > b                    feasible outcomes 3 ✓           :2 2 3

julia> showfeasible(myset)
3×3 Array{Int64,2}:
 1  1  2
 1  1  3
 2  2  3
```
"""
showfeasible(x::LogicalCombo) = x[:,:,true]
