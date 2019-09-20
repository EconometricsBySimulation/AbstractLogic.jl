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
       activehistory,
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

       replerror,
       activehistory,
       replset,
       sessionhistory,

       showlogichistory,
       showcommandhistory,
       showuserinput,
       showsetlocation,
       showcmdlocation,
       showcommandlist


##############################################################################
##
## Load main files
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

include("logicalcombo/help.jl")

include("logicalcombo/discover.jl")


##############################################################################
##
## Load REPL
##
##############################################################################

include("repl/History.jl")

include("repl/ALback_next.jl")

include("repl/ALcheck.jl")

include("repl/ALclear.jl")

include("repl/ALcompare.jl")

include("repl/ALhistory.jl")

include("repl/ALimport_export.jl")

include("repl/ALparse.jl")

include("repl/ALpreserve_restore.jl")

include("repl/ALrange.jl")

include("repl/ALsearch.jl")

include("repl/ALshow.jl")

include("repl/replcalls.jl")

include("repl/testcall.jl")

include("repl/repl.jl")

isdefined(Base, :active_repl) && include("repl/replmaker.jl")

end # module AbstractLogic
