
using Documenter, AbstractLogic
# using AbstractLogic

# include("C:\\Users\\francis.smart.ctr\\GitDir\\AbstractLogic.jl\\src\\AbstractLogic.jl")

# Installation
# ] dev https://github.com/EconometricsBySimulation/AbstractLogic.jl

# Form DataFrames - using as referense

# Build documentation.
# ====================

makedocs(
    # options
    modules = [AbstractLogic],
    doctest = false,
    clean = true,
    sitename = "AbstractLogic.jl",
    format = Documenter.HTML(),
    pages = Any[
        "Introduction" => "index.md",
        "User Guide" => Any[
            "Getting Started" => "man/getting_started.md",
            "Command Snytax" => "man/command_syntax.md",
            "RELP" => "man/repl.md",
            "Generators" => "man/generators.md",
            "Operators" => "man/operators.md",
            "Super Operators" => "man/superoperators.md",
            "Meta Operators" => "man/metaoperators.md",
            "Wildcards" => "man/wildcards.md",
            "Queries" => "man/queries.md"
        ]
        ,
         "API" => Any[
        #     "Types" => "lib/types.md",
             "Functions" => "lib/functions.md"
        #     "Indexing" => "lib/indexing.md"
         ]
         ,
         "Examples" => Any[
             "Harry Potter" => "examples/harrypotter.md",
             "LSAT 2007" => "examples/LSATAnalyticalReasoning.md"
         ]
    ]

)

# Deploy built documentation from Travis.
# =======================================

deploydocs(
    # options
    repo = "github.com/EconometricsBySimulation/AbstractLogic.jl.git"
)
