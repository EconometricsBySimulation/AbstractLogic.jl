
function ALexport(x)
   y = replace(x, r"^export( as){0,1} " => "")
   Core.eval(Main, Meta.parse("$y = returnreplset()"))
   printmarkdown("`julia>` $y = `returnreplset()`")
   println()
end
