function ipf_mult(X::AbstractArray{<:Real}, mar::Vector; maxiter::Int = 1000, tol::Float64 = 1e-10)
    # dimension check
    D = sum(ndims.(mar))
    DX = ndims(X)
    if DX != D
        throw(DimensionMismatch("The number of margins ($D) needs to equal ndims(X) = $DX."))
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