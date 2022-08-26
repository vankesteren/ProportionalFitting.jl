module ItPropFit

export 
    DimIndices,
    ArrayMargins, isconsistent, proportion_transform,
    ArrayFactors,
    ipf

include("DimIndices.jl")
include("ArrayMargins.jl")
include("ArrayFactors.jl")
include("utils.jl")
include("ipf.jl")

end # module
