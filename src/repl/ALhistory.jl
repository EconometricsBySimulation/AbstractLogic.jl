function Alhistory(; sessionprint = false)
   !sessionprint && (myhistory = activehistory)
   sessionprint  && (myhistory = sessionhistory)

   currentcommand =
     [priorcommands(myhistory)..., "<< present >>",
     futurecommands(myhistory)...]
   currentfeasible =
     [nfeasible.(priorlogicsets(myhistory))..., "...",
     nfeasible.(futurelogicsets(myhistory))...]


   txtout = "| Command | # feasible |\n| --- | --- |\n"
   for i in 1:length(currentcommand)
       txtout *= ("| $(markdownescape(currentcommand[i])) | $(currentfeasible[i]) |\n")
   end
   printmarkdown(txtout)
end
