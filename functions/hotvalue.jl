cd("C:/Users/francis.smart.ctr/GitDir/AbstractLogic")

struct hotcombination(invec)

  Size = *(length.(invec))
end

function hotvalue(i, col, invec)
    indexvalue = Integer(ceil(i / (invec[(col+1):length(invec)] .|> length |> prod)))
    indexvalue = (indexvalue - 1) % length(invec[col])
    invec[col][indexvalue+1]
    #invec[col][indexvalue]
end


myset = [1:2, 1:2, 1:2, 1:2]

hotvalue(12, 1, myset)
[hotvalue(i, j, myset) for i in 1:16, j in 1:4]

hotvalue(1, 1, [1:3,1:2,1:2])

hotvalue(1, 1, [1:3,1:2,1:2])

invec = Dict(a=1:2, b=1:4,c=1:4)
