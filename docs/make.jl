using ItPropFit
using Documenter

DocMeta.setdocmeta!(ItPropFit, :DocTestSetup, :(using ItPropFit); recursive=true)

makedocs(;
    modules=[ItPropFit],
    authors="Erik-Jan van Kesteren",
    repo="https://github.com/vankesteren/ItPropFit.jl/blob/{commit}{path}#{line}",
    sitename="ItPropFit.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://vankesteren.github.io/ItPropFit.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Reference" => "reference.md"
    ],
)

deploydocs(;
    repo="github.com/vankesteren/ItPropFit.jl",
    devbranch="main",
)
