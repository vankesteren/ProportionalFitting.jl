using ProportionalFitting
using Documenter

DocMeta.setdocmeta!(ProportionalFitting, :DocTestSetup, :(using ProportionalFitting); recursive=true)

makedocs(;
    modules=[ProportionalFitting],
    authors="Erik-Jan van Kesteren",
    repo="https://github.com/vankesteren/ProportionalFitting.jl/blob/{commit}{path}#{line}",
    sitename="ProportionalFitting.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://vankesteren.github.io/ProportionalFitting.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Examples" => "examples.md",
        "Benchmarks" => "benchmarks.md",
        "Reference" => "reference.md"
    ],
)

deploydocs(;
    repo="github.com/vankesteren/ProportionalFitting.jl",
    devbranch="main",
    versions = ["stable" => "v^", "v#.#.#"]
)
