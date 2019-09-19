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
       help,
       nfeasible,
       returnreplerror,
       returnlogicset,
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

Main.include("logicalcombo/counter.jl")

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

isdefined(Base, :active_repl) && Main.include("logicalcombo/replmaker.jl")

end # module AbstractLogic
