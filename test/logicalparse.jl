using AbstractLogic
using Test
using Suppressor

@test LogicalCombo() |> nfeasible == 0

logicset = @suppress logicalparse("a,b,c,d,e in 1:2")
@test logicset[1,1] == 1
@test logicset[4^3,3] == 2
@test logicset[:,:a] == logicset[:,1]

logicset = @suppress logicalparse("a.1,a.2,a.3,b.1,b.2,b.3 in 1:3 || {{j}}.1 != {{j}}.2, {{j}}.3 &&& {{j}}.2 != {{j}}.3")
@test nfeasible(logicset) == 36
@test @suppress nfeasible(logicalparse("a,b,c in 1:3 || {{i}}!={{>i}}")) == nfeasible(logicalparse("a,b,c in unique"))

logicset = @suppress logicalparse("a,b,c in 1:3 || {{i}}!={{!i}}")
@test AbstractLogic.operatoreval("a^=b",logicset) |> nfeasible == 0
@test AbstractLogic.operatoreval("a|=b",logicset) |> nfeasible == 0
@test AbstractLogic.operatoreval("a!|=b",logicset) |> nfeasible == 6
@test AbstractLogic.operatoreval("a<=b",logicset) |> nfeasible == 3
@test AbstractLogic.operatoreval("a<<b",logicset) |> nfeasible == 1
@test AbstractLogic.operatoreval("a>=b",logicset) |> nfeasible == 3
@test AbstractLogic.operatoreval("a>>b",logicset) |> nfeasible == 1
@test AbstractLogic.operatoreval("a % 3 ==0",logicset) |> nfeasible == 2


@test @suppress logicalparse("{{<3|>3}}=1", logicset) |> nfeasible  == 0

@test @suppress search("{{i+4}}=1", logicset)[1] === missing

@test @suppress logicalparse("a,b ∈ 0:1; a==a === b==b; a == b !=> b != a") |> nfeasible == 4

x = @suppress logicalparse("a,b in 1:5; true &&& true ||| false ==> true <== false ||| true ^^^ false")
@test nfeasible(x) == 25

x = @suppress logicalparse("a,b in 1:5; true &&&& true |||| false ===> true <=== false |||| true ^^^^ false")
@test nfeasible(x) == 25

logicset = @suppress logicalparse("a, b in 1; a != b")
@test @suppress( search("=1", logicset)) === missing
@test  @suppress(checkfeasible("a=1", logicalparse("a, b in 1; a != b")) === missing)

@test AbstractLogic.definelogicalset("a ∈ 1") |> nfeasible == 1
@test AbstractLogic.definelogicalset("a,b,c ∈ 1,2,3 || unique") |> nfeasible == 6

@test expand(LogicalCombo(), [:a => 1:2, :b => 1:3]) |> nfeasible == 6

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

@test @suppress(logicalparse("a,b,c,d,e in 1:2; {{i}}!={{i+1}}") |> nfeasible) == 2
@test @suppress(logicalparse("a,b,c,d,e in 1:2; {{i}}!={{i-1}}") |> nfeasible) == 2
@test @suppress(logicalparse("a,b in 1:2; {{i}}!={{>i}}") |> nfeasible) == 2

@test @capture_out(help()) |> length > 500
@test @capture_out(help("")) |> length > 500
@test @capture_out(help("in")) |> length > 250
@test @capture_out(help("back")) |> length > 50
@test @capture_out(help("!=")) |> length > 50
@test @capture_out(help("!==")) |> length > 430
@test @capture_out(help("!===")) |> length > 440
@test @capture_out(help("{{i}}")) |> length > 370

@test @suppress(checkfeasible("{{i}}=1", logicalparse("a,b in 1:2")))[1] == .25
@test @capture_out(logicalparse("a,b in 1:2; error"))[(end-16):end] == "not interpreted!\n"

x = @suppress logicalparse("a,b in 1:2; a==b")
@test @suppress(AbstractLogic.back(x) |> nfeasible) == 4

@test @suppress nfeasible(logicalparse(["a,b in 1:2","a==b"])) == nfeasible(x)

@test @suppress(logicalparse("a, b ∈ 0:1; a | b ||| a & b")) |> nfeasible == 3
