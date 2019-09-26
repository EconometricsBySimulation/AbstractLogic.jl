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
      return (verbose && println("$left is $indeptext $right"); true)
    (operator == "!⊥") && !independence &&
      return (verbose && println("$left is $indeptext $right"); true)

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
