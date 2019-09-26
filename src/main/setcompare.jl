function setcompare(command::String, logicset::LogicalCombo; verbose=true)

    m = match(r"^(.*?)([⊂⊃⊅⊄⋂⋔!]{1,2}|(subset|superset|notsubset|notsuperset|intersect))(.*?)$",command)
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
   end

   return result
end
