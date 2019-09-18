using Test
using AbstractLogic

@test LogicalCombo().logical == Bool[]
@test LogicalCombo().domain == []
@test LogicalCombo().keys == Symbol[]
@test LogicalCombo().commands == String[]

@test size(expand(LogicalCombo(), a = 1:3, b= 1:4, c = 1:2), 1) == 3*4*2
@test size(expand(LogicalCombo(), ["a","b","c"], ["a1","a2","a3"]), 1) == 3^3
@test size(expand(LogicalCombo(),[:a => 1:3, :b => 1:4, :c => 1:5]), 1) == 3*4*5
