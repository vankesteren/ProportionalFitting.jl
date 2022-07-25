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
