###################### Testing Logical LogicalCombo

x = LogicalCombo(a=1:3,b=1:2,c=2:4)

x[2] = false
x[3:4] = false
x[17:18] = fill(false,2)

x[:] === x.logical
x[:,:]
collect(x)
x[:,:,:]
x[:,:,:a]

x[:,:a] == x[:,"a"]

x[2,:a]
x[2,:]
x[2]
range(x)

# Testing Expand Function
x = LogicalCombo(a=1:2,b=1:2)
x[1:2] = false
collect(x)
range(x)

x2 = expand(x,c=1:2)
collect(x2)
range(x2)

# Throw an error
#x3 = expand(x, a=1:2)

# Expanding on an empty set generates a new set
expand(LogicalCombo(), a=1:2, b=1) |> collect
