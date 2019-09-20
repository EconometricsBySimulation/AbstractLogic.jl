using AbstractLogic
using Test
using Suppressor

@test (@capture_out abstractlogic("clearall")) == "Clearing Everything!\n"

# Basic logicparser features
@suppress abstractlogic("a = 1 [clear]"); @test returnreplerror()
@suppress abstractlogic("range abc"); @test returnreplerror()
@suppress abstractlogic("range a b"); @test returnreplerror()
@suppress abstractlogic("clear; a,b,c in 0:1; clear"); @test nfeasible(returnreplset()) != 1
@suppress abstractlogic("clearall"); @test length(returnlogicset()) == 1
@suppress abstractlogic("a,b,c ∈ 0:1; a=b [clear]"); @test activehistory.current == 3

# Navigation
@suppress abstractlogic("back [clear]"); @test returnreplerror()
@suppress abstractlogic("next [clear]"); @test returnreplerror()
@suppress abstractlogic("a,b,c ∈ 0:1; back"); @test !returnreplerror()
@suppress abstractlogic("next"); @test !returnreplerror()
@test @suppress abstractlogic("", returnactive = true) |> nfeasible == 8

# Show
@suppress abstractlogic("show"); @test !returnreplerror()
@suppress abstractlogic("clear; show"); @test returnreplerror()

# Import/Export
@suppress abstractlogic("a,b in 1:2; export testset"); @test testset |> nfeasible == 4
@test @suppress abstractlogic("clear; import testset", returnactive = true) |> nfeasible == 4

# REPL Commands
@suppress abstractlogic("compare noname"); @test returnreplerror()
@suppress abstractlogic("keys"); @test !returnreplerror()
@suppress abstractlogic("d"); @test !returnreplerror()
@suppress abstractlogic("discover"); @test !returnreplerror()
@suppress abstractlogic("h"); @test !returnreplerror()
@suppress abstractlogic("history"); @test !returnreplerror()
@suppress abstractlogic("ls"); @test !returnreplerror()
@suppress abstractlogic("logicset"); @test !returnreplerror()

# Silence and noisy
@test @suppress abstractlogic("clear; a,b in 1:2; preserve; clear; restore", returnactive = true) |> nfeasible == 4
@suppress abstractlogic("silence"); @test !returnreplerror()
@suppress abstractlogic("noisy"); @test !returnreplerror()
@suppress abstractlogic("dash; dashboard"); @test !returnreplerror()

printcleaner(x) = replace(x, r"( |\n|–|\"|\t|Feasible|Perceived|Outcomes)"=>"")

@suppress abstractlogic("clear; a,b,c in 1")
output = (@capture_out abstractlogic("history")) |> printcleaner
@test  output == "Command#feasible#SessionStarted0a,b,c∈11<<present>>..."
@test (@capture_out abstractlogic("keys")) == "a, b, c\n"

output = (@capture_out abstractlogic("b")) |> printcleaner
@test output == "#SessionStarted-:1:1:111"

@suppress abstractlogic("n")
output = (@capture_out abstractlogic("a=b")) |> printcleaner
@test output == "a=b:1:1✓✓:111"

@suppress abstractlogic("silence")
@test (@capture_out abstractlogic("a ∈ 1,2 [clear]")) == ""

@suppress abstractlogic("noisy")
@test (@capture_out abstractlogic("a ∈ 1,2 [clear]")) != ""
