struct DimIndices
    idx::Vector{Union{Int, Vector{Int}}}
    # inner constructor checking that all dims are there
    function DimIndices(idx::Vector{Union{Int, Vector{Int}}})
        D = maximum(maximum.(idx))
        dmissing = setdiff(1:D, vcat(idx...))
        length(dmissing) > 0 ? error("Missing array dimensions: $dmissing.") : new(idx)
    end
end

# convenient constructor
DimIndices(X::Vector) = DimIndices(Vector{Union{Int, Vector{Int}}}(X))

# Base methods
Base.ndims(DI::DimIndices) = maximum(maximum.(DI.idx))
Base.length(DI::DimIndices) = length(DI.idx)
Base.issorted(DI::DimIndices) = issorted(vcat(DI.idx...))
function Base.show(io::IO, DI::DimIndices)
    println(io, "Indices for $(ndims(DI))D array:")
    print("[")
    for i in 1:length(DI)
        show(io, DI.idx[i])
        if i != length(DI) print(", ") end
    end
    print("]")
end
