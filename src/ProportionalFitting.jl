module ProportionalFitting

export DimIndices,
    ArrayMargins,
    isconsistent,
    proportion_transform,
    align_margins,
    margin_totals_match,
    ArrayFactors,
    adjust!,
    ipf

include("DimIndices.jl")
include("ArrayMargins.jl")
include("ArrayFactors.jl")
include("utils.jl")
include("ipf.jl")

end # module
