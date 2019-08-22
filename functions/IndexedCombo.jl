
Base.fill(v; each::Integer) = collect(Iterators.flatten([fill(x, each) for x in v]))

mutable struct IndexedCombo
  keys::AbstractArray{Symbol,1}
  domain::AbstractArray
  index::AbstractArray{Integer,1}
  size::AbstractArray{Integer,1}
end

IndexedCombo() = IndexedCombo(Symbol[],[], Int64[], [0,0])
IndexedCombo()

function IndexedCombo(; kwargs...)
    if isempty(kwargs)
        return IndexedCombo(Symbol[],[], Int64[], [0,0])
    else
        keys = []; domain = []
        for (kw, val) in kwargs;
            push!(keys, kw)
            push!(domain, val)
        end
    end

    IndexedCombo(keys, domain, collect(1:*(length.(domain)...)),
      [*(length.(domain)...), length(keys)])
end

x = IndexedCombo(a=1:5,b=1:3,c=1:2)

function IndexedCombo(x::Union{AbstractArray{Pair{Symbol, Any}}, Array{Pair{Symbol,UnitRange{Int64}},1}})
    if length(x) == 0
        return IndexedCombo(Symbol[],[], Int64[], [0,0])
    else
        keys = []; domain = []
        for (kw, val) in x;
            push!(keys, kw)
            push!(domain, val)
        end
    end
    IndexedCombo(keys, domain, collect(1:*(length.(domain)...)),
      [*(length.(domain)...), length(keys)])
end
x = IndexedCombo([:a=>1:5,:b=>1:3,:c=>1:2])

function expand(x::IndexedCombo; kwargs...)
  if isempty(kwargs)
    return x
  elseif x.size[2]==0
    return IndexedCombo([kwargs...])
  else
    keys = []; domain = []
    for (kw, val) in kwargs;
        push!(keys, kw)
        push!(domain, val)
    end
  end

  foreach(y -> (y ∈ x.keys) && throw("key :$y already defined!") , keys)

  expander = *(length.(domain)...)
  outindex = (fill(x.index, each = expander) .- 1) .* expander +
    collect(Iterators.flatten(fill(1:expander,x.size[1])))
  IndexedCombo([x.keys..., keys...], [x.domain..., domain...], outindex,
    [*(length.(domain)..., x.size[1]), length(keys) + x.size[2]])

end
x = expand(IndexedCombo(), a=1:3,b=1:2)
@time x=expand(expand(IndexedCombo(), a=1:3,b=1:2), c=1:3, d=1:2, e=1:6, f=1:6)

function expand(x::IndexedCombo, y::Union{AbstractArray{Pair{Symbol, Any}}, Array{Pair{Symbol,UnitRange{Int64}},1}})

    (length(x.keys) == 0) && return IndexedCombo(y)
    (length(y) == 0) && return indexset

    keys = []; domain = []
    for (kw, val) in y;
        push!(keys, kw)
        push!(domain, val)
    end

    foreach(y -> (y ∈ x.keys) && throw("key :$y already defined!") , keys)

    expander = *(length.(domain)...)
    outindex = (fill(x.index, each = expander) .- 1) .* expander +
      collect(Iterators.flatten(fill(1:expander,x.size[1])))
    IndexedCombo([x.keys..., keys...], [x.domain..., domain...], outindex,
      [*(length.(domain)..., x.size[1]), length(keys) + x.size[2]])
end

x = expand(expand(IndexedCombo(), [:a=>1:3,:b=>1:2]), [:c=>1:4, :d=>1:5])

Base.keys(x::IndexedCombo)                = x.keys
domain(x::IndexedCombo)                   = x.domain
Base.size(x::IndexedCombo)                = x.size
Base.size(x::IndexedCombo,i::Integer)     = x.size[i]
solutions(x::IndexedCombo)                = x.index |> length

function Base.getindex(x::IndexedCombo, row::Integer, col::Integer)
    (col==0) && (row==0) && return :Valid
    (row==0) && return keys(x)[col]
    (col==0) && return row ∈ x.index
    # Divisor is calculating based on how many values remains how many times to repeat the current value
    divisor = (col+1 > size(x)[2] ? 1 : x.domain[(col+1):size(x)[2]] .|> length |> prod)
    # indexvalue finds the index to select from the column of interest
    indexvalue = (Integer(ceil(row / divisor)) - 1) % length(domain(x)[col]) + 1
    domain(x)[col][indexvalue]
end

[x[i,j] for i in 1:x.size[1], j in 0:x.size[2]]

Base.collect(x::IndexedCombo; bool::Bool=true, varnames::Bool=true) =
  [x[i,j] for i in !varnames:size(x)[1], j in !bool:size(x)[2]]

function mysplit(x, grouplength::Integer; filler::Array=[0,-1])
  (2*grouplength >= length(x)) && return x
  top = x[1 .+ 0:grouplength]
  bottom = x[reverse(length(x) .- (0:(grouplength-1)))]
  [top..., filler[[1,2,1]]..., bottom...]
