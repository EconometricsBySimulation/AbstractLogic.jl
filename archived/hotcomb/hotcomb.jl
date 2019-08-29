#cd("C:/Users/francis.smart.ctr/GitDir/AbstractLogicJL")
#cd("/Users/francissmart/Documents/GitHub/AbstractLogic")

struct Hotcomb
  intuple
end

Base.keys(x::Hotcomb)     = keys(x.intuple)
value(x::Hotcomb)         = [(length(i)>1 ? i : 1:i) for i in x.intuple]
Base.size(x::Hotcomb)     = (*(length.(value(x))...), length(x.intuple))
find(x::Tuple, y::Symbol) = x[[x...] .== y]
Base.collect(x::Hotcomb)  = [x[i,j] for i in 1:size(x)[1], j in 1:size(x)[2]]
Base.min(x::Hotcomb)      = min(collect(Iterators.flatten(value(x)))...)
Base.max(x::Hotcomb)      = max(collect(Iterators.flatten(value(x)))...)
ends(x::Hotcomb)          = [min(x), max(x)]

function Base.getindex(x::Hotcomb, row::Integer, col::Integer)
    # Divisor is calculating based on how many values remains how many times to repeat the current value
    divisor = (col+1 > size(x)[2] ? 1 : value(x)[(col+1):size(x)[2]] .|> length |> prod)
    # indexvalue finds the index to select from the column of interest
    indexvalue = (Integer(ceil(row / divisor)) - 1) % length(value(x)[col]) +1
    value(x)[col][indexvalue]
end

Base.getindex(x::Hotcomb, row::Int, ::Colon) = [ x[row,i] for i = 1:size(x)[2] ]
Base.getindex(x::Hotcomb, ::Colon, col::Union{Int64,Symbol}) = [ x[i,col] for i = 1:size(x)[1] ]
Base.getindex(x::Hotcomb, ::Colon, ::Colon) = collect(x)

function Base.getindex(x::Hotcomb, row::Integer, col::Symbol)
  keymatch = findall(y -> y==col, [keys(x)...])
  length(keymatch)==0 && throw("Symbol :$col not found")
  x[row, keymatch...]
end

Base.getindex(x::Hotcomb, row::AbstractArray{Bool,1}) = x[row,:]

Base.getindex(x::Hotcomb, row::AbstractArray{Bool,1}, col::Union{Symbol,Int}) =
  [ x[i,col] for i = (1:size(x)[1])[row] ]

Base.getindex(x::Hotcomb, ::Colon, col::Union{Array{Int,1}, Array{Symbol,1}}) =
  [ x[i,j] for i = 1:size(x)[1], j in col]

Base.getindex(x::Hotcomb, row::AbstractArray{Bool,1}, col::Union{Array{Int,1}, Array{Symbol,1}}) =
  [ x[i,j] for i = (1:size(x)[1])[row], j in col]

Base.getindex(x::Hotcomb, row::AbstractArray{Bool,1}, ::Colon) =
  [ x[i,j] for i = (1:size(x)[1])[row], j =  (1:size(x)[2])]

Base.getindex(x::Hotcomb, ::Colon, ::Colon) = collect(x)

Base.getindex(x::Hotcomb, symb::Union{Array{Symbol,1}, Symbol}) = x[:,symb]

append(x::Hotcomb, y::NamedTuple) = Hotcomb(merge(x.intuple, y))

x = Hotcomb((a=2,b=2,c=2,d=2))

append(x, (e=2,f=2, a=2))

###################### Testing


x = Hotcomb((a=4,b=4,c=6:15))
binaryselector = rand(Bool, size(x)[1])

x[1,:]
x[binaryselector, :a]
x[:, [:a,:b]]
x[[:a,:b]]
x[:a]
x[binaryselector, [1,3,2,1]]

x[binaryselector, 1]
y = x[binaryselector, :]

# min(x)
# max(x)
# ends(x)



"""
Hotcomb(x) takes a tuple, named tuple, vector of ranges, or vector of constants.
Vectors of constants will be expanded with starting index of 1.

It can be accessed using `[:,:]`` getindex lookups. It uses processing speed to
loopup values but uses almost no memory. Symbols can also be used to index columns.
Hotcomb type has `key()`, `value()`, `size()`, and `collect()` methods defined for it.

# Examples
```jldoctest
julia> mycomb = Hotcomb((a=1:2, b=1:4,c='a':'c'))
Hotcomb((a = 1:2, b = 1:4, c = 'a':1:'c'))

julia> collect(mycomb)
24×3 Array{Any,2}:
 1  1  'a'
 1  1  'b'
 1  1  'c'
 1  2  'a'
 1  2  'b'
 1  2  'c'
 ⋮
 2  3  'a'
 2  3  'b'
 2  3  'c'
 2  4  'a'
 2  4  'b'
 2  4  'c'

julia> mycomb[5 , :]
3-element Array{Any,1}:
 1
 2
 'b'

julia> mycomb[4 , :b]
2

julia> keys(Hotcomb((a=1:2, b=1:4,c='a':'c')))
(:a, :b, :c)

julia> value(Hotcomb([4,5,6]))
3-element Array{UnitRange{Int64},1}:
 1:4
 1:5
 1:6

julia> value(Hotcomb([4,5,6]) == value(Hotcomb([1:4,1:5,1:6]))
true
```
"""
