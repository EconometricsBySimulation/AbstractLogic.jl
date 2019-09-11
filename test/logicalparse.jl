using AbstractLogic
using Test

logicset = logicalparse("a,b,c,d,e in 1:2")
@test logicset[1,1] == 1
@test logicset[4^3,3] == 2
@test logicset[:,:a] == logicset[:,1]

logicset = logicalparse("a.1,a.2,a.3,b.1,b.2,b.3 in 1:4")
