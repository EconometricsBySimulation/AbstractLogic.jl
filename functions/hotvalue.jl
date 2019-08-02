cd("C:/Users/francis.smart.ctr/GitDir/AbstractLogic")

struct Hotcombination
  intuple
end

Base.:keys(x::Hotcombination) = keys(x.intuple)
value(x::Hotcombination) = [i for i in x.intuple]
Base.:size(x::Hotcombination) = (*(length.(value(x))...), length(x.intuple))
ncol(x::Hotcombination) = size(x)[2]
nrow(x::Hotcombination) = size(x)[1]
find(x::Tuple, y::Symbol) = x[[x...] .== y]

function Base.getindex(x::Hotcombination, row::Integer, col::Integer)
    # Divisor is calculating based on how many values remains
    # how many times to repeat the current value (effectively)
    divisor = (col+1 > size(x)[2] ? 1 : value(x)[(col+1):size(x)[2]] .|> length |> prod)
    # indexvalue finds the index to select from the column of interest
    indexvalue = (Integer(ceil(row / divisor)) - 1) % length(value(x)[col])
    value(x)[col][indexvalue+1]
    #invec[col][indexvalue]
end

Base.getindex(x::Hotcombination, row::Integer, col::Symbol) = x[row, find(keys(x), col)[1]]


x = Hotcombination((a=1:2, b=1:4,c='a':'c'))
keys(x)
value(x)
size(x)
x[3,2]
[x[i,j] for i in 1:size(x)[1], j in 1:size(x)[2]] # Seems to be working
x[3,:b]

first(keys(x)[[keys(x)...] .== col])


names = keys(invec)
vector = [i for i in invec]
Size = (*(length.(vector)...), length(vector))

function hotvalue(i, col, invec)
    indexvalue = Integer(ceil(i / (invec[(col+1):length(invec)] .|> length |> prod)))
    indexvalue = (indexvalue - 1) % length(invec[col])
    invec[col][indexvalue+1]
    #invec[col][indexvalue]
end


invec = [1:2, 1:2, 1:2, 1:2]

hotvalue(12, 2, invec)
hotvalue(12, 4, invec)

[hotvalue(i, j, invec) for i in 1:16, j in 1:4]

hotvalue(1, 1, [1:3,1:2,1:2])

hotvalue(1, 1, [1:3,1:2,1:2])

invec |> length

keys(invec)
