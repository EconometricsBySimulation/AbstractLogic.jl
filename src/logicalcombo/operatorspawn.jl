function operatorspawn(command,
    logicset::LogicalCombo;
    returnlogical=false,
    prefix=">>> ",
    verbose=true,
    printall=false)

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
        constraintprint = "{{" * matches[end]  * "}}"
        matches = matches[1:(end-1)]
    elseif occursin(r"^[0-9]+,$", matches[end])
        countrange = integer(matches[end][1:(end-1)]):size(logicset,2)^2
        tempcommand = replace(tempcommand, "{{$(matches[end])}}"=>"") |> strip
        constraintprint = "{{" * replace(matches[end], r",$"=>",∞") * "}}"
        matches = matches[1:(end-1)]
    elseif occursin(r"^,[0-9]+$", matches[end])
        countrange = 0:integer(matches[end][2:end])
        tempcommand = replace(tempcommand, "{{$(matches[end])}}"=>"") |> strip
        constraintprint = "{{" *  replace(matches[end], r"^,"=>"0,")  * "}}"
        matches = matches[1:(end-1)]
    elseif occursin(r"^[0-9]+$", matches[end])
        countrange = (x -> x[1]:x[1])(integer(matches[end]))
        tempcommand = replace(tempcommand, "{{$(matches[end])}}"=>"") |> strip
        constraintprint = "{{" *  matches[end]  * "}}"
        matches = matches[1:(end-1)]
    else
        countrange = missing
        constraintprint = ""
    end

    ijJ = map(x -> x[1], eachmatch(r"(?:\b)(j|J|i)(?:\b)", join(matches, " "))) |>
              unique .|> string

    mykeys   = keys(logicset)
    # Reduce the keyset if `j` or `J` are used
    # Remove variables that have attributes
    (length(ijJ)>0) && (ijJ[1] == "J") && (mykeys = [v for v in mykeys if !occursin(".", string(v))])
    # Remove attributes but keep variable names
    (length(ijJ)>0) && (ijJ[1] == "j") && (mykeys = unique([Symbol(replace(v, r"\..*$"=>"")) for v in string.(mykeys)]))

    rangematches = matches[occursin.(r">|<|!.+$" , matches)]
    imatches = matches[.!occursin.(r">|<|!.+$" , matches)]
    imatches = [replace(v , "!"=>"") for v in imatches]

   function firstmatch(x::String, y::Array{String})
     for i in 1:length(y)
         (x == y[i]) && return i
     end
   end

   rangematches0 = copy(rangematches)

    for v in 1:length(rangematches)
      m = eachmatch(r"(:[a-zA-Z][a-zA-Z0-9._]*)", rangematches[v])
      for vv in collect(m)
        rangematches[v] =
        replace(rangematches[v], string(vv[1]) => firstmatch(string(vv[1])[2:end], string.(mykeys)))
      end
    end

    (length(rangematches)>3) && throw("Only three !i, >i, >=i, <=i, <i wildcard allowed with i (or j/J)")
    (length(ijJ)>1)     && throw("Only one type i or j or J wildcard allowed")
    (length(matches)>6) && throw("No more than 6 wildcard values allowed")

    mydomain = 1:length(mykeys)

    collection = []

    txtoutarray = String[]

    iset = Symbol[]

    for i in mydomain, j in mydomain, k in mydomain, l in mydomain
      (length(imatches) == 0) && (i>1) && continue
      (length(rangematches) < 1 ) && (j>1) && continue
      (length(rangematches) < 2 ) && (k>1) && continue
      (length(rangematches) < 3 ) && (l>1) && continue

      txtcmd = tempcommand |> x -> replace(x, "!}}"=>"}}")

        for v in imatches
          txtcmd = subout(txtcmd, i, v, mykeys)
        end

        if length(rangematches)  >= 1
            splitthenskipcheck(rangematches[1], i, j) && continue
            txtcmd = replace(txtcmd, "{{" * rangematches0[1] * "}}" => String(mykeys[j]))
        end
        if length(rangematches)  >= 2
            splitthenskipcheck(rangematches[2], i, k) && continue
            txtcmd = replace(txtcmd, "{{" * rangematches0[2] * "}}" => String(mykeys[k]))
        end
        if length(rangematches)  >= 3
            splitthenskipcheck(rangematches[3], i, l) && continue
            txtcmd = replace(txtcmd, "{{" * rangematches0[3] * "}}" => String(mykeys[l]))
        end

        occursin("~~OUTOFBOUNDS~~", txtcmd) & !occursin("!}}", tempcommand) && continue

        if occursin("~~OUTOFBOUNDS~~", txtcmd) && occursin("!}}", tempcommand)
           txtcmd = replace(txtcmd, "~~OUTOFBOUNDS~~"=> "999" )
           # push!(collection, fill(false, length(logicset[:])))
        end
        # verbose &&  println(prefix * "$txtcmd")

        ℧∇ = logicset[:]

        try
           verbose && push!(txtoutarray, "`$prefix` $txtcmd")
           ℧∇ = superoperator(txtcmd, logicset, verbose=verbose)[:]
           # verbose && (txtoutarray[end] *= " ✔")
        catch
           verbose && (txtoutarray[end] *= " X")
        end

       push!(collection, ℧∇)
       (length(matches_dot)==0) && push!(iset, mykeys[i])
       (length(matches_dot)>0)  && push!(iset, Symbol(string(mykeys[i]) * matches_dot[1]))
    end

    !printall && (length(txtoutarray)>4) &&
      (txtoutarray = [txtoutarray[1:2]..., " ... ", txtoutarray[end .- (1:-1:0)]...])

    verbose && push!(txtoutarray, constraintprint)

    verbose && (printmarkdown(join(txtoutarray, " ")); println())

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
