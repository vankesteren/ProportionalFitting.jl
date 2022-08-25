module ItPropFit
export ipf
export ArrayFactors
export ArrayMargins, isconsistent, proportion_transform
export DimIndices

include("DimIndices.jl")
include("ArrayMargins.jl")
include("ArrayFactors.jl")
include("utils.jl")
include("ipf.jl")

end # module
