# dict methods for future reference
Base.Dict(AM::ArrayMargins) = Dict(AM.di[i] => AM.am[i] for i in 1:length(AM))
Base.Dict(AF::ArrayFactors) = Dict(AF.di[i] => AF.af[i] for i in 1:length(AF))

# method to align margins according to the size of a larger array
function align_margins(arr::AbstractArray, idx::Vector{Int}, shape::Tuple)
    # sort dimensions if necessary
    sp = sortperm(idx)
    permuted_arr = permutedims(arr, sp)
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