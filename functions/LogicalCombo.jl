
struct LogicalCombo
  keys::NamedTuple
  logical::AbstractArray{Bool}
end

x = LogicalCombo((a=1:2,b=1:2), fill(true, 4))
LogicSet(x) = LogicalCombo(x, fill(true,*(length.([x...])...)))

x = LogicSet((a=1:2,b=1:3, c=1:4))
x.logical .= collect(1:length(x.logical)) .% 2 .== 1
x
