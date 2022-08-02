struct ArrayDims
    d::Vector{Union{Int, Vector{Int}}}

    # inner constructor checking that all dims are there
    function ArrayDims(d::Vector{Union{Int, Vector{Int}}})
        D = maximum(maximum.(d))
        dmissing = setdiff(1:D, vcat(d...))
        length(dmissing) > 0 ? error("Missing array dimensions: $dmissing.") : new(d)
    end    
end

ArrayDims(X::Vector) = ArrayDims(Vector{Union{Int, Vector{Int}}}(X))

Base.ndims(x::ArrayDims) = maximum(maximum.(x.d))
Base.length(v::ArrayDims) = length(v.d)
Base.issorted(r::ArrayDims) = issorted(vcat(r.d...))

function Base.show(io::IO, A::ArrayDims)
    println(io, "ArrayDims for $(ndims(A))D array:")
    print("[")
    for i in 1:length(A)
        show(io, A.d[i])
        if i != length(A) print(", ") end
    end
    print("]")
end
