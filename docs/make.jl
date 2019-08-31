
using Documenter, AbstractLogic

# Installation
# ] dev https://github.com/EconometricsBySimulation/AbstractLogic.jl

# Form DataFrames - using as referense


using Documenter, AbstractLogic

# Build documentation.
# ====================

makedocs(
    # options
    modules = [DataFrames],
    doctest = false,
    clean = false,
    sitename = "AbstractLogic.jl",
    format = Documenter.HTML(),
    pages = Any[
        "Introduction" => "index.md",
        "User Guide" => Any[
            "Getting Started" => "man/getting_started.md",
            "Generators" => "man/generators.md",
            "Operators" => "man/operators.md",
            "Super Operators" => "man/superoperators.md",
            "Meta Operators" => "man/metaoperators.md",
            "Wildcards" => "man/wildcards.md",
        ],
        "API" => Any[
            "Types" => "lib/types.md",
            "Functions" => "lib/functions.md",
            "Indexing" => "lib/indexing.md"
        ]
    ]
)

# Deploy built documentation from Travis.
# =======================================

deploydocs(
    # options
    repo = "github.com/EconometricsBySimulation/AbstractLogic.jl.git",
    target = "build",
    deps = nothing,
    make = nothing,
)
