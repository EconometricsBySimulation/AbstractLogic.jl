# This file is a part of Julia. License is MIT: https://julialang.org/license
module AbstractLogic

##############################################################################
##
## Dependencies
##
##############################################################################

# using ReplMaker

##############################################################################
##
## Exported methods and types (in addition to everything reexported above)
##
##############################################################################

export checkfeasible,
       commandlist,
       expand,
       LogicalCombo,
       logicalparse,
       LogicalRepl,
       logiclist,
       nfeasible,
       reportfeasible,
       search,
       showfeasible


##############################################################################
##
## Load files
##
##############################################################################

include("logicalcombo/LogicalCombo.jl")
include("logicalcombo/LogicalParse.jl")
include("logicalcombo/LogicalREPL.jl")

end # module AbstractLogic
