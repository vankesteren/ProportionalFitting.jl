"""
    ArrayFactors(f)

Array factors are defined such that the array's elements are their products:
`M[i, j, ..., l] = f[1][i] * f[2][j] * ... * f[3][l]`

see also: [`ipf`](@ref), [`margins`](@ref), [`Array`](@ref)

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
    f::Vector{AbstractArray{T}}
end

function ArrayFactors(f::AbstractArray...)
    return ArrayFactors([f...])
end

# Overloading base methods
function Base.eltype(::Type{ArrayFactors{T}}) where {T}
    return T
end

function Base.show(io::IO, A::ArrayFactors)
    print(io, "Factors for array of size $(Tuple(length.(A.f))):")
    for i in 1:length(A.f)
        print(io, "\n  $i: ")
        show(io, A.f[i])
    end
end

"""
    Array(A::ArrayFactors{T})

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
function Base.Array(A::ArrayFactors{T}) where {T}
    D = length(A.f)
    M = ones(T, length.(A.f)...)
    for idx in CartesianIndices(M)
        for d in 1:D
            M[idx] *= A.f[d][idx[d]]
        end
    end
    return M
end