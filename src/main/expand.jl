function expand(x::LogicalCombo, mykeys::Union{Array{String},Array{String,1}}, myvalues::Union{Array{Any},Array{Int},Array{String,1}})
  isempty(mykeys) && return x

  keyset = map(x->Symbol(x), mykeys)
  mydomain = [myvalues for i in 1:length(mykeys)]

  (size(x)[2]==0) && return LogicalCombo(keyset, mydomain, fill(true,*(length.(mydomain)...)))

  foreach(y -> (y ∈ x.keys) && throw("key :$y already defined!") , keyset)

  expander = *(length.(mydomain)...)
  outlogical = fill(x.logical, each = expander)

  LogicalCombo([x.keys..., keyset...], [x.domain..., mydomain...], outlogical)
end

function expand(x::LogicalCombo; kwargs...)
  if isempty(kwargs)
    return x
  elseif size(x)[2]==0
    return LogicalCombo([kwargs...])
  else
    mykeys = []; mydomain = []
    for (kw, val) in kwargs;
        push!(mykeys, kw)
        push!(mydomain, val)
    end
  end

  foreach(y -> (y ∈ x.keys) && throw("key :$y already defined!") , mykeys)

  expander = *(length.(mydomain)...)
  outlogical = fill(x.logical, each = expander)

  LogicalCombo([x.keys..., mykeys...], [x.domain..., mydomain...], outlogical)
end

function expand(logicset::LogicalCombo, x::Union{Array{Pair{Symbol, Any}}, Array{Pair{Symbol,UnitRange{Int64}},1}})

    (length(logicset.keys) == 0) && return LogicalCombo(x)
    (length(x) == 0) && return logicset

    mykeys = []; mydomain = []
    for (kw, val) in x;
        push!(mykeys, kw)
        push!(mydomain, val)
    end

  foreach(y -> (y ∈ logicset.keys) && throw("key :$y already defined!"), mykeys)

  expander = *(length.(mydomain)...)
  outlogical = fill(logicset.logical, each = expander)

  LogicalCombo([logicset.keys..., mykeys...], [logicset.domain..., mydomain...], outlogical)
end
