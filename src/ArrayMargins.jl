"""
    ArrayMargins(am::Vector{<:AbstractArray}, di::DimIndex)
    ArrayMargins(am::Vector{<:AbstractArray})
    ArrayMargins(X::AbstractArray)
    ArrayMargins(X::AbstractArray, di::DimIndex)

ArrayMargins are marginal sums of an array, combined with the 
indices of the dimensions these sums belong to. The marginal
sums can be multidimensional arrays themselves.

There are various constructors for ArrayMargins, based on either
raw margins or an actual array from which the margins are then
computed.

see also: [`DimIndex`](@ref), [`ArrayFactors`](@ref)

# Fields
- `am::Vector{AbstractArray}`: Vector of marginal sums.
- `di::DimIndex`: Dimension indices to which the elements of `am` belong.

# Examples
```julia-repl
julia> X = reshape(1:12, 2, 3, 2)
2×3×2 reshape(::UnitRange{Int64}, 2, 3, 2) with eltype Int64:
[:, :, 1] =
 1  3  5
 2  4  6

[:, :, 2] =
 7   9  11
 8  10  12

julia> ArrayMargins(X)
Margins from 3D array:
  1: [36, 42]
  2: [18, 26, 34]
  3: [21, 57]

julia> ArrayMargins(X, [1, [2, 3]])
Margins from 3D array:
  1: [36, 42]
  [2, 3]: [3 15; 7 19; 11 23]

julia> ArrayMargins(X, [1, [3, 2]])
Margins from 3D array:
  1: [36, 42]
  [3, 2]: [3 7 11; 15 19 23]
```
"""
struct ArrayMargins{T}
    am::Vector{AbstractArray{T}}
    di::DimIndex
end

# Constructors based on margins
function ArrayMargins(am::Vector{<:AbstractArray{T}}) where T 
    nd = ndims.(am)
    j = 0
    di = []
    for i in nd
        push!(di, collect((j+1):(j+i)))
        j += i
    end
    ArrayMargins(Vector{AbstractArray{T}}(am), DimIndex(di))
end

function ArrayMargins(am::Vector{<:AbstractArray{T}}, DI::Vector) where T
    ArrayMargins(Vector{AbstractArray{T}}(am), DimIndex(DI))
end

# Constructors based on arrays
function ArrayMargins(X::AbstractArray, DI::DimIndex)
    D = ndims(X)
    if D != ndims(DI)
        throw(DimensionMismatch("Dimensions of X ($(ndims(X))) mismatch DI ($(ndims(DI)))."))
    end

    # in case of unsorted dimidx, change the array dimensions
    if !issorted(DI)
        X = permutedims(X, vcat(DI.idx...))
    end
    
    # create the margins
    am = Vector{AbstractArray{eltype(X)}}()
    for dim in DI.idx
        notd = Tuple(setdiff(1:D, dim))
        mar = dropdims(sum(X; dims = notd); dims = notd)
        push!(am, mar)
    end
    return ArrayMargins(am, DI)
end
ArrayMargins(X::AbstractArray) = ArrayMargins(X, DimIndex([1:ndims(X)...]))
ArrayMargins(X::AbstractArray, DI::Vector) = ArrayMargins(X, DimIndex(DI))

# Base methods
function Base.show(io::IO, AM::ArrayMargins)
    print(io, "Margins of $(ndims(AM.di))D array:")
    for i in 1:length(AM.am)
        print(io, "\n  $(AM.di.idx[i]): ")
        show(io, AM.am[i])
    end
end
Base.length(AM::ArrayMargins) = length(AM.am)
