logicset = logicalparse("a, b, c ∈ 1:3")
logicset |> showfeasible

logicalparse("a ∈ 1:3; b ∈ 1:2; c ∈ 2:3") |> showfeasible

logicalparse("a, b, c ∈ 1:3; a,c != b; a != c")[:,:,:]

logicalparse("a, b, c ∈ 1:3; a == b XOR a == c") |> showfeasible
logicalparse("a, b, c ∈ 1:3; a == b ^^^^ a == c")|> showfeasible
logicalparse("a, b, c ∈ 1:3; a == b xor a == c")|> showfeasible
logicalparse("a, b, c ∈ 1:3; a == b ^^^ a == c")|> showfeasible
logicalparse("a, b, c ∈ 1:3; a ^= b , c ")|> showfeasible

logicalparse("a, b, c ∈ 1:3; a, b ^= 1")|> showfeasible

logicalparse("a, b    ∈ 0:1; a ^ b") |> showfeasible
logicalparse("a, b, c ∈ 0:1; a ! b") |> showfeasible
logicalparse("a, b, c ∈ 0:1; a & b & c") |> showfeasible
logicalparse("a, b, c ∈ 1:2; !a; &b") |> showfeasible

logicalparse("a, b, c ∈ 1:3; a == b === a != c")|> showfeasible
logicalparse("a, b, c ∈ 1:3; a == b <=> a != c")|> showfeasible

logicalparse(["a, b, c, d, e ∈ 1:5", "{{i}} != {{!i}}"])|> showfeasible
logicalparse(["a, b, c, d, e ∈ 1:5", "{{i}} != {{>i}}"])|> showfeasible

#logicset = logicalparse(["a, b, c, d, e, f  ∈ 6"]); logicset[℧]

logicalparse(["a, b, c ∈ 1:6", "{{i}} == {{!i}}"])|> showfeasible
logicalparse(["a, b, c ∈ 1:6", "{{i}} != {{>i}}"])|> showfeasible

logicalparse(["a, b, c ∈ 1:6", "{{i}} > {{!i}}"])|> showfeasible
logicalparse(["a, b, c ∈ 1:6", "{{i}} > {{>i}}"])|> showfeasible

logicalparse(["a, b, c  ∈  1:3", "b != a,c", "c =| 1,2"])|> showfeasible
logicalparse(["a, b, c  ∈  1:3", "{{i}} != {{!i}}"])|> showfeasible

logicalparse(["a, b, c  ∈  [1,2,3]", "a|b = 1"])|> showfeasible
logicalparse(["a, b, c ∈ 1:3", "a | b"])|> showfeasible

logicalparse(["a, b, c ∈ 1:3", "a|b|c"])|> showfeasible
logicalparse(["a, b, c ∈ 1:3", "a | b | c"])|> showfeasible

logicalparse(["a, b, c ∈ 1:3", "a,b,c = 1"])|> showfeasible
logicalparse(["a, b, c ∈ 1:3", "a & b & c"])|> showfeasible

logicalparse(["a, b, c ∈ 0:2", "a,b,c = 0"])|> showfeasible
logicalparse(["a, b, c ∈ 0:2", "a ! b ! c"])|> showfeasible


logicalparse(["a, b, c  ∈  [1,2,3]"])|> showfeasible

# At least 2 less/more >> or <<
logicalparse(["a, b, c  ∈  [1,2,3]", "a << b"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3]", "a >> b"])|> showfeasible

logicalparse(["a, b, c  ∈  [1,2,3]", "a,b ^= 1"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3]", "a=1 ^^^ b=1"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3]", "a=1 ^^^^ b=1"])|> showfeasible


# All equal commands
logicalparse(["a, b, c  ∈  [1,2,3]", "a,b |=   1"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3]", "a=1 |||  b = 1"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3]", "a=1 |||| b = 1"])|> showfeasible

# logicalparse(["a, b, c  ∈  [1,2,3]", "a,b ^=   1"])|> showfeasible

logicalparse(["a, b, c  ∈  [1,2,3]", "a|b = 1 ||| c == 1"])|> showfeasible

