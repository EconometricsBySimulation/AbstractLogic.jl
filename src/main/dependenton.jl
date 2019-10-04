"""
   dependenton(command::String, logicset::LogicalCombo; verbose=true)

Checks whether variables on the left of the infix operator (⊥) depend for their
distribution on variables on the right of the operator.

#### Operators

* x ⊥ y: checks if the distribution of potential values of x does not change when y changes.
**Alternatively:** x independentof y

* x !⊥ y: checks if the distribution of potential values of x changes when y changes.
**Alternatively:** x dependenton y

#### Examples - API

```
julia> logicset = logicalparse("a, b, c ∈ 1:4; a > b", verbose=false)

julia> dependenton("a ⊥ c", logicset)
True: a is independent of c
true

julia> dependenton("a ⊥ b", logicset)
False: a is dependent on b
range( a | b == b ) =   {}
––––––––––––––––––– – –––––––
range( a | b == 1 ) = {2,3,4}
range( a | b == 2 ) =  {3,4}
range( a | b == 3 ) =   {4}
false

julia> dependenton("a !⊥ b", logicset)
a is dependent on b
true
```

#### Examples - REPL

```
abstractlogic> a, b, c ∈ 1:4; a > b [clear]
Activeset Already Empty

a, b, c ∈ 1:4            Feasible Outcomes: 64   Perceived Outcomes: 64 ✓        :1 4 2
a > b                    Feasible Outcomes: 24   Perceived Outcomes: 36 ✓        :4 2 1

abstractlogic> a ⊥ c
True: a is independent of c

abstractlogic> a ⊥ b
False: a is dependent on b
range( a | b == b ) =   {}
––––––––––––––––––– – –––––––
range( a | b == 1 ) = {2,3,4}
range( a | b == 2 ) =  {3,4}
range( a | b == 3 ) =   {4}

abstractlogic> a !⊥ b
True: a is dependent on b
```
"""
function dependenton(command::String, logicset::LogicalCombo; verbose=true)

    m = match(r"^(.*?)([⊥!]{1,2}|(dependenton|independentof))(.*?)$",command)
    left, operator, right  = m.captures[[1,2,4]] .|> strip

    ranges = range(logicset)

    rightranges = ranges[Symbol(right)]
    (length(rightranges) == 1) && return println("$left cannot vary in $right if right is constant!")

    leftranges = ranges[Symbol(left)]
    (length(rightranges) == 1) && return println("$left cannot vary in $right if left is constant!")

    leftsets =
      [range(logicalparse("$right = $v", logicset=logicset, verbose=false))[Symbol(left)]
      for v in rightranges ]

    independence = all(length.(leftsets) .== length(leftranges))
    indeptext = (independence ? "independent of" : "dependent on")

    (operator == "⊥")  && independence &&
      return (verbose && println("True: $left is $indeptext $right"); true)
    (operator == "!⊥") && !independence &&
      return (verbose && println("True: $left is $indeptext $right"); true)

   if verbose
       println("False: $left is $indeptext $right")
       txtout = "| " * join(["range( $left \\| $right == $right )", " = ", "{}"], " | ") * " | \n"
       txtout *= "| " * join(fill(":---:", 3), " | ") * " | \n"
       for i in 1:length(rightranges)
         txtout *= "| " * "range( $left \\| $right == $(rightranges[i]) ) " * " | = | {" *
           join(leftsets[i], ",") * "} | \n"
       end
       printmarkdown(txtout)
       println()
   end

   return false
end
