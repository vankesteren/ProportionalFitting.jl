using ProportionalFitting
using Documenter

DocMeta.setdocmeta!(ProportionalFitting, :DocTestSetup, :(using ProportionalFitting); recursive=true)

frmt =  Documenter.HTML(;
    prettyurls = get(ENV, "CI", "false") == "true",
    canonical = "https://vankesteren.github.io/ProportionalFitting.jl",
    edit_link = "main",
    assets = String[],
)

pgs = [
    "Home" => "index.md",
    "Examples" => "examples.md",
    "Benchmarks" => "benchmarks.md",
    "Reference" => "reference.md"
]

makedocs(;
    modules = [ProportionalFitting],
    authors = "Erik-Jan van Kesteren",
    repo = "https://github.com/vankesteren/ProportionalFitting.jl",
    sitename = "ProportionalFitting.jl",
    format = frmt,
    pages = pgs,
)

deploydocs(;
    repo = "github.com/vankesteren/ProportionalFitting.jl",
    devbranch = "main",
)
