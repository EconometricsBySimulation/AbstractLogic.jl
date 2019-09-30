function testcall(userinput; verbose=true)

    testname = match(r"t(?:est)?\((.*)\)", userinput).captures[1]

    breaktext(x) = strip.(split(x, "\n")) |> (x -> x[x .!= ""])

    (testname == ":") && (testname = ",")

    testrange = 1:10

    if occursin(",", testname)
        left, right = match(r"(.*),(.*)", testname).captures
        (left == "")  && (left = string(minimum(testrange)))
        (right == "") && (right = string(maximum(testrange)))

        for i in integer(left):integer(right)
            println("\n");
            println(Crayons.Box.YELLOW_FG("abstractlogic> t($i)"))
            abstractlogic("t($i)")
        end
        testcalls = String[]
    elseif testname ∈ ["1"]
        testcalls = ["clear;; a,b,c ∈ 1:4; a|c = 1; a > b; b > c"]
    elseif testname ∈ ["hp", "2", "harrypotter"]
        testcalls =  """
        clear;; a, b, c, d, e, f, g  ∈  NW, MA, MB, PO
        {{i}} == 'NW' {{2}} ; {{i}} == 'MA' {{1}}
        {{i}} == 'MB' {{1}} ; {{i}} == 'PO' {{3}}
        {{i!}} == 'NW' ==> {{i-1}} == 'PO'
        a != g; a,g != 'MA'; c,f != 'PO'; b == f
        """ |> breaktext
    elseif  testname ∈ ["lsatq11", "3"]
        testcalls = """
        a, b, c, d, e  ∈  0:4 || unique [clear]
        b == a*2; c < e
        prove: e == 1 ==> a==2
        range
        prove: {{i}} == 1 &&& {{>i}} == 2 {{1}}
        prove: c != 0 ==> b == 2
        any: c == 0 &&& d == 1
        show
        prove: {{i}} == 1|2 ==> {{i+2}} == 1|2
        prove: {{i}} == 1|3 ==> {{i+4}} != 1,3
        """ |> breaktext
    elseif  testname ∈ ["lsatq12", "4"]
        println("This problem has been simplified for testing purposes")
        testcalls = """
        t.1, t.2, t.3, f.1, f.2, f.3  ∈  _, Greed, Harvest, Limelight [clear]
        {{j}}.3 != '_'
        {{j}}.1 != '_' ==> {{j}}.2 != '_'
        {{i}} == 'Greed' {{1,}}
        {{i}} == 'Harvest' {{1,}}
        {{i}} == 'Limelight' {{1,}}
        {{j}}.1 != '_' ==> {{j}}.1 != {{j}}.2 &&& {{j}}.1 != {{j}}.3 &&& {{j}}.2 != {{j}}.3
        t.3 = 'Harvest'
        f.3 = 'Greed'|'Limelight'; f.2,f.1 != 'Greed','Limelight'
        export lsat3
        check t.2 = 'Limelight' ; t.3 = 'Harvest' ; f.3 = 'Limelight'
        any {{i}} == 'Limelight' {{3,}}
        any f.1,f.2,f.3 |= 'Greed'
        t.0, f.0 ∈ Greed, Harvest, Limelight
        """  |> breaktext
    elseif  testname ∈ ["lsatq13", "5"]
        testcalls = """
        w1, w2, w3, w4, w5, w6, w7  ∈ Guadeloupe, Jamaica, Martinique, Trinidad [clear]
        {{i}} = 'Guadeloupe' {{1,}}
        {{i}} = 'Jamaica' {{1,}}
        {{i}} = 'Martinique' {{1,}}
        {{i}} = 'Trinidad' {{1,}}
        w4 != 'Jamaica'
        w7 = 'Trinidad'
        {{i}} = 'Martinique' {{2}}
        {{<i}} = 'Martinique' &&& {{>i}} = 'Martinique' &&& {{i}} = 'Guadeloupe' {{1,}}
        {{i!}} = 'Jamaica' ==> {{i-1}} = 'Guadeloupe'
        {{i}} != {{i+1}}
        export lsat4
        check w1 = 'Guadeloupe'; w2 = 'Jamaica'; w3 = 'Martinique'; w4 = 'Trinidad'; w5 = 'Guadeloupe'; w6 = 'Martinique'; w7 = 'Trinidad'
        check w1 = 'Guadeloupe'; w2 = 'Martinique'; w3 = 'Trinidad'; w4 = 'Martinique'; w5 = 'Guadeloupe'; w6 = 'Jamaica'; w7 = 'Trinidad'
        check w1 = 'Jamaica'; w2 = 'Martinique'; w3 = 'Guadeloupe'; w4 = 'Martinique'; w5 = 'Guadeloupe'; w6 = 'Jamaica'; w7 = 'Trinidad'
        check w1 = 'Martinique'; w2 = 'Trinidad'; w3 = 'Guadeloupe'; w4 = 'Jamaica'; w5 = 'Martinique'; w6 = 'Guadeloupe'; w7 = 'Trinidad'
        check w1 = 'Martinique'; w2 = 'Trinidad'; w3 = 'Guadeloupe'; w4 = 'Trinidad'; w5 = 'Guadeloupe'; w6 = 'Jamaica'; w7 = 'Martinique'
        check w6 = 'Trinidad';; check w5 = 'Martinique'
        check w6 = 'Jamaica';; check w3 = 'Jamaica'
        check w3 = 'Guadeloupe'
        w5 = 'Trinidad'
        check w1 = 'Trinidad';; check w2 = 'Martinique'
        check w3 = 'Guadeloupe';; check w4 = 'Martinique'
        check w6 = 'Jamaica'
        import lsat4
        w1 = 'Guadeloupe'; w5 = 'Jamaica'
        check w2 = 'Jamaica';; check w2 = 'Trinidad'
        check w3 = 'Martinique';; check w6 = 'Guadeloupe'
        check w6 = 'Martinique'
        import lsat4
        w1 = 'Guadeloupe'; w2 = 'Trinidad'
        prove w3 = 'Martinique';; prove w4 = 'Martinique'
        prove w5 = 'Martinique';; prove w3 = 'Guadeloupe'
        prove w5 = 'Guadeloupe'
        import lsat4
        w3 = 'Martinique'
        any w4 = 'Guadeloupe'; w5 = 'Trinidad'
        any w4 = 'Jamaica'; w5 = 'Guadeloupe'
        any w4 = 'Martinique'; w5 = 'Trinidad'
        any w4 = 'Trinidad'; w5 = 'Jamaica'
        any w4 = 'Trinidad'; w5 = 'Martinique'
        import lsat4
        check w1|w2 = 'Guadeloupe'
        w1,w2 != 'Guadeloupe'
        check w2|w3 = 'Martinique'
        check {{i}} = 'Guadeloupe' {{,2}}
        check {{i}} = 'Jamaica' {{,2}}
        check {{i}} = 'Trinidad' {{,2}}
        """  |> breaktext
    elseif  testname ∈ ["lsatonlineq1", "6"]
        testcalls = """
        G, L, M, N, P, R, S, W ∈ red, not [clear]
        G, S = 'red' ==> W = 'red'
        N = 'red' ==> R, S = 'not'
        P = 'red' ==> L = 'not'
        L|M|R = 'red' {2}
        M, R = 'red'
        all: G, L = 'not'
        all: G, N = 'not'
        all: L, N = 'not'
        all: L, P = 'not'
        all: P, S = 'not'
        T, U, V, W, X, Y, Z ∈ unique [clear]
        X != 1,2
        W > X
        T,Y != 7
        Y|Z = W + 1
        V = U + 1 ||| V = U - 1
        """ |> breaktext
    elseif  testname ∈ ["lsatonlineq2", "7"]
        testcalls = """
        T, U, V, W, X, Y, Z ∈ unique [clear]
        X != 1,2
        W > X
        T,Y != 7
        Y|Z = W + 1
        V = U + 1 ||| V = U - 1
        export preserver
        V = 1
        all: T = 6
        all: X = 3
        all: Z = 7
        all: T = Y + 1
        all: W = X + 1
        import preserver
        U = 3
        range Y
        """ |> breaktext
    elseif  testname ∈ ["lsatonlineq3", "8"]
        println("This problem has been simplified for testing purposes")
        testcalls = """
        q1.m, q1.t, q1.w, q1.y ∈ 0:1 [clear]
        q2.m, q2.t, q2.w, q2.y ∈ 0:1
        q3.m, q3.t, q3.w, q3.y ∈ 0:1
        {{>=:q1.m,<=:q1.y}} == 1 {{1,}}
        {{>=:q2.m,<=:q2.y}} == 1 {{1,}}
        {{>=:q3.m,<=:q3.y}} == 1 {{1,}}
        {{j}}.m = 1 {{1,}}
        {{j}}.t = 1 {{1,}}
        {{j}}.w = 1 {{1,}}
        {{j}}.y = 1 {{1,}}
        {{i}} = 1 {{,6}}
        {{j}}.m = 1 ==> {{j+1}}.m != 1; {{j}}.t = 1 ==> {{j+1}}.t != 1
        {{j}}.w = 1 ==> {{j+1}}.w != 1; {{j}}.y = 1 ==> {{j+1}}.y != 1
        {{j}}.m = 1 {{2}}
        q2.w = 1
        export preserver
        {{j}}.w = 1 &&& {{j}}.y = 1 {{1,}}
        any: q2.m = 1
        J, K, L, M, N, P, Q ∈ 0:1 [clear]
        {{i}} = 1 {{4}}
        J ^ K
        N ^ P
        L! ==> N!
        K! ==> !Q
        export preserver
        P = 1
        show
        import preserver
        check: J == 1 &&& L == 1
        """ |> breaktext
    elseif  testname ∈ ["lsatonlineq4", "9"]
        testcalls = """
        J, K, L, M, N, P, Q ∈ 0:1 [clear]
        {{i}} = 1 {{4}}
        J ^ K
        N ^ P
        L! ==> N!
        K! ==> !Q
        export preserver
        P = 1
        show
        import preserver
        check: J == 1 &&& L == 1
        check: K == 1 &&& M == 1
        check: L == 1 &&& N == 1
        check: L == 1 &&& Q == 1
        check: M == 1 &&& Q == 1
        """ |> breaktext
    elseif  testname ∈ ["lsatonlineq5", "10"]
        testcalls = """
        s, h, j, k, l, m ∈ unique [clear]
        s = h + 1
        k < s
        m < l
        m = j + 1 ||| m = j - 1
        l < k
        range h
        """ |> breaktext
    else
        (testname != "") && replthrow("Test " * testname * " not found!")
        printmarkdown("Tests available: " * join(testrange, ", "))
        testcalls = String[]
    end

    for v in testcalls
        print(Crayons.Box.GREEN_FG("\nabstractlogic> "))
        println(v)
        abstractlogic(v)
        replerror && throw("Testcall Error")
    end
