"""
    margins(X)

Compute the marginal sum totals for an array.

# Arguments
- `X::AbstractArray{<: Number}`: array with any number of dimensions

# Examples
```julia-repl
julia> margins(reshape(1:12, 2, 3, 2))
3-element Vector{Vector{Int64}}:
 [36, 42]
 [18, 26, 34]
 [21, 57]
```
"""
function margins(X::AbstractArray{<: Real})
    D = ndims(X)
    return [vec(sum(X; dims = setdiff(1:D, d))) for d in 1:D]
end


function margins(X::AbstractArray{<: Real}, dims::Vector{Int}...)
    D = ndims(X)
    m = []
    for d in dims
        notd = Tuple(setdiff(1:D, d))
        mar = dropdims(sum(X; dims = notd); dims = notd)
        push!(m, mar)
    end
    return m
end

# flatten nested tuples into single tuple
flatten(x::Tuple) = x
flatten(x::Tuple, y::Tuple) = (x..., y...)
flatten(x::Tuple, y::Tuple, z::Tuple...) = (x..., tuplejoin(y, z...)...)

# margins to dims
function getdims(m::Vector)
    nd = ndims.(m)
    j = 0
    dd = []
    for i in nd
        push!(dd, (j+1):(j+i))
        j += i
    end
    return dd
end