using AbstractLogic
using Test

# Basic logicparser features
abstractlogic("a = 1 [clear]", returnactive=true); @test replerror
abstractlogic("range abc", returnactive=true); @test replerror
abstractlogic("range a b", returnactive=true); @test replerror
abstractlogic("clear; a,b,c in 0:1; clear"); @test length(returnlogicset()) != 1
abstractlogic("clearall"); @test length(returnlogicset()) == 1
abstractlogic("a,b,c ∈ 0:1; a=b [clear]"); @test length(showlogichistory()) == 3

# Navigation
abstractlogic("back [clear]"); @test replerror
abstractlogic("next [clear]"); @test replerror
abstractlogic("a,b,c ∈ 0:1; back"); @test !replerror
abstractlogic("next"); @test !replerror
@test abstractlogic("", returnactive = true) |> nfeasible == 8

# Show
abstractlogic("show"); @test !replerror
abstractlogic("clear; show"); @test replerror

# Import/Export
abstractlogic("a,b in 1:2; export testset"); @test testset |> nfeasible == 4
@test abstractlogic("clear; import testset", returnactive = true) |> nfeasible == 4

# REPL Commands
abstractlogic("compare noname"); @test replerror
abstractlogic("keys"); @test !replerror
abstractlogic("d"); @test !replerror
abstractlogic("discover"); @test !replerror
abstractlogic("h"); @test !replerror
abstractlogic("history"); @test !replerror
abstractlogic("ls"); @test !replerror
abstractlogic("logicset"); @test !replerror

# Silence and noisy
@test abstractlogic("preserve; clear; restore", returnactive = true) |> nfeasible == 4
abstractlogic("silence", returnactive = true); @test !replerror
abstractlogic("noisy", returnactive = true); @test !replerror

using Suppressor
