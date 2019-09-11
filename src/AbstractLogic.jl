# This file is a part of Julia. License is MIT: https://julialang.org/license
module AbstractLogic

##############################################################################
##
## Dependencies
##
##############################################################################
using Markdown, StatsBase, Crayons, ReplMaker

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
       dashboard!,
       dashboard,
       expand,
       nfeasible,
       returnreplset,
       showlogichistory,
       showcommandhistory,
       showuserinput,
       showsetlocation,
       showcmdlocation,
       showcommandlist


##############################################################################
##
## Load files
##
##############################################################################

include("logicalcombo/counter.jl")

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

isdefined(Base, :active_repl) && include("logicalcombo/replmaker.jl")

end # module AbstractLogic
