# This file is a part of Julia. License is MIT: https://julialang.org/license
module AbstractLogic

##############################################################################
##
## Dependencies
##
##############################################################################
using ReplMaker, Markdown, StatsBase, Crayons

##############################################################################
##
## Exported methods and types (in addition to everything reexported above)
##
##############################################################################

export abstractlogic,
       checkfeasible,
       LogicalCombo,
       logicalparse,
       search,
       showfeasible,
       discover,
       returnactivelogicset,
       dashboard!,
       dashboard,
       showlogichistory,
       showcommandhistory,
       showuserinput,
       showsetlocation,
       showcmdlocation,
       returnlogicset,
       showcommandlist


##############################################################################
##
## Load files
##
##############################################################################

include("logicalcombo/LogicalCombo.jl")

include("logicalcombo/logicalparse.jl")

include("logicalcombo/expand.jl")

include("logicalcombo/usefulfunctions.jl")

include("logicalcombo/definelogicalset.jl")

include("logicalcombo/operatoreval.jl")

include("logicalcombo/superoperator.jl")

include("logicalcombo/metaoperator.jl")

include("logicalcombo/operatorspawn.jl")

include("logicalcombo/search.jl")

include("logicalcombo/checkfeasible.jl")

include("logicalcombo/showfeasible.jl")

include("logicalcombo/repl.jl")

include("logicalcombo/help.jl")

include("logicalcombo/discover.jl")

#
#
#

using ReplMaker, Markdown, StatsBase, Crayons

Main.include("logicalcombo/LogicalCombo.jl")

Main.include("logicalcombo/logicalparse.jl")

Main.include("logicalcombo/expand.jl")

Main.include("logicalcombo/usefulfunctions.jl")

Main.include("logicalcombo/definelogicalset.jl")

Main.include("logicalcombo/operatoreval.jl")

Main.include("logicalcombo/superoperator.jl")

Main.include("logicalcombo/metaoperator.jl")

Main.include("logicalcombo/operatorspawn.jl")

Main.include("logicalcombo/search.jl")

Main.include("logicalcombo/checkfeasible.jl")

Main.include("logicalcombo/showfeasible.jl")

Main.include("logicalcombo/repl.jl")

Main.include("logicalcombo/help.jl")

Main.include("logicalcombo/discover.jl")

end # module AbstractLogic
