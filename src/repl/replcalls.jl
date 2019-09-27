
joins(x) = length(x) > 0 ? join(x, " ") : x

joinsample = (joins ∘ sample)

lastcommand() = "Last command: \"$(replset.commands[end])\" "

Base.nothing(; verbose = true) = verbose && println(lastcommand() * " - " * reportfeasible())

markdownescape(x) = replace(x, "|"=>"\\|") |> (x -> replace(x, "#"=>"\\#"))

printmarkdown(x) = show(stdout, MIME("text/plain"), Markdown.parse(x))

reportfeasible(logicset::LogicalCombo) = "Feasible Outcomes: $(nfeasible(logicset)) \t $(join(sample(logicset),", "))"

reportfeasible() = "Feasible Outcomes: $(nfeasible(replset)) \t $(join(sample(replset),", "))"

tounicode(x) = replace(x, r"\bin\b"=>"∈")
