cd("C:/Users/francis.smart.ctr/GitDir/AbstractLogic")

struct Hotcomb
  intuple
end

Base.keys(x::Hotcomb)     = keys(x.intuple)
value(x::Hotcomb)         = [(length(i)>1 ? i : 1:i) for i in x.intuple]
Base.size(x::Hotcomb)     = (*(length.(value(x))...), length(x.intuple))
find(x::Tuple, y::Symbol) = x[[x...] .== y]

function Base.getindex(x::Hotcomb, row::Integer, col::Integer)
    # Divisor is calculating based on how many values remains
    # how many times to repeat the current value
    divisor = (col+1 > size(x)[2] ? 1 : value(x)[(col+1):size(x)[2]] .|> length |> prod)
    # indexvalue finds the index to select from the column of interest
    indexvalue = (Integer(ceil(row / divisor)) - 1) % length(value(x)[col])
    value(x)[col][indexvalue+1]
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

Base.collect(x::Hotcomb) = [x[i,j] for i = 1:size(x)[1], j = 1:size(x)[2]]
###############################################################################
# Testing

using Test

mycomb = Hotcomb((a=1:2, b=1:4,c='a':'c'))
@test keys(mycomb) == (:a, :b, :c)
@test value(mycomb) == [1:2, 1:4, 'a':'c']
@test size(mycomb) == (24,3)
@test collect(mycomb) == mycomb[:,:] # Seems to be working
@test mycomb[13,2] == mycomb[13,:b]
@test mycomb[5,:] == [1, 2, 'b']

@test_throws "Symbol :d not found" mycomb[3,:d]

###############################################################################
# Benchmarking

using BenchmarkTools, InteractiveUtils

mycomb = Hotcomb([7,7,7,7,7,7,7])
value(mycomb)
size(mycomb)

mycomb_collect = mycomb[]

mycomb[1000,:]
@benchmark mycomb[1000,:]

mycomb_collect[1000,:]
@benchmark mycomb_collect[1000,:]

varinfo()
