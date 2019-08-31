# This file is a part of Julia. License is MIT: https://julialang.org/license
module AbstractLogic

##############################################################################
##
## Dependencies
##
##############################################################################


##############################################################################
##
## Exported methods and types (in addition to everything reexported above)
##
##############################################################################

export logicalparse,
       checkfeasible,
       search,
       LogicalCombo,
       expand,
       showfeasible,
       LogicalRepl,
       nfeasible,
       commandlist,
       logiclist

##############################################################################
##
## Load files
##
##############################################################################

include("logicalcombo/LogicalCombo.jl")
include("logicalcombo/LogicalParse.jl")
include("logicalcombo/LogicalREPL.jl")

end # module AbstractLogic
