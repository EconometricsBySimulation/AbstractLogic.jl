cd("C:/Users/francis.smart.ctr/GitDir/AbstractLogic")

i=1
function hotvalue(i, col, invec)
    indexvalue = Integer(ceil(i / (invec[(col+1):length(invec)] .|> length |> prod)))
    indexvalue = (indexvalue - 1) % length(invec[col])
    invec[col][indexvalue+1]
    #invec[col][indexvalue]
end