logicalparse(["a, b, c  ∈  [1,2,3,4]"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3,4]", "{{i}} == {{!i}}"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3,4]", "{{i}} != {{!i}}"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3,4]", "{{i}} > {{>i}}"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3,4]", "{{i}} > {{i+1}} {{2,3}}"])|> showfeasible

logicalparse(["a, b, c  ∈  [1,2,3]", "{{i}} == 1 {{2}}"])|> showfeasible

logicalparse(["a, b, c  ∈  [1,2,3,4]", "{{j}} > {{j+1}}"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3,4]", "{{i}} > {{i+1}} {{0}}"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3,4]", "{{j}} <= {{j+1}}"])|> showfeasible

logicalparse(["a, b, c, d  ∈  [1,2,3,4]", "{{i}} != {{!i}}"])|> showfeasible
logicalparse(["a, b, c, d  ∈  [1,2,3,4]", "{{i}} != {{!i}} {{0}}"])|> showfeasible

logicalparse(["a, b, c, d  ∈  [1,2,3,4]", "{{i}} = 2 {{2,3}}"])|> showfeasible # ??????????????????????
logicalparse(["a, b, c, d  ∈  [1,2,3,4]", "{{i}} != {{!i}} {{1,5}}"])|> showfeasible

logicalparse(["a, b, c  ∈  [1,2,3,4]", "{{j}} > {{j+1}}"])|> showfeasible

logicalparse(["a, b  ∈  [1,2,3]", "a|b = 1 {1}"])|> showfeasible
logicalparse(["a, b  ∈  [1,2,3]", "a|b = 1 {0}"])|> showfeasible

logicalparse(["a, b, c  ∈  [1,2,3]", "b != a,c", "c =| 1,2 {1}"])|> showfeasible

logicalparse(["a, b, c  ∈  [1,2,3]", "b != a,c", "c == 1|2"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3]", "a < b,c",  "c |= 1,2"]);logicset[℧,:]
logicalparse(["a, b, c  ∈  [1,2,3]", "b < 3 |=> a = b"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3]", "a == b <=| b << 3"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3]", "a == 1 <=> b == c"])|> showfeasible
logicalparse(["a, b, c  ∈  [1,2,3]", "a <= b,c", "c |= 1,2"])|> showfeasible

logicalparse(["a, b, c     ∈  [1,2,3]", "b , a == c-1", "c |= 1,2"])|> showfeasible
logicalparse(["a, b, c     ∈  [1,2,3]", "a == c+b"])|> showfeasible
logicalparse(["a, b, c, d  ∈  [1,2,3,4]", "a , b |= c, d"])|> showfeasible
logicalparse(["a, b, c, d  ∈  [1,2,3,4]", "a != b, c, d", "b != c,d", "c != d"])|> showfeasible
logicalparse(["a, b, c, d  ∈  [1,2,3,4]", "a != b, c, d", "b != c,d", "c != d", "a == c+1", "d == a*2"])|> showfeasible

logicalparse(["a, b, c  ∈  [1,2,3]", "b != a,c", "c =| 1,2"])|> showfeasible

logicalparse(["a, b, c, d, e, f, g  ∈  [1,2,3,4]", "a,b,c,d,e,f,g == 1 +++ a,b,c,d,e,f,g == 1 ==== 2"])|> showfeasible

logicalparse(["a, b, c     ∈  [1,2,3]", "b , a == c-1"])|> showfeasible

logicset = logicalparse("a, b, c ∈ 1:3; a = b|c; a = b ==> b = c+1")
logicset = logicalparse("a = c ==> c = b - 1; c = 2 ||| a=3", logicset)
logicset |> showfeasible

checkfeasible("a = 2", logicset)[1]
checkfeasible("b = 3", logicset)[1]
checkfeasible("c = 1", logicset)[1]
checkfeasible("{{i}} > 1", logicset)[2]
checkfeasible("{{i}} < 3 {{2}}", logicset)[2]

logicset |> showfeasible

search("{{i}} = 3", logicset)
search("{{i}} > 2", logicset)
search("{{i}} > {{i-1}}", logicset)

logicset = logicalparse(["a,b,c ∈  1,2,3"])
logicset = logicalparse(["d,e,f ∈  1,3"], logicset)
