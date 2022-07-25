"""
    ArrayFactors(f)

Array factors are defined such that the array's elements are their products:
`M[i, j, ..., l] = f[1][i] * f[2][j] * ... * f[3][l]`

see also: [`ipf`](@ref), [`margins`](@ref)

# Fields
- `f::Vector{Vector{<:Real}}`: Vector of array factors

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
struct ArrayFactors
    f::Vector{Vector{<:Real}}
end

# Methods
function Base.eltype(A::ArrayFactors)
    eltype(A.f[1])
end

function Base.show(io::IO, A::ArrayFactors)
    print(io, "Factors for array of size $(Tuple(length.(A.f))):")
    for i in 1:length(A.f)
        print(io, "\n  $i: ")
        show(io, A.f[i])
    end
end

function Base.Array(A::ArrayFactors)
    D = length(A.f)
    D_len = length.(A.f)
    M = ones(eltype(A), D_len...)
    for idx in CartesianIndices(M)
        for d in 1:D
            M[idx] *= A.f[d][idx[d]]
        end
    end
    return M
end