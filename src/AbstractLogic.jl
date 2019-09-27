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
       dependenton,
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
       setcompare,
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

include("main/LogicalCombo.jl")

include("main/counter.jl")

include("main/logicalparse.jl")

include("main/expand.jl")

include("main/usefulfunctions.jl")

include("main/definelogicalset.jl")

include("main/dependenton.jl")

include("main/operatoreval.jl")

include("main/superoperator.jl")

include("main/metaoperator.jl")

include("main/operatorspawn.jl")

include("main/search.jl")

include("main/checkfeasible.jl")

include("main/showfeasible.jl")

include("main/setcompare.jl")

include("main/help.jl")

include("main/discover.jl")


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
