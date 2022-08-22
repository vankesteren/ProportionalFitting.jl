"""
    DimIndices(idx::Vector{Vector{Int}})

DimIndices represent an exhaustive list of indices for the 
dimensions of an array. It is an object containing a single
element, `idx`, which is a nested vector of integers; 
e.g., `[[2], [1, 3], [4]]`. DimIndices objects are checked for 
uniqueness and completeness, i.e., all indices up to the largest
index are used exactly once.

# Fields
- `idx::Vector{Vector{Int}}`: nested vector of dimension indices.

# Examples
```julia-repl
julia> DimIndices([2, [1, 3], 4])
Indices for 4D array:
[[2], [1, 3], [4]]
```
"""
struct DimIndices
    idx::Vector{Vector{Int}}
    # inner constructor checking uniqueness & completeness
    function DimIndices(idx::Vector{Vector{Int}})
        # uniqueness
        if !allunique(vcat(idx...)) 
            error("Some dimensions were duplicated.")
        end
        # completeness
        D = maximum(maximum.(idx))
        dmissing = setdiff(1:D, vcat(idx...))
        if length(dmissing) > 0 
            error("Missing array dimensions: $dmissing.")
        end
        return new(idx)
    end
end

# convenient constructor
DimIndices(X::Vector) = DimIndices(Vector{Union{Int, Vector{Int}}}(X))
function DimIndices(X::Vector{Union{Int, Vector{Int}}})
    DimIndices(broadcast((x) -> [x...], X))
end

# Base methods
Base.ndims(DI::DimIndices) = maximum(maximum.(DI.idx))
Base.length(DI::DimIndices) = length(DI.idx)
Base.issorted(DI::DimIndices) = issorted(vcat(maximum.(DI.idx)...))
Base.getindex(DI::DimIndices, varargs...) = getindex(DI.idx, varargs...)
function Base.show(io::IO, DI::DimIndices)
    println(io, "Indices for $(ndims(DI))D array:")
    print("[")
    for i in 1:length(DI)
        show(io, DI.idx[i])
        if i != length(DI) print(", ") end
    end
    print("]")
end

# Convenience methods
function Base.dropdims(DI::DimIndices; dims::Union{Int, Vector{Int}})
    idx = setdiff(1:length(DI), dims)
    return DI[idx]
end

function Base.selectdim(DI::DimIndices, d::Union{Int, Vector{Int}})
    return vcat(DI[d]...)
end