using ReplMaker, Markdown

let
    keys() = println(join(replset.keys, ", "))

    global dashboard = false

    global replset = LogicalCombo()

    global setreplset!(x) = replset = x

    preserver = missing

    global activehistory = History()
    global setactivehistory!(x) = activehistory = x
    global pushactivehistory!(x) = push!(activehistory, x)

    global sessionhistory = History()
    global setsessionhistory!(x) = sessionhistory = x
    global pushsessionhistory!(x) = push!(sessionhistory, x)
    global popsessionhistory!() = pop!(sessionhistory)

    verboseall = true

    global replerror = false
    global replthrow(x) = (println(x) ; replerror = true)
    global returnreplerror() = replerror

    global preserver = missing
    global setpreserver!(x) = preserver = x

    global function abstractlogic(replinput; returnactive = false, verbose = true)
        replerror = false
        userinput = replinput |> strip |> tounicode

        userinput =  replace(userinput, r"^abstractlogic>"=>"") |> strip |> string

        verbose = verboseall & verbose & !occursin("[silent]", userinput)
        userinput = replace(userinput, "[silent]"=>"") |> strip |> string

        occursin("[clear]", userinput) && ALclear(verbose = verbose)
        userinput = replace(userinput, "[clear]"=>"") |> strip |> string

        if occursin(";;", userinput)
          for v in split(userinput, ";;");
              abstractlogic(v, verbose=verbose)
          end
          # userinput = "" # replace with return?
          returnactive && return replset
          return
        end

        # println("User input {$userinput}")

        if userinput == ""                                nothing(verbose = verbose)
        elseif (userinput[1] == '#')                      nothing(verbose = false)
        elseif occursin(r"⊥|dependenton|independentof", userinput)
            dependenton(userinput, replset, verbose = verbose)
        elseif occursin(r"[⊂⊃⊅⊄⋂⋔]|subset|superset|intersect|disjoint", userinput)
            setcompare(userinput, replset, verbose = verbose)
        elseif occursin(r"^t(est)?\(.*\)", userinput)                  testcall(userinput, verbose = verbose)
        elseif occursin(r"^(\?|help)", userinput)         help(userinput)
        elseif occursin(r"^show$", userinput)             ALshow(verbose = verbose)
        elseif occursin(r"^showall$", userinput)          ALshow(verbose = verbose, n = nfeasible(replset))
        elseif userinput ∈ ["back", "b"]                  ALback()
        elseif occursin(r"compare ", userinput)           ALcompare(userinput)
        elseif userinput ∈ ["discover", "d"]              discover(LogicalCombo())
        elseif occursin(r"^export( as){0,1} ", userinput) ALexport(userinput)
        elseif userinput ∈ ["next", "n", "f"]             ALnext(verbose = verbose)
        elseif occursin(r"^import ", userinput)           ALimport(userinput)
        elseif occursin(r"^dash(board)?$", userinput)     dashboard = !dashboard
        elseif userinput ∈ ["history", "h"]               Alhistory()
        elseif userinput ∈ ["History", "H"]               Alhistory(sessionprint=true)
        elseif userinput ∈ ["clearall", "Clear"]          ALClear(verbose = verbose)
        elseif occursin(r"^clear[ ]*$", userinput)        ALclear(verbose = verbose)
        elseif occursin(r"^range", userinput)             ALrange(userinput)
        elseif userinput ∈ ["keys", "k"]                  keys()
        elseif userinput == "preserve"                    ALpreserve()
        elseif userinput == "restore"                     ALrestore()
        elseif userinput == "silence"                     verboseall = false
        elseif userinput == "noisy"                       verboseall = true

        elseif occursin(r"^(prove|all|check|any|✓)", userinput) ALcheck(userinput)
        elseif occursin(r"^search", userinput)            ALsearch(userinput)
        else                                              ALparse(userinput, replset, verbose = verbose)
        end
        returnactive && return replset
        nothing
    end

end
"""
    abstractlogic(; returnactive = false)

Call the REPL from Julia. Setting returnactive to *true* returns the last active
logicset.

```julia
julia> abstractlogic("a, b, c in 1:3")
a, b, c ∈ 1:3            feasible outcomes 27 ✓          :1 1 3

julia> abstractlogic("a == b")
a == b                   feasible outcomes 9 ✓           :3 3 3

julia> abstractlogic("a > c")
a > c                    feasible outcomes 3 ✓           :3 3 1

julia> abstractlogic("c != 1")
c != 1                   feasible outcomes 1 ✓✓          :3 3 2

```
"""
abstractlogic = abstractlogic

function parse_to_expr(s)
   abstractlogic(s)

   # if dashboard
   #   # println("\nCommand Lists:" * string(replset.commands[end])
   #   # for v in showcommandlist()
   #   #     println(v)
   #   # end
   #   #
   #   # println("\nCommand Location:" * string(showcmdlocation()))
   #   # for v in showcommandhistory()
   #   #     println(v)
   #   # end
   #   #
   #   # println("\nLogicSet Lists:" * string(showsetlocation()))
   #   # for v in returnlogicset()
   #   #     println(join(collect(string(v))[1:(min(200,end))]))
   #   # end
   #   #
   # end
   nothing
end

"""
    replerror

Reports the error value of the most recently run repl command. Is defined as a
global in the `let block`.
"""
replerror = replerror

"""
    replset

Reports the value of the most recently run repl command. Is defined as a
global in the `let block`.

#### Example
```
abstractlogic> clear;; a, b in 1:2; a>b
Activeset Already Empty

a, b ∈ 1:2               Feasible Outcomes: 4    Perceived Outcomes: 4 ✓         :2 2
a>b                      Feasible Outcomes: 1    Perceived Outcomes: 1 ✓✓        :2 1

julia> replset |> nfeasible
1
```
"""
replset = replset
