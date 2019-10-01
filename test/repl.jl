using AbstractLogic
using Test
using Suppressor

@test (@capture_out abstractlogic("clearall")) == "Clearing Everything!\n"

# Basic logicparser features
@suppress abstractlogic("a = 1 [clear]"); @test replerror

@suppress abstractlogic("range abc"); @test replerror
@suppress abstractlogic("clear;; a,b,c in 1:2;; range a b"); @test !replerror
@suppress abstractlogic("a,b,c in 1:2;; range a [clear]"); @test !replerror

@suppress abstractlogic("check a==b"); @test !replerror
@suppress abstractlogic("a in 1; check z=1[clear]"); @test replerror

@suppress abstractlogic("clear; a,b,c in 0:1; clear"); @test nfeasible(replset) != 1
@suppress abstractlogic("clearall"); @test sessionhistory.current == 1
@suppress abstractlogic("a,b,c ∈ 0:1; a=b [clear]"); @test activehistory.current == 2

# Navigation
@suppress abstractlogic("back [clear]"); @test replerror
@suppress abstractlogic("next [clear]"); @test replerror
@suppress abstractlogic("a,b,c ∈ 0:1;; back"); @test !replerror
@suppress abstractlogic("next"); @test !replerror
@test @suppress abstractlogic("", returnactive = true) |> nfeasible == 8

# Show
@suppress abstractlogic("show"); @test !replerror
@suppress abstractlogic("clear;; show"); @test replerror

# Import/Export
@suppress abstractlogic("clear;; a,b in 1:2;; export testset"); @test testset |> nfeasible == 4
@test @suppress abstractlogic("clear;; import testset", returnactive = true) |> nfeasible == 4

# REPL Commands
@suppress abstractlogic("compare noname"); @test replerror
@suppress abstractlogic("keys"); @test !replerror
@suppress abstractlogic("d"); @test !replerror
@suppress abstractlogic("discover"); @test !replerror

x = @capture_out(abstractlogic("clear;; a,b in 1:2;; compare testset"))[(end-30):end]
  @test x == "lues. replset[:] == testset[:]\n"
x = @capture_out(abstractlogic("a = 1;; compare testset"))[(end-40):end]
  @test x == " nfeasible(replset) < nfeasible(testset)\n"
x = @capture_out(abstractlogic("d, e in 1:5;; compare testset"))[(end-40):end]
  @test x == " nfeasible(replset) > nfeasible(testset)\n"
x = @capture_out(abstractlogic("clear;; a ∈ 1:2;; export t2;; clear;; b ∈ 1:3; b>1 ;; compare t2 [silent]"))[(end-40):end]
  @test x == "ues. nfeasible(replset) == nfeasible(t2)\n"

@suppress abstractlogic("clear; a in 1; b = 1"); @test replerror

@suppress abstractlogic("clear;; a,b,c in 1:2;; search {{i}}>{{!i}}"); @test !replerror
@suppress abstractlogic("clear;; a,b,c in 1:2;; search z>z"); @test replerror


@suppress abstractlogic("h"); @test !replerror
@suppress abstractlogic("history"); @test !replerror

@suppress abstractlogic("clear ;; a in 1;; check aa = 1"); @test replerror

printcleaner(x) = replace(x, r"( |\n|–|\"|\t|Feasible|Perceived|Outcomes)"=>"")

@test (@capture_out abstractlogic("H")) == (@capture_out abstractlogic("History"))
@test (@capture_out abstractlogic("clearall;; H")) |> printcleaner ==
  "ClearingEverything!Command#feasible#SessionStarted0<<present>>..."

# Silence and noisy
@test @suppress abstractlogic("clear;; a,b in 1:2;; preserve;; clear;; restore", returnactive = true) |> nfeasible == 4
@suppress abstractlogic("silence"); @test !replerror
@suppress abstractlogic("noisy"); @test !replerror
@suppress abstractlogic("dash;; dashboard"); @test !replerror


@suppress abstractlogic("clear;; a,b,c in 1")
output = (@capture_out abstractlogic("history")) |> printcleaner
@test  output == "Command#feasible#SessionStarted0a,b,c∈11<<present>>..."
@test @capture_out(abstractlogic("keys")) == "a, b, c\n"

output = (@capture_out abstractlogic("b")) |> printcleaner
@test output == "#SessionStarted-:0"

@suppress abstractlogic("n")
output = (@capture_out abstractlogic("a=b")) |> printcleaner
@test output == "a=b:1:1✓✓:111"

@suppress abstractlogic("silence")
@test (@capture_out abstractlogic("a ∈ 1,2 [clear]")) == ""

@suppress abstractlogic("noisy")
@test (@capture_out abstractlogic("a ∈ 1,2 [clear]")) != ""

@test (@capture_out abstractlogic("clear;; a,b ∈ 1,2; a=b [silent]")) == ""
@capture_out(AbstractLogic.parse_to_expr("clear")) == "Clearing Activeset\n"

# Running all examples: examples 4 and 8 have been simplified to improve run speed
@test length(@capture_out abstractlogic("t(:)")) > 1000
@suppress abstractlogic("t(undefinedtest)"); @test replerror

# @suppress abstractlogic("t(1)")  ; @test replset |> nfeasible == 1
# @suppress abstractlogic("t(2)")  ; @test replset |> nfeasible == 6
# @suppress abstractlogic("t(3)")  ; @test replset |> nfeasible == 3
# @suppress abstractlogic("t(4)")  ; @test replset |> nfeasible == 6
# # @suppress abstractlogic("t(5)")  ; @test replset |> nfeasible == 12
