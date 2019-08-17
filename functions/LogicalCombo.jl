
struct LogicalCombo
  keys::AbstractArray{Symbol}
  domain::AbstractArray
  logical::AbstractArray{Bool}
end

LogicalCombo() = LogicalCombo(Symbol[],[], Bool[])

function LogicalCombo(; kwargs...)
    if isempty(kwargs)
        return LogicalCombo(Symbol[],[], Bool[0])
    else
        keys = []; domain = []
        for (kw, val) in kwargs;
            push!(keys, kw)
            push!(domain, val)
        end
    end
    LogicalCombo(keys, domain, fill(true,*(length.(domain)...)))
end

Base.keys(x::LogicalCombo)     = x.keys
domain(x::LogicalCombo)        = x.domain
Base.size(x::LogicalCombo)     = [length(x.logical), length(x.keys)]

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

Base.getindex(x::LogicalCombo, row::Integer, col::String) = x[row, Symbol(col)]
Base.getindex(x::LogicalCombo, ::Colon, col::String) = x[:, Symbol(col)]

Base.getindex(x::LogicalCombo, ::Colon, col::Union{Int64,Symbol}) =
  [ x[i,col] for i = 1:size(x)[1] ]

Base.getindex(x::LogicalCombo, ::Colon, ::Colon; bool=false, varnames=false) =
  collect(x,bool=bool,varnames=varnames)

Base.getindex(x::LogicalCombo, ::Colon) =  x.logical
Base.getindex(x::LogicalCombo, y::Union{Int64,UnitRange}) =  x.logical[y]

Base.setindex!(x::LogicalCombo, y::Union{Int64,UnitRange}) =  x.logical[y]

Base.setindex!(x::LogicalCombo, y::Bool, z::Integer)   = x.logical[z] = y
Base.setindex!(x::LogicalCombo, y::Bool, z::Union{UnitRange, AbstractArray}) =
  x.logical[z] .= y

Base.setindex!(x::LogicalCombo, y::Array{Bool}, z::Union{UnitRange, AbstractArray}) =
  x.logical[z] = y

Base.getindex(x::LogicalCombo, ::Colon, ::Colon, ::Colon)   =
  [x[i,j] for i in (1:size(x)[1])[x[:]], j in 1:size(x)[2]]

Base.getindex(x::LogicalCombo, ::Colon, ::Colon, y::Union{Int64,Symbol,String}) =
  [x[i,y] for i in (1:size(x)[1])[x[:]]]

Base.fill(v; each::Integer) = collect(Iterators.flatten([fill(x, each) for x in v]))

function expand(x::LogicalCombo; kwargs...)
  if isempty(kwargs)
    return x
  elseif size(x)[2]==0
    # return(kwargs)
    return LogicalCombo(kwargs...)
  else
    mykeys = []; mydomain = []
    println(kwargs)
    for (kw, val) in kwargs;
        push!(mykeys, kw)
        push!(mydomain, val)
    end
  end

  foreach(y -> (y ∈ x.keys) && throw("key :$y already defined ") , mykeys)

  expander = *(length.(mydomain)...)
  outlogical = fill(x.logical, each = expander)

  LogicalCombo([x.keys..., mykeys...], [x.domain..., mydomain...], outlogical)
end

function  range(x::LogicalCombo)
  p = Dict()
  for i in 1:size(x)[2]; p[x.keys[i]] = sort(unique(x[:,:,i])); end
  p
end

###################### Testing

x = LogicalCombo(a=1:3,b=1:2,c=2:4)

x[2] = false
x[3:4] = false
x[17:18] = fill(false,2)

x[:] === x.logical
x[:,:]
collect(x)
x[:,:,:]
x[:,:,:a]

x[:,:a] == x[:,"a"]

x[2,:a]
x[2,:]
x[2]
range(x)

# Testing Expand Function
x = LogicalCombo(a=1:2,b=1:2)
x[1:2] = false
collect(x)
range(x)

x2 = expand(x,c=1:2)
collect(x2)
range(x2)

# Throw an error
x3 = expand(x, a=1:2)
