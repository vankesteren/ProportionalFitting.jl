"""
    ArrayFactors(f)

Array factors are defined such that the array's elements are their products:
`M[i, j, ..., l] = f[1][i] * f[2][j] * ... * f[3][l]`

see also: [`ipf`](@ref), [`ArrayMargins`](@ref), [`DimIndices`](@ref)

# Fields
- `f::Vector{Vector{T}}`: Vector of array factors

# Examples
```julia-repl
julia> AF = ArrayFactors([[1,2,3], [4,5]])
Factors for array of size (3, 2):
  1: [1, 2, 3]
  2: [4, 5]

julia> eltype(AF)
Int64

julia> Array(AF)
3×2 Matrix{Int64}:
  4   5
  8  10
 12  15
```
"""
struct ArrayFactors{T}
    af::Vector{<:AbstractArray{T}}
    di::DimIndices
end

# promoting constructor
ArrayFactors(af::Vector{<:AbstractArray}) = ArrayFactors(af, DimIndices(getdims(af)))

# todo: constructor for mixed-type arrayfactors ([[1, 2, 3], [.4, .5]])

# constructor based on arrays vararg
function ArrayFactors(af::AbstractArray...)
    v = [af...]
    return ArrayFactors(v, DimIndices(getdims(v)))
end

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
