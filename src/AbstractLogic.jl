# This file is a part of Julia. License is MIT: https://julialang.org/license
module AbstractLogic

##############################################################################
##
## Dependencies
##
##############################################################################
# cd("/Users/francissmart/Documents/GitHub/AbstractLogic")
using Pkg
Pkg.activate(".")

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

include("logicalcombo/operatoreval.jl")
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

include("logicalcombo/repl.jl")

include("logicalcombo/help.jl")

end # module AbstractLogic
