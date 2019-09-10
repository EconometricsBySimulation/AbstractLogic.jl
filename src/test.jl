using Pkg
Pkg.activate(".")

include("AbstractLogic.jl")

using AbstractLogic: abstractlogic,
       checkfeasible,
       LogicalCombo,
       logicalparse,
       search,
       showfeasible,
       discover,
       dashboard!,
       dashboard,
       showlogichistory,
       showcommandhistory,
       showuserinput,
       showsetlocation,
       showcmdlocation,
       showcommandlist


using SparseArrays, Serialization

# v7 = logicalparse("a,b,c,d,e,f,g ∈ 1:7 || {{i}} != {{>i}}")
# sv7 = sparsevec(v7[:])
# vector(sv7)
#
# serialize("src/sv/sv7.ser", sv7)
#
# v8 = logicalparse("a,b,c,d,e,f,g,h ∈ 1:8 || {{i}} != {{>i}}")
# sv8 = sparsevec(v8[:])
#
# serialize("src/sv/sv8.ser", sv8)
#
# v9 = logicalparse("a,b,c,d,e,f,g,h,i ∈ 1:9 || {{i}} != {{>i}}")
# sv9 = sparsevec(v9[:])

# function f1()
#     j = 0
#     for i in (1:length(v9[:]))[v9[:]]
#         j += 1
#     end
# end
#
# function f2()
#     j = 0
#     for i in (sv9)
#         j += 1
#     end
# end
#
#
# serialize("src/sv/sv9.ser", sv9)
#

n = 6
factorial(n)
20

function geti(x, n, k)
    fset = 1:n
    y = x
    z = 0
    setout = Integer[]
    for j in 1:k
        fset, y, z, setout
        K = factorial(n-j)
        z = Integer(ceil(y/ K))
        y = y - (z-1) * K
        push!(setout, fset[z])
        fset = fset[[(1:(z-1))..., ((z+1):length(fset))...]]
    end
    setout[k]
end

X = [geti(i,6,j) for i in 1:720, j in 1:n]

unique(X, dims=1)

X = LogicalCombo([:a,:b,:c,:d], 1:4, fill(true, factorial(4)), permutationuniquelookup)
size(X)
X[:,:]
