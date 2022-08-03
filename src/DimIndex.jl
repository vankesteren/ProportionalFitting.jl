struct DimIndex
    idx::Vector{Union{Int, Vector{Int}}}
    # inner constructor checking that all dims are there
    function DimIndex(idx::Vector{Union{Int, Vector{Int}}})
        D = maximum(maximum.(idx))
        dmissing = setdiff(1:D, vcat(idx...))
        length(dmissing) > 0 ? error("Missing array dimensions: $dmissing.") : new(idx)
    end
end

# convenient constructor
DimIndex(X::Vector) = DimIndex(Vector{Union{Int, Vector{Int}}}(X))

# Base methods
Base.ndims(DI::DimIndex) = maximum(maximum.(DI.idx))
Base.length(DI::DimIndex) = length(DI.idx)
Base.issorted(DI::DimIndex) = issorted(vcat(DI.idx...))
function Base.show(io::IO, DI::DimIndex)
    println(io, "Indices for $(ndims(DI))D array:")
    print("[")
    for i in 1:length(DI)
        show(io, DI.idx[i])
        if i != length(DI) print(", ") end
    end
    print("]")
end

function dims_excluding_idx(DI::DimIndex, i::Int)
    vcat(setdiff(DI.idx, DI.idx[d])...)
end