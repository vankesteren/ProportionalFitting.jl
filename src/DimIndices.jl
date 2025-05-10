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
        # uniqueness between sets of indices 
        if !allunique(sort.(idx))
            error("Some sets of dimensions were duplicated, e.g. [[1,2], [2,1]].")
            # uniqueness within sets of indices
        elseif !all(allunique, idx)
            error("Some dimensions were duplicated within a set, e.g. [[2,1,2], [3]].")
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
DimIndices(X::Vector) = DimIndices(Vector{Union{Int,Vector{Int}}}(X))
function DimIndices(X::Vector{Union{Int,Vector{Int}}})
    return DimIndices(broadcast((x) -> [x...], X))
end

"""
    default_dimindices(m::Vector{<:AbstractArray})

Create default dimensions from a vector of arrays. These dimensions
are assumed to be ordered. For example, for 
the dimensions will be [[1], [2], [3]]. For [[1, 2], [2 1 ; 3 4]], it
will be [[1], [2, 3]].

See also: [`DimIndices`](@ref)

# Arguments
- `m::Vector{<:AbstractArray}`: Array margins or factors.

# Examples
```julia-repl
julia> default_dimindices([[1, 2], [2, 1], [3, 4]])
Indices for 3D array:
    [[1], [2], [3]]

julia> default_dimindices([[1, 2], [2 1 ; 3 4]])
Indices for 3D array:
    [[1], [2, 3]]
```
"""
function default_dimindices(m::Vector{<:AbstractArray})
    nd = ndims.(m)
    j = 0
    dd = []
    for i in nd
        push!(dd, collect((j + 1):(j + i)))
        j += i
    end
    return DimIndices(dd)
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
        if i != length(DI)
            print(", ")
        end
    end
    return print("]")
end
