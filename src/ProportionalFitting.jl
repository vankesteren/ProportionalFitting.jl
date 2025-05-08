module ProportionalFitting

export
    DimIndices,
    ArrayMargins, isconsistent, proportion_transform, align_arrays, margin_totals_match,
    ArrayFactors,
    ipf

include("DimIndices.jl")
include("ArrayMargins.jl")
include("ArrayFactors.jl")
include("utils.jl")
include("ipf.jl")

end # module
