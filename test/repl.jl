using AbstractLogic
using Test
using Suppressor

# Basic logicparser features
abstractlogic("a = 1 [clear]"); @test returnreplerror()
abstractlogic("range abc"); @test returnreplerror()
abstractlogic("range a b"); @test returnreplerror()
abstractlogic("clear; a,b,c in 0:1; clear"); @test nfeasible(returnreplset()) != 1
abstractlogic("clearall"); @test length(returnlogicset()) == 1
abstractlogic("a,b,c ∈ 0:1; a=b [clear]"); @test length(showlogichistory()) == 1

# Navigation
abstractlogic("back [clear]"); @test returnreplerror()
abstractlogic("next [clear]"); @test returnreplerror()
abstractlogic("a,b,c ∈ 0:1; back"); @test !returnreplerror()
abstractlogic("next"); @test !returnreplerror()
@test abstractlogic("", returnactive = true) |> nfeasible == 8

# Show
abstractlogic("show"); @test !returnreplerror()
abstractlogic("clear; show"); @test returnreplerror()

# Import/Export
abstractlogic("a,b in 1:2; export testset"); @test testset |> nfeasible == 4
@test abstractlogic("clear; import testset", returnactive = true) |> nfeasible == 4

# REPL Commands
abstractlogic("compare noname"); @test returnreplerror()
abstractlogic("keys"); @test !returnreplerror()
abstractlogic("d"); @test !returnreplerror()
abstractlogic("discover"); @test !returnreplerror()
abstractlogic("h"); @test !returnreplerror()
abstractlogic("history"); @test !returnreplerror()
abstractlogic("ls"); @test !returnreplerror()
abstractlogic("logicset"); @test !returnreplerror()

# Silence and noisy
@test abstractlogic("clear; a,b in 1:2; preserve; clear; restore", returnactive = true) |> nfeasible == 4
abstractlogic("silence"); @test !returnreplerror()
abstractlogic("noisy"); @test !returnreplerror()
abstractlogic("dash; dashboard"); @test !returnreplerror()

printcleaner(x) = replace(x, r"( |\n|–|\"|\t|Feasible|Perceived|Outcomes)"=>"")

abstractlogic("clear; a,b,c in 1")
output = (@capture_out abstractlogic("history")) |> printcleaner
@test  output == "Command#feasible#SessionCleared0a,b,c∈11<<present>>..."
@test (@capture_out abstractlogic("keys")) == "a, b, c\n"

output = (@capture_out abstractlogic("b")) |> printcleaner
@test output == "Lastcommand:#SessionCleared-:0:1:Any[]"

abstractlogic("n")
output = (@capture_out abstractlogic("a=b")) |> printcleaner
@test output == "a=b:1:1✓✓:111"

@test (@capture_out abstractlogic("clear [silent]")) == ""
