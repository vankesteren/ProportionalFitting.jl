# flatten nested tuples into single tuple
# https://discourse.julialang.org/t/efficient-tuple-concatenation/5398/10
flatten(x::Tuple) = x
flatten(x::Tuple, y::Tuple) = (x..., y...)
flatten(x::Tuple, y::Tuple, z::Tuple...) = (x..., flatten(y, z...)...)

# margins to dims
function getdims(m::Vector{<:AbstractArray})
    nd = ndims.(m)
    j = 0
    dd = []
    for i in nd
        push!(dd, collect((j+1):(j+i)))
        j += i
    end
    return dd
end

# dict methods for future reference
Base.Dict(AM::ArrayMargins) = Dict(AM.di[i] => AM.am[i] for i in 1:length(AM))
Base.Dict(AF::ArrayFactors) = Dict(AF.di[i] => AF.af[i] for i in 1:length(AF))