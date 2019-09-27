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

x = @suppress logicalparse("a,b in 1:5; true &&& true ||| false ==> true <== false ||| true ^^^ false")
@test nfeasible(x) == 25

x = @suppress logicalparse("a,b in 1:5; true &&&& true |||| false ===> true <=== false |||| true ^^^^ false")
@test nfeasible(x) == 25

logicset = @suppress logicalparse("a, b in 1; a != b")
@test @suppress( search("=1", logicset)) === missing

logicset = @suppress logicalparse("a, b, c in 1:3; a > b")
@test @suppress !dependenton("a ⊥ b", logicset)
@test @suppress dependenton("a !⊥ b", logicset)

@test @suppress !dependenton("a ⊥ b", logicset)
@test @suppress dependenton("a !⊥ b", logicset)
@test @suppress dependenton("a ⊥ c", logicset)

@test @suppress !setcompare("a ⊂ b", logicset)
@test @suppress setcompare("a !⊂ b", logicset)
@test @suppress setcompare("c ⊃ b", logicset)
@test @suppress setcompare("b !⊃ c", logicset)
@test @suppress setcompare("a,b ⋂ b,c", logicset)
@test @suppress !setcompare("a !⋂ c", logicset)

@test logicset |> showfeasible == logicset[:,:,true]

@test @capture_out(help()) |> length > 500
@test @capture_out(help("")) |> length > 500
@test @capture_out(help("in")) |> length > 250
@test @capture_out(help("back")) |> length > 50
@test @capture_out(help("!=")) |> length > 50
@test @capture_out(help("!==")) |> length > 430
@test @capture_out(help("!===")) |> length > 440
@test @capture_out(help("{{i}}")) |> length > 370
