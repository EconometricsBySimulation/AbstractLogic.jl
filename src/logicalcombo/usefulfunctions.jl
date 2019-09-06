
# Functions:
# reportfeasible
# subout
# back

##########################################################################
##########################################################################

function reportfeasible(logicset::LogicalCombo;
    command=""::String,
    verbose=true::Bool)::LogicalCombo

    !verbose && return logicset
    filler = repeat("\t", max(1, 3-Integer(floor(length(command)/8))))

    Nfeas = nfeasible(logicset)

    (Nfeas == 0)  && (check = "X ")
    (Nfeas  > 1)  && (check = "✓ ")
    (Nfeas == 1)  && (check = "✓✓")

    ender = (Nfeas>0) ? ":" *
      join(logicset[rand(1:Nfeas),:,:], " ") : " [empty set]"

    println(" $filler feasible outcomes $Nfeas $check \t $ender")
    return logicset
end

reportfeasible(command::String, verbose::Bool)::Function =
  (x -> reportfeasible(x, command=command, verbose=verbose))

##########################################################################
##########################################################################

function subout(txtcmd, i, arg, mykeys)
  lookup(vect, i) = i ∈ 1:length(vect) ? vect[i] : "~~OUTOFBOUNDS~~"

  (arg[end] ∈ ['i', 'j', 'J'])  && return replace(txtcmd, "{{$arg}}"=>lookup(mykeys,i))

  mod = integer(match(r"([0-9]+$)", arg).match)

  occursin("+", arg) && return replace(txtcmd, "{{$arg}}"=>lookup(mykeys,i+mod))
  occursin("-", arg) && return replace(txtcmd, "{{$arg}}"=>lookup(mykeys,i-mod))

  txtcmd
end

##########################################################################
##########################################################################

function back(logicset::LogicalCombo; verbose=false)
  (length(logicset.commands)==0) && (println("Nothing to go back to!"); return logicset)
  commandlist = copy(logicset.commands)
  pop!(commandlist)
  return logicalparse(commandlist, verbose=verbose)
end
