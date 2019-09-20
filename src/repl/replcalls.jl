
printmarkdown(x) = show(stdout, MIME("text/plain"), Markdown.parse(x))
markdownescape(x) = replace(x, "|"=>"\\|") |> (x -> replace(x, "#"=>"\\#"))
tounicode(x) = replace(x, r"\bin\b"=>"∈")
Base.nothing() = println(lastcommand() * " - " * reportfeasible())


function itemprint(x)
   for v in x
      vstring = string(v)
      println(vstring[1:min(90,end)] * (length(vstring) > 90 ? "..." : ""))
   end
end
