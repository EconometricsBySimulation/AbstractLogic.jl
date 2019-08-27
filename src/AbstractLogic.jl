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

export AbstractDataFrame,
       All,
       Between,
       DataFrame,
       DataFrame!,
       DataFrameRow,
       GroupedDataFrame,
       SubDataFrame,
       allowmissing!,
       aggregate,
       by,
       categorical!,
       columnindex,
       combine,
       completecases,
       deleterows!,
       describe,
       disallowmissing!,
       dropmissing,
       dropmissing!,
       eltypes,
       groupby,
       groupindices,
       groupvars,
       insertcols!,
       mapcols,
       melt,
       meltdf,
       names!,
       ncol,
       nonunique,
       nrow,
       order,
       rename!,
       rename,
       select,
       select!,
       stack,
       stackdf,
       unique!,
       unstack,
       permutecols!

##############################################################################
##
## Load files
##
##############################################################################

include("logicalcombo/LogicalCombo.jl")
include("logicalcombo/LogicalParse.jl")


end # module AbstractLogic
