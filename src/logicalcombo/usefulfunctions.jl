
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
    Perceived = percievedfeasible(logicset)

    (Nfeas == 0)  && (check = "X ")
    (Nfeas  > 1)  && (check = "✓ ")
    (Nfeas == 1)  && (check = "✓✓")

    ender = (Nfeas>0) ? ":" *
      join(logicset[rand(1:Nfeas),:,:], " ") : " [empty set]"

    println(" $filler Feasible Outcomes: $Nfeas \t Perceived Outcomes: $Perceived $check \t $ender")
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

subout("{{i + 1}}", 1, "i + 1", [:a,:b,:c,:d])

##########################################################################
##########################################################################

function stringnumparse(x)
    !occursin(r"\+|\-",x) && return integer(x)

    x2 = split(x, r"\+|\-")

    occursin("+", x) && return +(integer.(x2)...)
    occursin("-", x) && return -(integer.(x2)...)

    throw("$x not interpreted!")
end

##########################################################################
##########################################################################

Base.:+(x::String, y::String) = x * " " * y

function skipthischeck(txt, i, j; verbose=false)
    txt = replace(txt, " "=>"")

    occursin(r"!(i|j|J)", txt) && return i==j

    occursin(r"![0-9]+$", txt) &&
     return integer(match(r"^!([0-9])+$", txt).captures[1]) == j

    occursin(r"^!(i|j|J)$", txt) && (i  == j) && return true

      m = match(r"^\*?([>=<]{0,2})(.*)([>=<]{0,2})\*?$", txt)
      if m.match != nothing
        centernum = stringnumparse(strip.(m.captures[2]))
        verbose && print(" (" +
         (m.captures[1] == "" ? "" : string(j) + string(m.captures[1])) *
           " $centernum " *
         (m.captures[3] == "" ? "" : string(m.captures[3]) + string(j)) * ") ")
        # * [operator] center
        (m.captures[1] == ">")  && !(j >  centernum    ) && return true
        (m.captures[1] == ">=") && !(j >= centernum    ) && return true
        (m.captures[1] == ">>") && !(j >  centernum + 1) && return true
        (m.captures[1] == "<")  && !(j <  centernum    ) && return true
        (m.captures[1] == "<=") && !(j <= centernum    ) && return true
        (m.captures[1] == "<<") && !(j <  centernum - 1) && return true

        # center [operator] *
        (m.captures[3] == "<")  && !(centernum     <  j) && return true
        (m.captures[3] == "<=") && !(centernum     <= j) && return true
        (m.captures[3] == "<<") && !(centernum - 1 << j) && return true
        (m.captures[3] == ">")  && !(centernum     >  j) && return true
        (m.captures[3] == ">=") && !(centernum     >= j) && return true
        (m.captures[3] == ">>") && !(centernum + 1 >> j) && return true

        (m.captures[1] ∈ ["=","=="]) && (centernum != j) && return true
        (m.captures[3] ∈ ["=","=="]) && (centernum != j) && return true
      end
    false
end

##########################################################################
##########################################################################

function splitthenskipcheck(txt, i, j; verbose=false)
    rangematchessplit =
       strip.(split(replace(txt, r"i|j|J"=>i), r"(,|\|)"))

    occursin("|", txt) && return all(skipthischeck.(rangematchessplit, i, j, verbose=verbose))

    !occursin("|", txt) && return any(skipthischeck.(rangematchessplit, i, j, verbose=verbose))

    false
end

# txt = "!1,!3"
#
# for i in 1:5, j in 1:5
#     print("i = $i, j = $j skipthis {{$txt}} Skip? ")
#     println(splitthenskipcheck(txt, i, j, verbose=true))
# end
#

##########################################################################
##########################################################################

function back(logicset::LogicalCombo; verbose=false)
  (length(logicset.commands)==0) && (println("Nothing to go back to!"); return logicset)
  commandlist = copy(logicset.commands)
  pop!(commandlist)
  return logicalparse(commandlist, verbose=verbose)
end
