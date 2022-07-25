using IPF
using Documenter

DocMeta.setdocmeta!(IPF, :DocTestSetup, :(using IPF); recursive=true)

makedocs(;
    modules=[IPF],
    authors="Erik-Jan van Kesteren",
    repo="https://github.com/vankesteren/IPF.jl/blob/{commit}{path}#{line}",
    sitename="IPF.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://vankesteren.github.io/IPF.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/vankesteren/IPF.jl",
    devbranch="main",
)
