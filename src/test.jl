using SparseArrays, Serialization

v7 = logicalparse("a,b,c,d,e,f,g ∈ 1:7 || {{i}} != {{>i}}")
sv7 = sparsevec(v7[:])
vector(sv7)

serialize("src/sv/sv7.ser", sv7)

v8 = logicalparse("a,b,c,d,e,f,g,h ∈ 1:8 || {{i}} != {{>i}}")
sv8 = sparsevec(v8[:])

serialize("src/sv/sv8.ser", sv8)

v9 = logicalparse("a,b,c,d,e,f,g,h,i ∈ 1:9 || {{i}} != {{>i}}")
sv9 = sparsevec(v9[:])

function f1()
    j = 0
    for i in (1:length(v9[:]))[v9[:]]
        j += 1
    end
end

function f2()
    j = 0
    for i in (sv9)
        j += 1
    end
end


serialize("src/sv/sv9.ser", sv9)


I want to loop through only the values which are true
```
bool = repeat([false, true, repeat([false],50)...], 100)
for i in (1:length(bool))[bool]
    println(i)
end

sparsebool = sparse(bool)
for i in indexes(sparsebool)
    println(i)
end
```

n = 4
factorial(n)
20

function geti(x, n, k)
    fset = 1:4
    y = x
    z = 0
    setout = Int64[]
    for j in 1:k
        K = factorial(n-1)
        z = ceil(y/ K)
        y = y - (z-1) * K
        push!(setout, fset[z])
        fset = fset[(1:(z-1))..., ((z+1):end)...]
    end
    z
end

[geti(i,4,j) for i in 1:24, j in 1:4]
