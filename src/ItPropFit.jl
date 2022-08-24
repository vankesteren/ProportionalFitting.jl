module ItPropFit
export ipf, ipf_mult, ArrayFactors, ArrayMargins, DimIndices

include("DimIndices.jl")
include("ArrayMargins.jl")
include("ArrayFactors.jl")
include("utils.jl")
include("ipf.jl")
include("ipf_mult.jl")

end # module
