function ALshow(; n =10, verbose=true)
    nrow = nfeasible(replset)

    (nrow == 0) && return replthrow("Nothing to Show - [Empty Set]")

    printset = unique([(1:min(n÷2,nrow))..., 0, (max(nrow-(n÷2 -1), 1):nrow)...])
    (nrow<=n) && (printset = 1:nrow)

    txtout = ""
    (nrow > n) && (txtout *= "*Showing $n of $nrow rows*\n\n")

    txtout *= "| " * join(replset[0,:], " | ") * " | \n"
    txtout *= "| " * join(fill(":---:", size(replset,2) ), " | ") * " | \n"

    for v in printset
      (v != 0) &&
        (txtout *= "| " * join(replset[v,:,:], " | ")*" |\n")
      (v == 0) &&
        (txtout *= "| " * (join(fill("⋮",  size(replset, 2)), " | "))*"|\n")
    end

    verbose && printmarkdown(txtout)
end
