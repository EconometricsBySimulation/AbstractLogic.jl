"""
    LogicalCombo <: Any

A LogicalCombo stores the variable names, domains, as well as an binary
representation of feasible values given constraints.

**Fields**

* keys : Stores the names of variables.
* domain : Stores the range of possible matches variables can have.
* logical : A binary vector marking feasibility of length equal to every
    possible combination of value which the matrix could take on.
* commandlist : An array collection of the strings input to generate the current
    state of the the object.

**Indexing**

* [x,y] Where x is numeric or : and y is numeric, colon, or symbol will
    return matrix point values regardless of feasibility.
* [:,:] Will collect the entire possible domain and is the same as `collect()`.
* [x,0] Will return the logical vector values
* [x,:,true] Will return the xth feasible value of the LogicalCombo set.
* [x,:,false] Will return the xth infeasible value of the LogicalCombo set.
"""
struct LogicalCombo
  keys::Array{Symbol}
  domain::AbstractArray
  logical::Array{Bool}
  lookup::Function
  type::String
  commands::Array{String}
end

LogicalCombo(keys, domain, logical) =
    LogicalCombo(keys, domain, logical, permutationlookup, "Permutation", String[])

LogicalCombo(keys, domain, logical, permutationlookup, type) =
    LogicalCombo(keys, domain, logical, permutationlookup, type, String[])

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
    # if length(x) == 0
    #     return LogicalCombo(Symbol[],[], Bool[0])
    # else
        mykeys = []; mydomain = []
        for (kw, val) in x;
            push!(mykeys, kw)
            push!(mydomain, val)
        end
    # end
    LogicalCombo(mykeys, mydomain, fill(true,*(length.(mydomain)...)))
end

Base.keys(x::LogicalCombo)     = x.keys
domain(x::LogicalCombo)        = x.domain
Base.size(x::LogicalCombo)     = [length(x.logical), length(x.keys)]
Base.size(x::LogicalCombo, y::Integer) = size(x)[y]

function permutationlookup(x::LogicalCombo, row::Integer, col::Integer)
    # Divisor is calculating based on how many values remains how many times to repeat the current value
    divisor = (col+1 > size(x)[2] ? 1 : x.domain[(col+1):size(x)[2]] .|> length |> prod)
    # indexvalue finds the index to select from the column of interest
    indexvalue = (Integer(ceil(row / divisor)) - 1) % length(domain(x)[col]) + 1
    domain(x)[col][indexvalue]
end

function permutationuniquelookup(x::LogicalCombo, row::Integer, col::Integer)
    n = size(x,2)
    fset = 1:n
    y = row
    z = 0
    setout = Integer[]
    for j in 1:col
        K = factorial(n-j)
        z = Integer(ceil(y/ K))
        y = y - (z-1) * K
        push!(setout, fset[z])
        fset = fset[[(1:(z-1))..., ((z+1):length(fset))...]]
    end
    domain(x)[setout[col]]
end

function Base.getindex(x::LogicalCombo, row::Integer, col::Integer)
    (col==0) && (row==0) && return :keys
    (row==0) && return keys(x)[col]
    (col==0) && return x.logical[row]
    x.lookup(x, row, col)
end

Base.collect(x::LogicalCombo; bool::Bool=true, varnames::Bool=true) =
  [x[i,j] for i in !varnames:size(x)[1], j in !bool:size(x)[2]]

function Base.getindex(x::LogicalCombo, row::Integer, col::Symbol)
  keymatch = findall(y -> y == col , x.keys)
  length(keymatch)==0 && throw("Symbol :$col not found")
  x[row, keymatch...]
end

Base.getindex(x::LogicalCombo, ::Colon) =  x.logical
Base.getindex(x::LogicalCombo, y::Union{Int64,UnitRange}) =  x.logical[y]
# Base.getindex(x::LogicalCombo, y::Union{Array}) =
#   [x[i,j] for i in (1:size(x)[1])[x[:] .& y], j in 1:size(x)[2]]

###############################################################################
## Logical Combo [x,y] two index

Base.getindex(x::LogicalCombo, row::Int, ::Colon; bool::Bool=false) =
  [ x[row,i] for i = !bool:size(x)[2] ]

Base.getindex(x::LogicalCombo, y::Union{Integer,Array}, col::String) = x[y, Symbol(col)]

Base.getindex(x::LogicalCombo, ::Colon, col::String) = x[:, Symbol(col)]

Base.getindex(x::LogicalCombo, y::Union{Integer,Array{Int64}}, ::Colon) =
  hcat([ x[i,:] for i in collect(y) ]...)

Base.getindex(x::LogicalCombo, row::UnitRange, ::Colon) = x[collect(row),:]

Base.getindex(x::LogicalCombo, ::Colon, col::Union{Int64,Symbol}; bool::Bool=false) =
  [ x[i,col] for i = 1:size(x)[1]]

# Base.getindex(x::LogicalCombo, ::Colon, col::Union{Int64,Symbol}) =
#   [ x[i,col] for i = 1:size(x)[1] ]

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

Base.getindex(x::LogicalCombo, y::Union{Int64, Array}, ::Colon, z::Bool) =
  x[(1:size(x)[1])[x[:] .== z][y],:]

Base.getindex(x::LogicalCombo, j::Int64, y::Union{Int64,Symbol,String}, z::Bool) =
  x[(1:size(x,1))[x[:] .== z][j],y]


###############################################################################
## Logical Combo [x,y;] two index with named arguments

Base.getindex(x::LogicalCombo, ::Colon, ::Colon; bool=false, varnames=false) =
  collect(x,bool=bool,varnames=varnames)

###############################################################################
# Set index!
# Base.setindex!(x::LogicalCombo, y::Union{Int64,UnitRange}) =  x.logical[y]

Base.setindex!(x::LogicalCombo, y::Bool, z::Integer)   = x.logical[z] = y
Base.setindex!(x::LogicalCombo, y::Bool, z::Union{UnitRange, AbstractArray}) =
  x.logical[z] .= y
Base.setindex!(x::LogicalCombo, y::Union{Array{Bool},Array{Bool,1},BitArray{1}}, ::Colon) = x.logical[:] .= y

Base.setindex!(x::LogicalCombo, y::Union{Array{Bool},Array{Bool,1}}, z::Union{UnitRange, AbstractArray}) =
  x.logical[z] = y

###############################################################################
# Extra Functions

Base.fill(v; each::Integer) = collect(Iterators.flatten([fill(x, each) for x in v]))

function Base.range(x::LogicalCombo; feasible=true)
  p = Dict()
  for i in 1:size(x,2); p[x.keys[i]] = sort(unique(x[:,i,feasible])); end
  p
end

Base.range(x::LogicalCombo, y::String; feasible=true) =
  Dict(Symbol(y) => x[:, Symbol(y), feasible] |> unique |> sort)

using StatsBase

function StatsBase.sample(x::LogicalCombo; n=1, feasible=true)
  if nfeasible(x) == 0
    return []
  elseif nfeasible(x) == 1
    return x[:,:,:]
  else
    y = x[sample(1:nfeasible(x, feasible), n, replace=false),:,feasible]
    (n == 1) && return y
    (n > 1) && return sort(y, dims=1)
 end
end

StatsBase.sample(x::LogicalCombo, n; feasible=true) = sample(x, n=n, feasible=feasible)
StatsBase.sample(x::LogicalCombo, n, feasible) = sample(x, n=n, feasible=feasible)
