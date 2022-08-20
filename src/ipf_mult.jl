# TODO: work with arraymargins and dimindices
function ipf_mult(X::AbstractArray{<:Real}, AM::ArrayMargins; maxiter::Int = 1000, tol::Float64 = 1e-10)
    # dimension check
    J = length(mar)
    D = ndims(mar)
    DX = ndims(X)
    if DX != D
        throw(DimensionMismatch("The number of margins ($D) needs to equal ndims(X) = $DX."))
    end
    D_size = size.(mar)
    if size(X) != flatten(D_size...)
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
    mar_seed = margins(X, dims...)
    fac = [mar[i] ./ mar_seed[i] for i in 1:J]
    X_prod = copy(X)

    # start iteration
    iter = 0
    crit = 0.
    for i in 1:maxiter
        iter += 1
        oldfac = deepcopy(fac)

        for j in 1:J # loop over margins
            # get complement dimensions
            notj = setdiff(1:J, j)
            notd = Tuple.(setdiff(dims, [dims[j]]))
            flat_notd = flatten(notd...)

            # multiply by complement factors

            X_prod = mapslices(x -> x .* fac[notj[1]], X, dims = notd[1])
            if (J > 2)
                for k in 2:(J-1)
                    X_prod = mapslices(x -> x .* fac[notj[k]], X_prod, dims = notd[k])
                end
            end

            # then sum over everything but d
            s = dropdims(sum(X_prod; dims = flat_notd), dims = flat_notd)

            # update this factor
            fac[j] = mar[j] ./ s
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