end

mysplit([1,2,3,5,6,7,8], 2)
mysplit(1:15, 4)
mysplit(1:15, 5)

function Base.println(x::IndexedCombo;
    n::Integer=10,
    footer::Bool = true,
    header::Bool = true,
    everything::Bool=false)

  isodd(n) && (n=round(n÷2)*2)

  println()
  header && (join(x[0,:, bool=true], "\t") |> println)
  indexset = everything ? (1:size(x,1)) : x.index
  for i in mysplit(indexset, n÷2)
      (i > 0) && (join(x[i,:, bool=true], "\t") |> println)
      (i == 0) && (repeat( "..\t", size(x,2)) |> println)
      (i .< 0) && ("$(length(indexset) - n) rows not printed" |> println)
  end
  footer && (join(x[0,:, bool=true], "\t") |> println)
end

printall(x::IndexedCombo; I...) = println(x, everything = true)

x.index = x.index[x.index .% 9 .== 0]
println(x)
println(x, n=7)
println(x, n=15)
println(x, n=7, everything=true)

x[x.index .% 18 .== 0]

Base.getindex(x::IndexedCombo, row::Int, ::Colon; bool::Bool=false) =
  [ x[row,i] for i = !bool:size(x,2) ]

Base.getindex(x::IndexedCombo, ::Colon, col::Union{Int64,Symbol}; bool::Bool=false) =
  [ x[i,col] for i = 1:size(x)[1]]

function Base.getindex(x::IndexedCombo, row::Integer, col::Symbol)
  keymatch = findall(y -> y == col , x.keys)
  length(keymatch)==0 && throw("Symbol :$col not found")
  x[row, keymatch...]
end

Base.getindex(x::IndexedCombo, row::Integer, col::String) = x[row, Symbol(col)]
Base.getindex(x::IndexedCombo, ::Colon, col::String) = x[:, Symbol(col)]

Base.getindex(x::IndexedCombo, ::Colon, col::Union{Int64,Symbol}) =
  [ x[i,col] for i = 1:size(x)[1] ]


Base.getindex(x::IndexedCombo, ::Colon, ::Colon; bool=false, varnames=false) =
  collect(x,bool=bool,varnames=varnames)

Base.getindex(x::IndexedCombo, ::Colon) =  x.index
Base.getindex(x::IndexedCombo, y::Union{Int64,UnitRange}) = [x.index ∈ i for i ∈ y]

Base.getindex(x::IndexedCombo, y::BitArray{1}) =
  x.index[[ind ∈ (1:size(x,1))[y] for ind in x.index]]

x.index = x[(1:size(x,1)) .% 2 .== 0]
x.index = x[(1:size(x,1)) .% 3 .== 0]
x.index = x[(1:size(x,1)) .% 4 .== 0]
x.index = x[(1:size(x,1)) .% 5 .== 0]

x |> println

  [x[i,j] for i in (1:size(x)[1])[x[:] .& y], j in 1:size(x)[2]]

  [x[i,j] for i in (1:size(x)[1])[x[:] .& y], j in 1:size(x)[2]]

Base.getindex(x::IndexedCombo, ::Colon, ::Colon, ::Colon)   =
  [x[i,j] for i in (1:size(x)[1])[x[:]], j in 1:size(x)[2]]

Base.getindex(x::IndexedCombo, ::Colon, ::Colon, y::Union{Int64,Symbol,String}) =
  [x[i,y] for i in (1:size(x)[1])[x[:]]]

# Set index!
Base.setindex!(x::IndexedCombo, y::Union{Int64,UnitRange}) =  x.logical[y]

Base.setindex!(x::IndexedCombo, y::Bool, z::Integer)   = x.logical[z] = y
Base.setindex!(x::IndexedCombo, y::Bool, z::Union{UnitRange, AbstractArray}) =
  x.logical[z] .= y
Base.setindex!(x::IndexedCombo, y::Union{Array{Bool},Array{Bool,1},BitArray{1}}, ::Colon) = x.logical[:] .= y

Base.setindex!(x::IndexedCombo, y::Union{Array{Bool},Array{Bool,1}}, z::Union{UnitRange, AbstractArray}) =
  x.logical[z] = y

Base.fill(v; each::Integer) = collect(Iterators.flatten([fill(x, each) for x in v]))

function Base.range(x::IndexedCombo)
  p = Dict()
  for i in 1:size(x)[2]; p[x.keys[i]] = sort(unique(x[:,:,i])); end
  p
end

showfeasible(x::IndexedCombo) = x[:,:,:]

###################### Testing

x = IndexedCombo(a=1:3,b=1:2,c=2:4)

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
x = IndexedCombo(a=1:2,b=1:2)
x[1:2] = false
collect(x)
range(x)

x2 = expand(x,c=1:2)
collect(x2)
range(x2)

# Throw an error
#x3 = expand(x, a=1:2)

# Expanding on an empty set generates a new set
expand(IndexedCombo(), a=1:2, b=1) |> collect
