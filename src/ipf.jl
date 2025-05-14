"""
    ipf(X::AbstractArray{<:Real}, mar::ArrayMargins; maxiter::Int = 1000, tol::Float64 = 1e-10)
    ipf(X::AbstractArray{<:Real}, mar::Vector{<:Vector{<:Real}})
    ipf(mar::ArrayMargins)
    ipf(mar::Vector{<:Vector{<:Real}})

Perform iterative proportional fitting (factor method). The array (X) can be
any number of dimensions, and the margins can be multidimensional as well. 
If only the margins are given, then the seed matrix `X` is assumed
to be an array filled with ones of the correct size and element type.

If the margins are not an ArrayMargins object, they will be coerced to this type.

This function returns the update matrix as an ArrayFactors object. To compute
the updated matrix, use `Array(result) .* X` (see examples).

see also: [`ArrayFactors`](@ref), [`ArrayMargins`](@ref)

# Arguments
- `X::AbstractArray{<:Real}`: Array to be adjusted
- `mar::ArrayMargins`: Target margins as an ArrayMargins object
- `maxiter::Int=1000`: Maximum number of iterations
- `tol::Float64=1e-10`: Factor change tolerance for convergence

# Examples
```julia-repl
julia> X = [40 30 20 10; 35 50 100 75; 30 80 70 120; 20 30 40 50]
julia> u = [150, 300, 400, 150]
julia> v = [200, 300, 400, 100]
julia> AF = ipf(X, [u, v])
Factors for 2D array:
    [1]: [0.9986403503185242, 0.8833622306385376, 1.1698911437112522, 0.8895042701910321]
    [2]: [1.616160156063788, 1.5431801747375655, 1.771623700829941, 0.38299396265192226]

julia> Z = Array(AF) .* X
4×4 Matrix{Float64}:
 64.5585   46.2325   35.3843   3.82473
 49.9679   68.1594  156.499   25.3742
 56.7219  144.428   145.082   53.7673
 28.7516   41.18     63.0347  17.0337

julia> ArrayMargins(Z)
Margins of 2D array:
  [1]: [150.0000000009452, 299.99999999962523, 399.99999999949796, 149.99999999993148]
  [2]: [200.0, 299.99999999999994, 399.99999999999994, 99.99999999999997]
```
"""
function ipf(
    X::AbstractArray{<:Real}, mar::ArrayMargins; maxiter::Int=1000, tol::Float64=1e-10
)
    # dimension check
    if ndims(X) != ndims(mar)
        throw(
            DimensionMismatch(
                "The number of margins ($(ndims(mar))) needs to equal ndims(X) = $(ndims(X)).",
            ),
        )
    end
    if size(X) != size(mar)
        throw(
            DimensionMismatch(
                "The size of the margins $(size(mar)) needs to equal size(X) = $(size(X))."
            ),
        )
    end

    # margin consistency checks
    if !isconsistent(mar; tol=tol) || !margin_totals_match(mar; tol=tol)
        # transform to proportions
        @info "Inconsistent target margins, converting `X` and `mar` to proportions."
        X /= sum(X)
        mar = proportion_transform(mar)

        #recheck proportions across margins that appear more than once
        if !margin_totals_match(mar; tol=tol)
            throw(DimensionMismatch("Margin proportions inconsistent across dimensions"))
        end
    end

    # initialization 

    # define dimensions
    J = length(mar)
    di = mar.di
    complement_dims = Tuple.(setdiff(1:ndims(mar), dd) for dd in di.idx)

    # pre-align array margins
    aligned_margins = align_margins(mar)

    # initialize seed as aligned array margins
    aligned_seed = align_margins(ArrayMargins(X, di))

    # initialize factors to update
    fac = [aligned_margins[i] ./ aligned_seed[i] for i in 1:J]

    # copy the starting array
    X_prod = copy(X)

    # start iteration

    iter = 0
    crit = 0.0
    for i in 1:maxiter
        iter += 1
        oldfac = deepcopy(fac)

        for j in 1:J # loop over margin elements
            notj = setdiff(1:J, j) # get complement margins

            # create X multiplied by complement factors
            for k in 1:J-1 # loop over complement margins
                cur_fac = fac[notj[k]] # get current factor
                # perform elementwise multiplication
                if k == 1
                    X_prod = X .* cur_fac
                else
                    X_prod .*= cur_fac
                end
            end

            # then we compute the margin by summing over all complement dimensions
            cur_sum = sum(X_prod; dims=complement_dims[j])

            # update this factor
            fac[j] = aligned_margins[j] ./ cur_sum
        end

        # convergence check
        crit = maximum(broadcast(x -> maximum(abs.(x)), fac - oldfac))
        if crit < tol
            break
        end
    end

    if iter == maxiter
        @warn "Did not converge. Try increasing the number of iterations. Maximum absolute difference between subsequent iterations: $crit"
    else
        @info "Converged in $iter iterations."
    end

    # return factors to original margin shape
    reshaped_factors = map(1:J) do j
        reshaped_fac = dropdims(fac[j]; dims=complement_dims[j])
        if !issorted(di[j])
            sp = sortperm(sortperm(di[j]))
            permutedims(reshaped_fac, sp)
        else
            reshaped_fac
        end
    end

    return ArrayFactors(reshaped_factors, di)
end

function ipf(
    X::AbstractArray{<:Real},
    mar::Vector{<:Vector{<:Real}};
    maxiter::Int=1000,
    tol::Float64=1e-10,
)
    return ipf(X, ArrayMargins(mar); maxiter=maxiter, tol=tol)
end

function ipf(mar::ArrayMargins{T}; maxiter::Int=1000, tol::Float64=1e-10) where {T}
    return ipf(ones(T, size(mar)), mar; maxiter=maxiter, tol=tol)
end

function ipf(mar::Vector{<:Vector{<:Real}}; maxiter::Int=1000, tol::Float64=1e-10)
    return ipf(ArrayMargins(mar); maxiter=maxiter, tol=tol)
end