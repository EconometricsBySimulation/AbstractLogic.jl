function operatorspawn(command,
    logicset::LogicalCombo;
    returnlogical=false,
    prefix=">>> ",
    verbose=true)

    logicsetcopy = deepcopy(logicset)

    tempcommand = command
    m = eachmatch(r"(\{\{.*?\}\})", tempcommand)
    matches = [replace(x[1], r"\{|\}"=>"") for x in collect(m)] |> unique

    # Check if a {{j}}. structure or {{J}}. structure exists
    m_dot = eachmatch(r"(\{\{[jJ]\}\})(\.[a-zA-Z0-9_.])", tempcommand)
    matches_dot = string.([x.captures[2] for x in collect(m_dot)]) |> unique

    if occursin(r"^[0-9]+,[0-9]+$", matches[end])
        countrange = (x -> x[1]:x[2])(integer.(split(matches[end], ",")))
        tempcommand = replace(tempcommand, "{{$(matches[end])}}"=>"") |> strip
        matches = matches[1:(end-1)]
    elseif occursin(r"^[0-9]+,$", matches[end])
        countrange = integer(matches[end][1:(end-1)]):size(logicset,2)^2
        tempcommand = replace(tempcommand, "{{$(matches[end])}}"=>"") |> strip
        matches = matches[1:(end-1)]
    elseif occursin(r"^,[0-9]+$", matches[end])
        countrange = 0:integer(matches[end][2:end])
        tempcommand = replace(tempcommand, "{{$(matches[end])}}"=>"") |> strip
        matches = matches[1:(end-1)]
    elseif occursin(r"^[0-9]+$", matches[end])
        countrange = (x -> x[1]:x[1])(integer(matches[end]))
        tempcommand = replace(tempcommand, "{{$(matches[end])}}"=>"") |> strip
        matches = matches[1:(end-1)]
    else
        countrange = missing
    end

    iSet  = [m for m in matches if m[end:end] ∈ ["i", "j", "J"]]
    # iSet1 = [m[1:1] for m in iSet]
    # iSet2 = [m[1:2] for m in iSet if length(m)>=2]

    iSetend = unique([replace(m, r".*(i|j).*$"=>s"\1") for m in matches if m[end:end] ∈ ["i", "j", "J"]])

    leftmodifier = [replace(m, r"(i|j).*$"=>"") for m in iSet]

    (leftmodifier[1] != "") && throw("i must be the first wildcard expressed")
    (length(iSet)>3) && throw("Only three !i, >i, >=i, <=i, <i wildcard allowed with i (or j/J)")
    (length(iSetend)>1) && throw("Only one type i or j wildcard allowed")
    (length(matches)>6) && throw("No more than 6 wildcard values allowed")

    mykeys   = keys(logicset)
    # Reduce the keyset if `j` or `J` are used
    any(occursin.("J", iSet)) && (mykeys = [v for v in mykeys if !occursin(".", string(v))])
    any(occursin.("j", iSet)) &&
      (mykeys = unique([Symbol(replace(v, r"\..*$"=>"")) for v in string.(mykeys)]))

    mydomain = 1:length(mykeys)

    collection = []

    verbose && println()

    iset = Symbol[]

    for i in mydomain, j in mydomain, k in mydomain
      (length(leftmodifier) < 2) && (j>1) && continue
      (length(leftmodifier) < 3) && (k>1) && continue

      if length(leftmodifier)  >= 2
          ("!"  == leftmodifier[2])  && (i   == j)   && continue
          (">"  == leftmodifier[2])  && (i   >= j)   && continue
          (">>" == leftmodifier[2])  && (i+1 >= j)   && continue
          ("<"  == leftmodifier[2])  && (i   <= j)   && continue
          ("<<" == leftmodifier[2])  && (i-1 <= j)   && continue
          (">=" == leftmodifier[2])  && (i   <  j)   && continue
          ("<=" == leftmodifier[2])  && (i   >  j)   && continue
      end

      if length(leftmodifier)  == 3
          ("!"  == leftmodifier[3])  && (i   == k)   && continue
          (">"  == leftmodifier[3])  && (i   >= k)   && continue
          (">>" == leftmodifier[3])  && (i+1 >= k)   && continue
          ("<"  == leftmodifier[3])  && (i   <= k)   && continue
          ("<<" == leftmodifier[3])  && (i-1 <= k)   && continue
          (">=" == leftmodifier[3])  && (i   <  k)   && continue
          ("<=" == leftmodifier[3])  && (i   >  k)   && continue
      end
      #println("$i and $j")

       txtcmd = tempcommand |> x -> replace(x, "!}}"=>"}}")

       # Sub out the j/i match in the command
       for m in [m for m in matches if occursin(r"^(i|j|J)", m)]
         txtcmd = subout(txtcmd, i, replace(m, r"\!$"=>""), mykeys)
       end

       (length(iSet) >= 2) && (txtcmd = subout(txtcmd, j, iSet[2], mykeys))
       (length(iSet) == 3) && (txtcmd = subout(txtcmd, k, iSet[3], mykeys))


       occursin("~~OUTOFBOUNDS~~", txtcmd) & !occursin("!}}", tempcommand) && continue

       if occursin("~~OUTOFBOUNDS~~", txtcmd) && occursin("!}}", tempcommand)
           txtcmd = replace(txtcmd, "~~OUTOFBOUNDS~~"=> "999" )
           # push!(collection, fill(false, length(logicset[:])))
       end
       # verbose &&  println(prefix * "$txtcmd")

       ℧∇ = logicset[:]

       try
           ℧∇ = superoperator(txtcmd, logicset, verbose=verbose)[:]
           verbose &&  println(prefix * "$txtcmd")
       catch
       end

       push!(collection, ℧∇)
       (length(matches_dot)==0) && push!(iset, mykeys[i])
       (length(matches_dot)>0)  && push!(iset, Symbol(string(mykeys[i]) * matches_dot[1]))
    end

    collector = hcat(collection...)

    returnlogical && return [collector, iset]

    if (countrange === missing)
      ℧Δ = logicset[:] .& [all(collector[i,:]) for i in 1:size(collector)[1]]
    else
      ℧Δ = logicset[:] .& [sum(collector[i,:]) ∈ countrange for i in 1:size(collector)[1]]
    end

    logicsetcopy[:] = ℧Δ
    logicsetcopy
end
