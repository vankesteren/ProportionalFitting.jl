"""
    ipf(X, mar[; maxiter, tol])

Perform iterative proportional fitting (factor method). The array (X) can be
any number of dimensions, as long as the margins have the correct size.
Will return the weights as an ArrayFactors object. 

see also: [`ArrayFactors`](@ref), [`margins`](@ref)

# Arguments
- `X::AbstractArray{<:Real}`: Array to be adjusted
- `mar::Vector{<:Vector{<:Real}}`: Target margins
- `maxiter::Int=1000`: Maximum number of iterations
- `tol::Float64=1e-10`: Factor change tolerance for convergence

# Examples
```julia-repl
julia> X = [40 30 20 10; 35 50 100 75; 30 80 70 120; 20 30 40 50]
julia> u = [150, 300, 400, 150]
julia> v = [200, 300, 400, 100]
julia> AF = ipf(X, [u, v])
Factors for array of size (4, 4):
    1: [1.2513914546748504, 1.1069369933423092, 1.4659850061977997, 1.1146335537777001]
    2: [1.2897345098410427, 1.2314947369488765, 1.4137981417470917, 0.305638354490167]

julia> Array(AF) .* X
4×4 Matrix{Float64}:
 64.5585   46.2325   35.3843   3.82473
 49.9679   68.1594  156.499   25.3742
 56.7219  144.428   145.082   53.7673
 28.7516   41.18     63.0347  17.0337
```
"""
function ipf(X::AbstractArray{<:Real}, mar::Vector{<:Vector{<:Real}}; maxiter::Int = 1000, tol::Float64 = 1e-10)
    # dimension check
    D = length(mar)
    DX = ndims(X)
    if DX != D
        throw(DimensionMismatch("The number of margins ($D) needs to equal ndims(X) = $(ndims(X))."))
    end
    D_len = length.(mar)
    if size(X) != Tuple(D_len)
        throw(DimensionMismatch("The size of the margins $D_len needs to equal size(X) = $(size(X))."))
    end

    # margin consistency check
    marsums = sum.(mar)
    if (maximum(marsums) - minimum(marsums)) > tol
        # transform to proportions
        @info "Inconsistent target margins, converting `X` and `mar` to proportions. Margin totals: $marsums" 
        X /= sum(X)
        mar = convert.(Vector{Float64}, mar) ./ marsums
    end

    # initialization (simplified first iteration)
    fac = [mar[d] ./ vec(sum(X; dims = setdiff(1:D, d))) for d in 1:D]
    X_prod = copy(X)

    # start iteration
    iter = 0
    crit = 0.
    for i in 1:maxiter
        iter += 1
        oldfac = deepcopy(fac)

        for d in 1:D
            # get complement dimensions
            notd = setdiff(1:D, d)
            
            # multiply by complement factors
            X_prod = mapslices(x -> x .* fac[notd[1]], X, dims = notd[1])
            if (D > 2)
                for nd in notd[2:end]
                    X_prod = mapslices(x -> x .* fac[nd], X_prod, dims = nd)
                end
            end

            # then sum over everything but d
            s = vec(sum(X_prod; dims = notd))

            # update this factor
            fac[d] = mar[d] ./ s
        end

        # convergence check
        crit = maximum(broadcast(x -> maximum(abs.(x)), fac - oldfac))
        if crit < tol break end
    end

    if iter == maxiter
        @warn "Did not converge. Try increasing the number of iterations. Maximum absolute difference between subsequent iterations: $crit" 
    else 
        @info "Converged in $iter iterations."
    end

    return ArrayFactors(fac)
end