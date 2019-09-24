


function itemprint(x)
   for v in x
      vstring = string(v)
      println(vstring[1:min(90,end)] * (length(vstring) > 90 ? "..." : ""))
   end
end

joins(x) = length(x) > 0 ? join(x, " ") : x

joinsample = (joins ∘ sample)

lastcommand() = "Last command: \"$(replset.commands[end])\" "

Base.nothing(; verbose = true) = verbose && println(lastcommand() * " - " * reportfeasible())

markdownescape(x) = replace(x, "|"=>"\\|") |> (x -> replace(x, "#"=>"\\#"))

printmarkdown(x) = show(stdout, MIME("text/plain"), Markdown.parse(x))

reportfeasible() = "Feasible Outcomes: $(nfeasible(replset)) \t Perceived Outcomes: $(percievedfeasible(replset)) \t:$(joinsample(replset))"

tounicode(x) = replace(x, r"\bin\b"=>"∈")
