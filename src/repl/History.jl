mutable struct History
    logicsets::Array
    current::Integer
end

function Base.push!(x::History, logicset::LogicalCombo)
  x.logicsets = [x.logicsets[1:x.current]..., logicset]
  x.current += 1
  x
end


function Base.pop!(x::History)
  pop!(x.logicsets)
  x.current -= 1
  x
end

update!(x::History, logicset::LogicalCombo) = x.logicsets[x.current] = logicset

activelogicset(x::History) = x.logicsets[x.current]
priorlogicsets(x::History) = x.logicsets[1:x.current]
futurelogicsets(x::History) = x.logicsets[(x.current+1):end]

back!(x::History) = x.current = (x.current > 0 ? x.current - 1 : 0)
next!(x::History) = x.current = (x.current < length(x.logicsets) ? x.current + 1 : x.current)

activecommand(x::History)  = activelogicset(x).commands[end]
priorcommands(x::History)  = priorlogicsets(x) .|> z -> z.commands[end]

function futurecommands(x::History)
  y = futurelogicsets(x)
  (length(y) == 0) && return String[]
  y .|> z -> z.commands[end]
end

History() = History([logicalparse("#Session Started", verbose = false)], 1)

# active = History()
# priorcommands(active)
# futurecommands(active)
#
# push!(active, logicalparse("x in 1:4", activelogicset(active) ) )
# push!(active, logicalparse("y in 1:4", activelogicset(active) ) )
# push!(active, logicalparse("z in 1:4", activelogicset(active) ) )
#
# activelogicset(active)
# priorlogicsets(active)
#
# activecommand(active)
# priorcommands(active)
#
# back!(active)
# back!(active)
# futurecommands(active)
# priorcommands(active)
#
# next!(active)
# push!(active, logicalparse("q in 1:4", activelogicset(active) ) )
# priorcommands(active)
