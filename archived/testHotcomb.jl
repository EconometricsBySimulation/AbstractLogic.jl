# Testing

using Test

mycomb = Hotcomb((a=1:2, b=1:4,c='a':'c'))
@test keys(mycomb) == (:a, :b, :c)
@test value(mycomb) == [1:2, 1:4, 'a':'c']
@test size(mycomb) == (24,3)
@test collect(mycomb) == mycomb[:,:] # Seems to be working
@test mycomb[13,2] == mycomb[13,:b]
@test mycomb[5,:] == [1, 2, 'b']

@test_throws "Symbol :d not found" mycomb[3,:d]

###############################################################################
# Benchmarking

using BenchmarkTools, InteractiveUtils

mycomb = Hotcomb([7,7,7,7,7,7,7])
value(mycomb)
size(mycomb)

mycomb_collect = mycomb[]

mycomb[1000,:]
@benchmark mycomb[1000,:]

mycomb_collect[1000,:]
@benchmark mycomb_collect[1000,:]

varinfo() # Accessing mycomb as Hotcomb is more time intensive but uses less memory than generating full collection
