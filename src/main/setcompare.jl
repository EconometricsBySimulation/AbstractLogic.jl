"""
    setcompare(command::String, logicset::LogicalCombo; verbose=true)

Provides a mechanism for checking if a set made up of possible values a variable can take is a subset of another set.

#### Operatators
In the repl this function is called by the use of set operators.

* x ⊂ y: checks if the values x can take are all contained within the set y
**Alternatively:** x subset y

* x !⊂ y: checks if one or more of the values x can take are not within the set y
**Alternatively:** x notsubset y

* x ⊃ y: checks if the values y can take are all contained within the set x
**Alternatively:** x superset y

* x !⊃ y: checks if one or more of the values y can take are not within the set x
**Alternatively:** x notsuperset y

* x ⋂ y: checks if set x intersects set y, that is if any values of x are in y
**Alternatively:** x intersect y

* x ⋔ y:  checks if set x is disjoint from set y, that is no values of x are in y
**Alternatively:** x notintersect y, x !⋂ y, x disjoint y

#### Set Unions and Intersections
The left and right hand side of the set operator can also be constructed from
multiple sets joined together with either the `|` (or ,) operator or using the intersetion
of the set using the `&` operator.

#### Examples - API
```
julia> logicset = logicalparse("a, b, c ∈ 1:4; a > b", verbose=false)

julia> setcompare("a ⊂ c", logicset)
  a   ⊂    c    result
––––– – ––––––– ––––––
2,3,4 ⊂ 1,2,3,4  true
true

julia> setcompare("a !⊃ c", logicset)
  a   !⊃    c    result
––––– –– ––––––– ––––––
2,3,4 !⊃ 1,2,3,4  true
true
```
#### Examples - REPL
```
abstractlogic> a, b, c ∈ 1:4
a, b, c ∈ 1:4            Feasible Outcomes: 64   Perceived Outcomes: 64 ✓        :1 1 4

abstractlogic> a > b
a > b                    Feasible Outcomes: 24   Perceived Outcomes: 36 ✓        :3 2 2

abstractlogic> a ⊂ c
  a   ⊂    c    result
––––– – ––––––– ––––––
2,3,4 ⊂ 1,2,3,4  true

abstractlogic> a !⊃ c
  a   !⊃    c    result
––––– –– ––––––– ––––––
2,3,4 !⊃ 1,2,3,4  true

abstractlogic> a ⋂ b
  a   ⋂   b   result
––––– – ––––– ––––––
2,3,4 ⋂ 1,2,3  true

abstractlogic> a | b superset c
 a | b  superset    c    result
––––––– –––––––– ––––––– ––––––
2,3,4,1 superset 1,2,3,4  true

abstractlogic> a & b ⊃ c
a & b ⊃    c    result
––––– – ––––––– ––––––
 2,3  ⊃ 1,2,3,4 false
```
"""
function setcompare(command::String, logicset::LogicalCombo; verbose=true)

    m = match(r"^(.*?)([⊂⊃⊅⊄⋂⋔!]{1,2}|(notsubset|notsuperset|notintersect|disjoint|subset|superset|intersect))(.*?)$",command)
    left, operator, right  = m.captures[[1,2,4]] .|> strip

    ranges = range(logicset)

    occursin(r"(&.*\|)|(\|.*&)", left) && thow("\n | and & cannot both appear left of operator!")
    if occursin("&", left)
        leftrange = intersect([ranges[Symbol(v)] for v in strip.(split(left, r",|&"))]...)
    else
        leftrange = union([ranges[Symbol(v)] for v in strip.(split(left, r",|\|"))]...)
    end

    occursin(r"(&.*\|)|(\|.*&)", right) && thow("\n | and & cannot both appear right of operator!")
    if occursin("&", right)
        rightrange = intersect([ranges[Symbol(v)] for v in strip.(split(right, r",|&"))]...)
    else
        rightrange = union([ranges[Symbol(v)] for v in strip.(split(right, r",|\|"))]...)
    end

    ⊂(x,y) = all([v ∈ y for v in x]) # subset of
    ⋲(x,y) = any([v ∈ y for v in x]) # intersects with

   (operator ∈ ["⊂", "subset"]) && (result =  (leftrange ⊂ rightrange))
   (operator ∈ ["⊄", "!⊂", "notsubset"]) && (result = !(leftrange ⊂ rightrange))
   (operator ∈ ["⊃", "superset"]) && (result =  (rightrange ⊂ leftrange))
   (operator ∈ ["⊅", "!⊃", "notsubset"]) && (result = !(rightrange ⊂ leftrange))
   (operator ∈ ["⋂", "intersect"]) && (result =  (leftrange ⋲ rightrange))
   (operator ∈ ["!⋂", "⋔", "notintersect"]) && (result = !(leftrange ⋲ rightrange))

   leftjoin  = join(leftrange, ",")
   rightjoin = join(rightrange, ",")
   excaped(x) = replace(x, "|"=>"\\|")

   if verbose
       txtout = "| " * join([excaped.(left),operator,excaped.(right),"result"], " | ") * " | \n"
       txtout *= "| " * join(fill(":---:", 4), " | ") * " | \n"
       txtout *= "| " * join([leftjoin,operator,rightjoin,result], " | ") * " | \n"
       printmarkdown(txtout)
       println()
   end

   return result
end
