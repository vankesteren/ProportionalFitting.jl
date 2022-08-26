"""
    ArrayFactors(af::Vector{<:AbstractArray}), di::DimIndices)

Array factors are defined such that the array's elements are their products:
`M[i, j, ..., l] = af[1][i] * af[2][j] * ... * af[3][l]`. 

The array factors can be vectors or multidimensional arrays themselves.

The main use of ArrayFactors is as a memory-efficient representation of a 
multidimensional array, which can be constructed using the `Array()` 
method.

see also: [`ipf`](@ref), [`ArrayMargins`](@ref), [`DimIndices`](@ref)

# Fields
- `af::Vector{<:AbstractArray{T}}`: Vector of (multidimensional) array factors
- `di::DimIndices`: Dimension indices to which the array factors belong.

# Examples
```julia-repl
julia> AF = ArrayFactors([[1,2,3], [4,5]])
Factors for array of size (3, 2):
  [1]: [1, 2, 3]
  [2]: [4, 5]

julia> eltype(AF)
Int64

julia> Array(AF)
3×2 Matrix{Int64}:
  4   5
  8  10
 12  15

julia> AF = ArrayFactors([[1,2,3], [4 5; 6 7]], DimIndices([2, [1, 3]]))
Factors for 3D array:
  [2]: [1, 2, 3]
  [1, 3]: [4 5; 6 7]

julia> Array(AF)
2×3×2 Array{Int64, 3}:
[:, :, 1] =
 4   8  12
 6  12  18

[:, :, 2] =
 5  10  15
 7  14  21
```
"""
struct ArrayFactors{T}
    af::Vector{<:AbstractArray{T}}
    di::DimIndices
end

# Constructor for mixed-type arrayfactors needs promotion before construction
function ArrayFactors(af::Vector{<:AbstractArray}, di::DimIndices) 
    AT = eltype(af)
    PT = promote_type(eltype.(af)...)
    ArrayFactors(Vector{AT{PT}}(af), di)
end

# Constructor promoting vector to dimindices
ArrayFactors(af::Vector{<:AbstractArray}, di::Vector) = ArrayMargins(af, DimIndices(di))    

# Constructor based on factors without dimindices
ArrayFactors(af::Vector{<:AbstractArray}) = ArrayFactors(af, default_dimindices(af))

# Overloading base methods
function Base.eltype(::Type{ArrayFactors{T}}) where {T}
    return T
end

function Base.show(io::IO, AF::ArrayFactors)
    print(io, "Factors for $(ndims(AF.di))D array:")
    for i in 1:length(AF.af)
        print(io, "\n  $(AF.di.idx[i]): ")
        show(io, AF.af[i])
    end
end

Base.size(AF::ArrayFactors) = flatten(size.(AF.af)...)[sortperm(vcat(AF.di.idx...))]
Base.length(AF::ArrayFactors) = length(AF.af)

"""
    Array(AF::ArrayFactors{T})

Create an array out of an ArrayFactors object.

# Arguments
- `A::ArrayFactors{T}`: Array factors

# Examples
```julia-repl
julia> fac = ArrayFactors([[1,2,3], [4,5], [6,7]])
Factors for array of size (3, 2, 2):
    1: [1, 2, 3]
    2: [4, 5]
    3: [6, 7]

julia> Array(fac)
3×2×2 Array{Int64, 3}:
[:, :, 1] =
 24  30
 48  60
 72  90

[:, :, 2] =
 28   35
 56   70
 84  105
```
"""
function Base.Array(AF::ArrayFactors{T}) where {T}
    D = length(AF.di)
    asize = size(AF)
    M = ones(T, asize)
    for d in 1:D
        idx = AF.di.idx[d]
        af = AF.af[d]
        if !issorted(idx)
            sp = sortperm(idx)
            idx = idx[sp]
            af = permutedims(af, sp)
        end
        dims = [idx...]
        shp = ntuple(i -> i ∉ dims ? 1 : asize[popfirst!(dims)], ndims(AF.di))
        M .*= reshape(af, shp)
    end
    return M
end
