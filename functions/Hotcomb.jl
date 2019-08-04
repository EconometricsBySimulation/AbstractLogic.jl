cd("C:/Users/francis.smart.ctr/GitDir/AbstractLogicJL")
cd("/Users/francissmart/Documents/GitHub/AbstractLogic")

struct Hotcomb
  intuple
end

Base.keys(x::Hotcomb)     = keys(x.intuple)
value(x::Hotcomb)         = [(length(i)>1 ? i : 1:i) for i in x.intuple]
Base.size(x::Hotcomb)     = (*(length.(value(x))...), length(x.intuple))
find(x::Tuple, y::Symbol) = x[[x...] .== y]
Base.collect(x::Hotcomb)  = [x[i,j] for i in 1:size(x)[1], j in 1:size(x)[2]]

function Base.getindex(x::Hotcomb, row::Integer, col::Integer)
    # Divisor is calculating based on how many values remains how many times to repeat the current value
    divisor = (col+1 > size(x)[2] ? 1 : value(x)[(col+1):size(x)[2]] .|> length |> prod)
    # indexvalue finds the index to select from the column of interest
    indexvalue = (Integer(ceil(row / divisor)) - 1) % length(value(x)[col]) +1
    value(x)[col][indexvalue]
end

function Base.getindex(x::Hotcomb, I...)
  ([I...] == Any[]) && (return collect(x))
  index = [I...]
  (index[1] == Colon()) && (index[2] != Colon()) && (return [x[i,index[2]] for i = 1:size(x)[1] ])
  (index[1] != Colon()) && (index[2] == Colon()) && (return [x[index[1],i] for i = 1:size(x)[2] ])
  (index[1] == Colon()) && (index[2] == Colon()) && (return collect(x))
end

function Base.getindex(x::Hotcomb, row::Integer, col::Symbol)
  keymatch = findall(y -> y==col, [keys(x)...])
  length(keymatch)==0 && throw("Symbol :$col not found")
  x[row, keymatch...]
end


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
