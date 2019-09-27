using AbstractLogic
using Test
using Suppressor

logicset = @suppress logicalparse("a,b,c,d,e in 1:2")
@test logicset[1,1] == 1
@test logicset[4^3,3] == 2
@test logicset[:,:a] == logicset[:,1]

logicset = @suppress logicalparse("a.1,a.2,a.3,b.1,b.2,b.3 in 1:3 || {{j}}.1 != {{j}}.2, {{j}}.3 &&& {{j}}.2 != {{j}}.3")
@test nfeasible(logicset) == 36
@test @suppress nfeasible(logicalparse("a,b,c in 1:3 || {{i}}!={{>i}}")) == nfeasible(logicalparse("a,b,c in unique"))

logicset = @suppress logicalparse("a, b in 1; a != b")
@test search("=1", logicset) === missing
