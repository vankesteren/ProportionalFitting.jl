"""
    ArrayFactors(af::Vector{<:AbstractArray}, di::DimIndices)
    ArrayFactors(af::Vector{<:AbstractArray}, di::Vector)
    ArrayFactors(af::Vector{<:AbstractArray})

Array factors are defined such that the array's elements are their products:
`M[i, j, ..., l] = af[1][i] * af[2][j] * ... * af[3][l]`.

The array factors can be vectors or multidimensional arrays themselves.

The main use of ArrayFactors is as a memory-efficient representation of a
multidimensional array, which can be constructed using the `Array()`
method. However, to perform elementwise multiplication of this array with
another array `X` of the same size, it is more efficient not instantiate
the full array. Instead, call `adjust!(X, AF)`.

see also: [`ipf`](@ref), [`ArrayMargins`](@ref), [`DimIndices`](@ref), [`adjust!`](@ref)

# Fields
- `af::Vector{<:AbstractArray}`: Vector of (multidimensional) array factors
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
    size::Tuple

    function ArrayFactors(af::Vector{<:AbstractArray{T}}, di::DimIndices) where {T}
        # loop over arrays then dimensions to get size, checking for mismatches
        dimension_sizes = zeros(Int, ndims(di))
        for i in 1:length(af)
            for (j, d) in enumerate(di.idx[i])
                new_size = size(af[i], j)
                if dimension_sizes[d] == 0
                    dimension_sizes[d] = new_size
                    continue
                end
                # check
                if dimension_sizes[d] != new_size
                    throw(
                        DimensionMismatch(
                            "Dimension sizes not equal for dimension $d: $(dimension_sizes[d]) and $new_size",
                        ),
                    )
                end
            end
        end
        return new{T}(af, di, Tuple(dimension_sizes))
    end
end

# Constructor for mixed-type arrayfactors needs promotion before construction
function ArrayFactors(af::Vector{<:AbstractArray}, di::DimIndices)
    AT = eltype(af)
    PT = promote_type(eltype.(af)...)
    return ArrayFactors(Vector{AT{PT}}(af), di)
end

# Constructor promoting vector to dimindices
ArrayFactors(af::Vector{<:AbstractArray}, di::Vector) = ArrayFactors(af, DimIndices(di))

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

Base.size(AF::ArrayFactors) = AF.size
Base.length(AF::ArrayFactors) = length(AF.af)
Base.ndims(AF::ArrayFactors) = length(AF.size)

"""
    adjust!(X::AbstractArray{T}, AF::ArrayFactors{U})

Adjust a seed array with respect to a set of ArrayFactors. The adjustment
happens through elementwise multiplication of the array by each factor,
taking into account the dimensions that this factor belongs to. This
performs the same operation as `X .* Array(AF)`, but faster and more
memory-efficient.

# Arguments
- `X::AbstractArray`: Seed array to be adjusted
- `AF::ArrayFactors`: Array factors

# Type constraints:
- `T == U` where both are subtypes of `Number`
- `T <: AbstractFloat` and `U <: Number`
- `T <: Integer` and `U <: Integer`

# Examples
```julia-repl
julia> AF = ArrayFactors([[1, 2, 3, 4], [.1, .2, .3, .4]])
Factors for 2D array:
  [1]: [1.0, 2.0, 3.0, 4.0]
  [2]: [0.1, 0.2, 0.3, 0.4]

julia> X = [40 30 20 10; 35 50 100 75; 30 80 70 120; 20 30 40 50]
4×4 Matrix{Int64}:
 40  30   20   10
 35  50  100   75
 30  80   70  120
 20  30   40   50

julia> adjust!(X, AF)
julia> X
4×4 Matrix{Int64}:
 4   6   6    4
 7  20  60   60
 9  48  63  144
 8  24  48   80
```
"""
function adjust!(X::AbstractArray{T}, AF::ArrayFactors{T}) where {T<:Number}
    return _adjust!(X, AF)
end

function adjust!(
    X::AbstractArray{T}, AF::ArrayFactors{U}
) where {T<:AbstractFloat,U<:Number}
    return _adjust!(X, AF)
end

function adjust!(X::AbstractArray{T}, AF::ArrayFactors{U}) where {T<:Integer,U<:Integer}
    return _adjust!(X, AF)
end

function _adjust!(X::AbstractArray, AF::ArrayFactors)
    # check dimensions
    if size(X) ≠ size(AF)
        throw(DimensionMismatch("X is incompatible with array factors"))
    end

    aligned_factors = align_margins(AF)

    # perform elementwise multiplication for each factor
    for d in 1:length(AF)
        X .*= aligned_factors[d]
    end
end

# method to align all arrays so each has dimindices 1:ndims(AM)
function align_margins(AF::ArrayFactors{T})::Vector{Array{T}} where T
    align_margins(AF.af, AF.di, AF.size)
end

"""
    Array(AF::ArrayFactors{T})

Create an array out of an ArrayFactors object.

# Arguments
- `AF::ArrayFactors{T}`: Array factors

# Examples
```julia-repl
julia> AF = ArrayFactors([[1,2,3], [4,5], [6,7]])
Factors for array of size (3, 2, 2):
    1: [1, 2, 3]
    2: [4, 5]
    3: [6, 7]

julia> Array(AF)
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
    X = ones(T, size(AF))
    adjust!(X, AF)
    return X
end
