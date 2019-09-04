# This file is a part of Julia. License is MIT: https://julialang.org/license
module AbstractLogic

##############################################################################
##
## Dependencies
##
##############################################################################

using ReplMaker,
      Markdown

##############################################################################
##
## Exported methods and types (in addition to everything reexported above)
##
##############################################################################

export checkfeasible,
       LogicalCombo,
       logicalparse,
       logicalrepl,
       search,
       showfeasible


##############################################################################
##
## Load files
##
##############################################################################

include("logicalcombo/LogicalCombo.jl")

include("logicalcombo/logicalparse.jl")

# include("logicalcombo/operatoreval.jl")
#
# include("logicalcombo/superoperator.jl")
#
# include("logicalcombo/metaoperator.jl")
#
# include("logicalcombo/search.jl")
#
# include("logicalcombo/checkfeasible.jl")
#
# include("logicalcombo/showfeasible.jl")

include("logicalcombo/help.jl")

include("logicalcombo/repl.jl")

end # module AbstractLogic
