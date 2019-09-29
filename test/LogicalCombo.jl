using Test
using AbstractLogic

@test LogicalCombo().logical == Bool[]
@test LogicalCombo().domain == []
@test LogicalCombo().keys == Symbol[]
@test LogicalCombo().commands == String[]

@test size(expand(LogicalCombo(), a = 1:3, b= 1:4, c = 1:2), 1) == 3*4*2
@test size(expand(LogicalCombo(), ["a","b","c"], ["a1","a2","a3"]), 1) == 3^3
@test size(expand(LogicalCombo(),[:a => 1:3, :b => 1:4, :c => 1:5]), 1) == 3*4*5
@test size(expand(LogicalCombo(), a = 1:3, b = 1:4, c = 1:5), 1) == 3*4*5
@test size(expand(LogicalCombo(a = 1:3, b = 1:4), c = 1:5), 1) == 3*4*5
@test_throws "key :a already defined!" expand(LogicalCombo(a=1), a = 1:3)
@test size(expand(LogicalCombo()), 1) == 0

@test nfeasible(LogicalCombo()) == 0
@test LogicalCombo() |> collect |> size == (1,1)

@test string(LogicalCombo()) == string(LogicalCombo(Symbol[], [], Bool[]))

x = LogicalCombo([:x=>1:2, :y=>1:4])
@test  x |> nfeasible == 8

@test x[1:2] == [true, true]
@test x[1] == x[2]
@test x[5,"x"] == x[2,"y"]
@test x[2,"x"] != x[2,"y"]
@test x[:,:x] == x[:,"x"]
@test x[1:2,:] == x[[1,2],:]
@test x[:,:x,:] == x[:,:x,true]
@test x[1,:x,true] == 1
@test x[1:3] = true

@test x[:,:,true] != x[:,:,!true]
@test x[:,:] |> size == (8,2)
@test x[:,:, varnames=true] |> size == (9,2)

x[1:2] = [false, false]; @test x[1:2] == [false, false]
x[3] = false; @test x[3] == false

@test range(x) |> length == 2
@test range(x, "x") |> length == 1

@test length(AbstractLogic.sample(LogicalCombo())) == 0
@test length(AbstractLogic.sample(x)) == 2
@test length(AbstractLogic.sample(x,3)) == 6
@test length(AbstractLogic.sample(x,2,false)) == 4
