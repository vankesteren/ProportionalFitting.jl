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
    function ArrayMargins(am::Vector{<:AbstractArray{T}}, di::DimIndices) where T
        # loop over arrays then dimensions to get size, checking for mismatches
        dimension_sizes = zeros(Int, ndims(di))
        for i in 1:length(am)
            for (j, d) in enumerate(di.idx[i])
                new_size = size(am[i], j)
                if dimension_sizes[d] == 0 
                    dimension_sizes[d] = new_size
                else # check
                    dimension_sizes[d] == new_size || throw(DimensionMismatch("Dimension sizes not equal for dimension $d: $(dimension_sizes[d]) and $new_size"))
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
    ArrayMargins(Vector{AT{PT}}(am), di)
end

# Constructor promoting vector to dimindices
ArrayMargins(am::Vector{<:AbstractArray}, di::Vector) = ArrayMargins(am, DimIndices(di))

# Constructor based on margins without indices
ArrayMargins(am::Vector{<:AbstractArray}) = ArrayMargins(am, default_dimindices(am))

# Constructor based on array
function ArrayMargins(X::AbstractArray, di::DimIndices)
    D = ndims(X)
    if D != ndims(di)
        throw(DimensionMismatch("Dimensions of X ($(ndims(X))) mismatch DI ($(ndims(di)))."))
    end

    # create the margins
    am = Vector{AbstractArray{eltype(X)}}()
    for dim in di.idx
        notd = Tuple(setdiff(1:D, dim))
        mar = dropdims(sum(X; dims = notd); dims = notd)
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

# methods for consistency of margins
function isconsistent(AM::ArrayMargins; tol::Float64 = eps(Float64))
    marsums = sum.(AM.am)
    return (maximum(marsums) - minimum(marsums)) < tol
end

function proportion_transform(AM::ArrayMargins)
    mar = convert.(Array{Float64}, AM.am) ./ sum.(AM.am)
    return ArrayMargins(mar, AM.di)
end

function check_margin_totals(AM::ArrayMargins; tol::Float64 = eps(Float64))

    #get all shared subsets of dimensions
    shared_subsets = vcat(
        [[i] for i in 1:ndims(AM)], #Single dimensions
        unique(intersect(AM.di.idx[[i,j]]...) for i in 1:length(AM.di.idx) for j in i+1:length(AM.di.idx)) #Shared subsets
    )

    #loop over these subsets, and check marginal totals are equal in every array margin where they appear
    check = true
    for dd in shared_subsets
        margin_totals = Vector{Array{Float64}}()
        for i in 1:length(AM.am)
            if issubset(dd, AM.di.idx[i])
                dims_to_sum = findall(x -> !in(x, dd), AM.di.idx[i])
                margin_total = dropdims(sum(AM.am[i]; dims = dims_to_sum); dims = Tuple(dims_to_sum))
                #reshape
                remaining_dims = filter(d -> d in dd, AM.di.idx[i])
                perm_order = [findfirst(==(d), remaining_dims) for d in dd]
                push!(margin_totals, permutedims(margin_total, perm_order))
            end
        end
        if !all(x -> isapprox(x, margin_totals[1]; atol = tol), margin_totals)
            @warn "Margin totals do not match across array margin(s): $dd"
            check = false
        end
    end

    return check
end

