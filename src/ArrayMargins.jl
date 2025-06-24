"""
    ArrayMargins(am::Vector{<:AbstractArray}, di::DimIndices)
    ArrayMargins(am::Vector{<:AbstractArray}, di::Vector)
    ArrayMargins(am::Vector{<:AbstractArray})
    ArrayMargins(X::AbstractArray, di::DimIndices)
    ArrayMargins(X::AbstractArray)

ArrayMargins are marginal sums of an array, combined with the
indices of the dimensions these sums belong to. The marginal
sums can be multidimensional arrays themselves.

There are various constructors for ArrayMargins, based on either
raw margins or an actual array from which the margins are then
computed.

see also: [`DimIndices`](@ref), [`ArrayFactors`](@ref), [`ipf`](@ref)

# Fields
- `am::Vector{AbstractArray}`: Vector of marginal sums.
- `di::DimIndices`: Dimension indices to which the elements of `am` belong.

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
  [1]: [36, 42]
  [2]: [18, 26, 34]
  [3]: [21, 57]

julia> ArrayMargins(X, [1, [2, 3]])
Margins from 3D array:
  [1]: [36, 42]
  [2, 3]: [3 15; 7 19; 11 23]

julia> ArrayMargins(X, [2, [3, 1]])
Margins of 3D array:
  [2]: [18, 26, 34]
  [3, 1]: [9 12; 27 30]
```
"""
struct ArrayMargins{T}
    am::Vector{<:AbstractArray{T}}
    di::DimIndices
    size::Tuple

    # loop to check dimension sizes
    function ArrayMargins(am::Vector{<:AbstractArray{T}}, di::DimIndices) where {T}
        # loop over arrays then dimensions to get size, checking for mismatches
        dimension_sizes = zeros(Int, ndims(di))
        for i in 1:length(am)
            for (j, d) in enumerate(di.idx[i])
                new_size = size(am[i], j)
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
        return new{T}(am, di, Tuple(dimension_sizes))
    end
end

# Constructor for mixed-type arraymargins needs promotion before construction
function ArrayMargins(am::Vector{<:AbstractArray}, di::DimIndices)
    AT = eltype(am)
    PT = promote_type(eltype.(am)...)
    return ArrayMargins(Vector{AT{PT}}(am), di)
end

# Constructor promoting vector to dimindices
ArrayMargins(am::Vector{<:AbstractArray}, di::Vector) = ArrayMargins(am, DimIndices(di))

# Constructor based on margins without indices
ArrayMargins(am::Vector{<:AbstractArray}) = ArrayMargins(am, default_dimindices(am))

# Constructor based on array
function ArrayMargins(X::AbstractArray, di::DimIndices)
    D = ndims(X)
    if D != ndims(di)
        throw(
            DimensionMismatch("Dimensions of X ($(ndims(X))) mismatch DI ($(ndims(di))).")
        )
    end

    # create the margins
    am = Vector{AbstractArray{eltype(X)}}()
    for dim in di.idx
        notd = Tuple(setdiff(1:D, dim))
        mar = dropdims(sum(X; dims=notd); dims=notd)
        if !issorted(dim)
            mar = permutedims(mar, sortperm(sortperm(dim)))
        end
        push!(am, mar)
    end
    return ArrayMargins(am, di)
end
ArrayMargins(X::AbstractArray) = ArrayMargins(X, DimIndices([1:ndims(X)...]))
ArrayMargins(X::AbstractArray, DI::Vector) = ArrayMargins(X, DimIndices(DI))

# Base methods
function Base.show(io::IO, AM::ArrayMargins)
    print(io, "Margins of $(ndims(AM.di))D array:")
    for i in 1:length(AM.am)
        print(io, "\n  $(AM.di.idx[i]): ")
        show(io, AM.am[i])
    end
end

Base.size(AM::ArrayMargins) = AM.size
Base.length(AM::ArrayMargins) = length(AM.am)
Base.ndims(AM::ArrayMargins) = length(AM.size)

function Base.convert(T::DataType, AM::ArrayMargins)::ArrayMargins{T}
    new_margins = [convert.(T, arr) for arr in AM.am]
    return ArrayMargins(new_margins, AM.di)
end

# method to align all arrays so each has dimindices 1:ndims(AM)
function align_margins(AM::ArrayMargins{T})::Vector{Array{T}} where {T}
    return align_margins(AM.am, AM.di, AM.size)
end

# method for consistency of margin totals
function isconsistent(am::Vector{<:AbstractArray}; tol::AbstractFloat=1e-10)
    marsums = sum.(am)
    return (maximum(marsums) - minimum(marsums)) < tol
end

isconsistent(AM::ArrayMargins; tol::AbstractFloat=1e-10) = isconsistent(AM.am; tol=tol)

# method for transforming aligned margins to proportions
function proportion_transform(am::Vector{<:AbstractArray})
    return am ./ sum.(am)
end

# method for transforming ArrayMargins
function proportion_transform(AM::ArrayMargins)
    return ArrayMargins(proportion_transform(AM.am), AM.di)
end

# method to check totals across repeated dimensions
function margin_totals_match(
    am::Vector{<:AbstractArray}, di::DimIndices; tol::AbstractFloat=1e-10
)

    # get all shared subsets of dimensions
    shared_subsets = shared_dimension_subsets(di)

    # loop over these subsets, and check marginal totals are equal in every array margin where they appear
    check = true
    for dd in shared_subsets
        margin_totals = Vector{Array}()
        for i in 1:length(am)
            if issubset(dd, di.idx[i])
                complement_dims = setdiff(1:ndims(di), dd)
                push!(margin_totals, sum(am[i]; dims=complement_dims))
            end
        end
        if !all(x -> isapprox(x, margin_totals[1]; atol=tol), margin_totals)
            @warn "Margin totals do not match across array margin(s): $dd"
            check = false
        end
    end

    return check
end

# method to check totals for ArrayMargins directly
function margin_totals_match(AM::ArrayMargins; tol::AbstractFloat=1e-10)
    return margin_totals_match(align_margins(AM), AM.di; tol=tol)
end

# method to force (aligned) margins to be consistent
function make_margins_consistent(am::Vector{<:AbstractArray}, di::DimIndices)
    new_am = deepcopy(am)

    # get all shared subsets of dimensions
    shared_subsets = shared_dimension_subsets(di)

    # loop over these subsets, and check marginal totals are equal in every array margin where they appear
    for dd in shared_subsets
        margin_totals = Vector{Array}()
        complement_dims = setdiff(1:ndims(di), dd)
        # calculate margin totals
        for i in 1:length(am)
            if issubset(dd, di.idx[i])
                push!(margin_totals, sum(am[i]; dims=complement_dims))
            end
        end
        # calculate average
        mean_margin_total = reduce(+, margin_totals) ./ length(margin_totals)
        # modify copy
        for i in 1:length(am)
            if issubset(dd, di.idx[i])
                new_am[i] =
                    new_am[i] ./ sum(new_am[i]; dims=complement_dims) .* mean_margin_total
            end
        end
    end

    return new_am
end
