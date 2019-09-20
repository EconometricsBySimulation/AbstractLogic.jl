function Alhistory()
   currentcommand =
     [priorcommands(activehistory)..., "<< present >>",
     futurecommands(activehistory)...]
   currentfeasible =
     [nfeasible.(priorlogicsets(activehistory))..., "...",
     nfeasible.(futurelogicsets(activehistory))...]


   txtout = "| Command | # feasible |\n| --- | --- |\n"
   for i in 1:length(currentcommand)
       txtout *= ("| $(markdownescape(currentcommand[i])) | $(currentfeasible[i]) |\n")
   end
   printmarkdown(txtout)
end
