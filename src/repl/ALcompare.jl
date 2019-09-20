function ALcompare(x; verbose=true)

    y = Symbol(strip(replace(x, r"^compare "=>"")))

    !(y ∈ names(Main)) && (replthrow("$y not found!"); return)

    z = getfield(Main, y)

    (replset[:] == z[:]) &&
      (println("replset and $y have the same feasible values. replset[:] == $y[:]"); return)
    (nfeasible(replset) == nfeasible(z)) &&
      (println("replset set and $y have the same number of feasible values. nfeasible(replset) == nfeasible($y)"); return)
    (nfeasible(replset) > nfeasible(z)) &&
      (println("replset set has more feasible values than $y. nfeasible(replset) > nfeasible($y)"); return)
    (nfeasible(replset) < nfeasible(z)) &&
      (println("replset set has less feasible values than $y. nfeasible(replset) < nfeasible($y)"); return)

end
