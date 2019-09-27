
function ALexport(x; verbose = true)
   y = replace(x, r"^export( as){0,1} " => "")
   Core.eval(Main, Meta.parse("$y = replset"))
   verbose && printmarkdown("`julia>` $y = `replset`")
   verbose && println()
end

function ALimport(userinput; verbose = true)

    imports = Symbol(strip(replace(userinput, r"^import "=>"")))

    !(imports ∈ names(Main)) && (println("$imports not found!"); return)

    imported = getfield(Main, imports)
    !isa(imported, LogicalCombo) && (println("$imports not a LogicalCombo!"); return)

    setreplset!(imported)

    setactivehistory!(History())
    pushactivehistory!(replset)

    pushsessionhistory!(imported)

    verbose && println("Importing $imports - " * reportfeasible(replset))
end
