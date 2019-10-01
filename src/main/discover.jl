
"""
Prints a list of logical combos, variables defined, number of feasible outcomes,
number of commands, as well as the last command.

discover(x::LogicalCombo)
discover()

"""
function discover(x::LogicalCombo)
   nameset = names(Main)

   logicalcombonames = String[]
   variables         = String[]
   nfeasiblelist     = Int16[]
   ncommands         = Int16[]
   lastcommand       = String[]

   for v in nameset
     # global logicalcombonames, variables, nfeasible, ncommands
     x = getfield(Main, v)
     if isa(x, LogicalCombo)
       push!(logicalcombonames, string(v))
       push!(variables, join(keys(x),", "))
       push!(nfeasiblelist, nfeasible(x))
       push!(ncommands, length(x.commands))
       (length(x.commands) > 0 ? push!(lastcommand, last(x.commands)) : push!(lastcommand, ""))
     end
   end

   (length(logicalcombonames)==0) && (println("No LogicalCombos found in Main"); return)

   txtout = "| Name | Variables | #feasible | #commands | Last Command | \n"
   txtout *= "| :---: | :---: | :---: | :---: | :---: | \n"

   for i in 1:length(logicalcombonames)
       txtout *= "| $(logicalcombonames[i]) | $(variables[i]) | " *
             "$(nfeasiblelist[i]) | $(ncommands[i]) | $(lastcommand[i]) | \n"
   end

   printmarkdown(txtout)
end

discover() = discover(LogicalCombo())
