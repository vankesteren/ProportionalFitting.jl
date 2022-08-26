using Test, ItPropFit, Logging
Logging.disable_logging(Logging.Info)

@testset "DimIndices" begin
    # Basic object & method
    di = DimIndices([1, [2, 3], [4, 5, 6]])
    @test typeof(di) == DimIndices
    @test length(di) == 3
    @test ndims(di) == 6

    # test completeness
    @test_throws ErrorException DimIndices([2, 1, [5, 4, 6]])
    
    # test uniqueness
    @test_throws ErrorException DimIndices([[2, 3, 2], 1, [5, 4, 6]])
end

@testset "ArrayMargins" begin
    # Basic object & methods
    di = DimIndices([1, 2])
    mar = ArrayMargins([[22, 26, 30], [6, 15, 24, 33]], di)
    @test typeof(mar) == ArrayMargins{Int}
    @test length(mar) == 2
    @test size(mar) == (3, 4)
    
    # Consistency check
    @test isconsistent(mar)
    
    mar_p = proportion_transform(mar)
    @test sum.(mar_p.am) == [1., 1.]

    # Constructors
    mar2 = ArrayMargins([[22, 26, 30], [6, 15, 24, 33]])
    @test mar.am == mar2.am && mar.di.idx == mar2.di.idx

    X = [1  4  7  10
         2  5  8  11
         3  6  9  12]
    mar3 = ArrayMargins(X)
    @test mar.am == mar3.am && mar.di.idx == mar3.di.idx

    mar4 = ArrayMargins(X, DimIndices([2, 1]))
    @test mar.am == reverse(mar4.am) && mar.di.idx == reverse(mar4.di.idx)

    mar5 = ArrayMargins(X, DimIndices([[2, 1]]))
    @test mar5.am[1] == X'
end

@testset "ArrayFactors" begin
    # Basic object & methods
    di = DimIndices([1, 2])
    fac = ArrayFactors([[1,2,3], [4,5]], di)
    @test size(fac) == (3, 2)
    @test eltype(fac) == Int64
    @test Array(fac) == [4 5 ; 8 10 ; 12 15]

    # constructors
    fac2 = ArrayFactors([[1,2,3], [4, 5]])
    @test fac.af == fac2.af && fac.di.idx == fac2.di.idx

    fac3 = ArrayFactors([[4, 5], [1, 2, 3]], DimIndices([2, 1]))
    @test Array(fac) == Array(fac3)

    # multidimensional madness
    di = DimIndices([1, [2, 3], 4, [5, 6, 7]])
    f1 = [.1, .6]
    f2 = [3. 2. 1. ; 6. 5. 4.]
    f3 = [.5, .1, .9]
    f4 = reshape(1.0:12.0, 2, 3, 2)
    fac4 = ArrayFactors([f1, f2, f3, f4], di)
    @test length(Array(fac4)) == prod(size(fac4))

    di = DimIndices([1, [3, 2], 4, [5, 6, 7]])
    fac5 = ArrayFactors([f1, f2', f3, f4], di)
    @test Array(fac4) ≈ Array(fac5) # nb: approx because floating point errors

    di = DimIndices([4, [3, 2], 1, [5, 6, 7]])
    fac6 = ArrayFactors([f3, f2', f1, f4], di)
    @test Array(fac4) ≈ Array(fac6)

    di = DimIndices([4, [3, 2], 1, [7, 5, 6]])
    fac7 = ArrayFactors([f3, f2', f1, permutedims(f4, [3, 1, 2])], di)
    @test Array(fac4) ≈ Array(fac7)
end

@testset "Two-dimensional ipf" begin
    # Basic example with convenient interface
    X = [40 30 20 10; 35 50 100 75; 30 80 70 120; 20 30 40 50]
    u = [150, 300, 400, 150]
    v = [200, 300, 400, 100]

    AF = ipf(X, [u, v])
    X_prime = Array(AF) .* X
    AM = ArrayMargins(X_prime)
    @test AM.am ≈ [u, v]

    # Margins only
    AF = ipf([u, v])
    AM = ArrayMargins(Array(AF))
    @test AM.am ≈ [u, v]

    # Inconsistent margins
    w = [15, 30, 40, 15]
    AF = ipf(X, [w, v]) 
    AM = ArrayMargins(X ./ sum(X) .* Array(AF))
    @test AM.am ≈ [w ./ sum(w), v ./ sum(v)]

    # Large 100 x 100 matrix
    X = reshape(repeat(1:16, 625), 100, 100)
    Y = reshape(repeat(1:5, 2000), 100, 100) + X
    m = ArrayMargins(Y)
    AF = ipf(X, m)
    X_prime = Array(AF) .* X
    AM = ArrayMargins(X_prime)
    @test AM.am ≈ m.am    
end

@testset "Multidimensional ipf" begin
    # Small three-dimensional case
    X = reshape(1:12, 2, 3, 2)
    m = ArrayMargins([[48, 60], [28, 36, 44], [34, 74]])
    AF = ipf(X, m)
    X_prime = Array(AF) .* X
    AM = ArrayMargins(X_prime)
    @test AM.am ≈ m.am

    # large five-dimensional case
    X = reshape(repeat(1:12, 100), 6, 4, 2, 5, 5)
    Y = reshape(repeat(1:5, 240), 6, 4, 2, 5, 5) + X
    m = ArrayMargins(Y)
    AF = ipf(X, m)
    X_prime = Array(AF) .* X
    AM = ArrayMargins(X_prime)
    @test AM.am ≈ m.am

    # large five-dimensional case with multidimensional margins
    di = DimIndices([[1, 2], [3, 4, 5]])
    m = ArrayMargins(Y, di)
    AF = ipf(X, m)
    X_prime = Array(AF) .* X
    AM = ArrayMargins(X_prime, di)
    @test AM.am ≈ m.am

    # large five-dimensional case with unordered multidimensional margins
    di = DimIndices([[1, 4], [5, 2, 3]])
    m = ArrayMargins(Y, di)
    AF = ipf(X, m)
    X_prime = Array(AF) .* X
    AM = ArrayMargins(X_prime, di)
    @test AM.am ≈ m.am
end