end



# function testcall(userinput; verbose=true)
#
#     testname = match(r"t(?:est)?\((.*)\)", userinput).captures[1]
#
#     folders = readdir()
#     ("examples" ∈ folders) && (testfiles = readdir("examples/repl/"))
#     !("examples" ∈ folders) && (testfiles = readdir("../examples/repl/"))
#
#     testfiles = testfiles .|> x -> replace(x, r".jl$"=>"") |> lowercase
#
#     occursin(r"^[0-9]{1,2}$", testname) && (testname = testfiles[parse(Int64, testname)])
#
#     (testname == "") && return printmarkdown("Tests available: `" * join(testfiles, "`, `") *
#         "`\n \n `abstractlogic> t(testname)`")
#
#     !(testname ∈ testfiles) &&
#       return replthrow("\"$testname\" not found. Tests available: " * join(testfiles, ", "))
#
#     ("examples" ∈ folders) && (testread = readlines("examples/repl/$testname.jl"))
#     !("examples" ∈ folders) && (testread = readlines("../examples/repl/$testname.jl"))
#
#     testread = (testread.|> x -> strip(x)) |> x -> x[x .!= ""] |> x -> x[(x .|> y -> y[1]) .!= '#']
#
#     codestart = findall(y -> occursin(r"^Start the repl", y), testread)
#
#     (length(codestart) == 0) && return replthrow("\"Start the repl\" not found!")
#     (length(codestart) > 1 ) && return replthrow("Multiple \"Start the repl\" found!")
#
#     testlines = testread[(codestart[1]+1):end]
#
#     for v in testlines
#         println(Crayons.Box.GREEN_FG("\nabstractlogic> " * replace(v, "abstractlogic> "=> "")))
#         abstractlogic(v)
#         replerror && throw("")
#     end
# end
