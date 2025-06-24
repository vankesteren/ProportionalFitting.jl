
# method to align margins according to the size of a larger array
function align_margins(arr::AbstractArray, idx::Vector{Int}, shape::Tuple)
    # sort dimensions if necessary
    sp = sortperm(idx)
    permuted_arr = PermutedDimsArray(arr, sp) # use a view unlike permutedims()
    # create correct shape for elementwise operations
    shp = ntuple(i -> i ∉ idx ? 1 : shape[i], length(shape))
    return reshape(permuted_arr, shp)
end

# method to align all arrays so each has dimindices 1:length(shape)
function align_margins(A::Vector{<:AbstractArray}, DI::DimIndices, shape::Tuple)
    map(A, DI.idx) do arr, idx
        align_margins(arr, idx, shape)
    end
end

# get all shared subsets of dimensions
function shared_dimension_subsets(DI::DimIndices)
    single_dimensions = [[i] for i in 1:ndims(DI)]
    shared_subsets = collect(
        intersect(DI.idx[[i, j]]...) for i in 1:length(DI) for j in (i + 1):length(DI)
    )
    return unique(vcat(single_dimensions, shared_subsets))
end
