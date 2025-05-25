using Test, ProportionalFitting

@testset "DimIndices" begin
    # Basic object & method
    di = DimIndices([1, [2, 3], [4, 5, 6]])
    @test typeof(di) == DimIndices
    @test length(di) == 3
    @test ndims(di) == 6

    # Test with duplicated dimensions
    di = DimIndices([[5, 2, 4], [1, 4, 3], [2, 5, 1], [4, 2]])
    @test typeof(di) == DimIndices
    @test length(di) == 4
    @test ndims(di) == 5

    # test completeness
    @test_throws ErrorException DimIndices([2, 1, [5, 4, 6]])

    # test uniqueness
    @test_throws ErrorException DimIndices([[2, 3, 2], 1, [5, 4, 6]])
    @test_throws ErrorException DimIndices([[2, 3], 1, [5, 4, 6], [3, 2]])

    # test subsets allowed
    @test_nowarn DimIndices([[1, 3], 1, [5, 4, 6], [3, 2], [4, 5]])
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
    @test sum.(mar_p.am) == [1.0, 1.0]

    # Constructors
    mar2 = ArrayMargins([[22, 26, 30], [6, 15, 24, 33]])
    @test mar.am == mar2.am && mar.di.idx == mar2.di.idx

    X = [
        1 4 7 10
        2 5 8 11
        3 6 9 12
    ]
    mar3 = ArrayMargins(X)
    @test mar.am == mar3.am && mar.di.idx == mar3.di.idx

    mar4 = ArrayMargins(X, DimIndices([2, 1]))
    @test mar.am == reverse(mar4.am) && mar.di.idx == reverse(mar4.di.idx)

    mar5 = ArrayMargins(X, DimIndices([[2, 1]]))
    @test mar5.am[1] == X'

    # Test for overlapping dimension case, as well as Float64 type
    di = DimIndices([[5, 2, 4], [1, 4, 3], [2, 5, 1], [4, 2]])
    X = convert(Array{Float64}, reshape(repeat(1:20, 15), 3, 2, 5, 2, 5))
    mar6 = ArrayMargins(X, di)
    @test typeof(mar6) == ArrayMargins{Float64}
    @test length(mar6) == 4
    @test ndims(mar6) == 5
    @test size(mar6) == (3, 2, 5, 2, 5)

    # Consistency check
    @test isconsistent(mar6)
    mar6_p = proportion_transform(mar6)
    @test sum.(mar6_p.am) ≈ fill(1.0, 4)
    @test margin_totals_match(mar6)

    # Check we can catch margin inconsistency
    mar7 = deepcopy(mar6)
    mar7.am[2][1, 2, 4] += 1 #augment one value by one
    @test !isconsistent(mar7)
    @test_warn r"Margin totals do not match" margin_totals_match(mar7)

    # Check we can achieve proportion consistency even if margin totals are not consistent
    mar8 = deepcopy(mar6)
    mar8.am[1] .*= 2.5 #scale
    @test !isconsistent(mar8; tol=sqrt(eps(Float64)))
    @test_warn r"Margin totals do not match" margin_totals_match(mar8)
    mar8_p = proportion_transform(mar8)
    @test isconsistent(mar8_p; tol=sqrt(eps(Float64)))
    @test_nowarn margin_totals_match(mar8_p; tol=sqrt(eps(Float64)))

    # Test we catch mismatched lengths of repeated dimensions
    target_13 = fill(3, (2, 4))
    target_23 = fill(2, (3, 4))
    di = DimIndices([[1, 3], [2, 1]]) #incorrect should be [[1,3], [2,3]]
    @test_throws DimensionMismatch m = ArrayMargins([target_13, target_23], di)
end

@testset "ArrayFactors" begin
    # Basic object & methods
    di = DimIndices([1, 2])
    fac = ArrayFactors([[1, 2, 3], [4, 5]], di)
    @test size(fac) == (3, 2)
    @test eltype(fac) == Int64
    @test Array(fac) == [4 5; 8 10; 12 15]

    # constructors
    fac2 = ArrayFactors([[1, 2, 3], [4, 5]])
    @test fac.af == fac2.af && fac.di.idx == fac2.di.idx

    fac3 = ArrayFactors([[4, 5], [1, 2, 3]], DimIndices([2, 1]))
    @test Array(fac) == Array(fac3)

    # adjust method
    X = [
        1 2
        3 4
        5 6
    ]

    @test X .* Array(fac3) == [
        4 10
        24 40
        60 90
    ]

    adjust!(X, fac3)

    @test X == [
        4 10
        24 40
        60 90
    ]

    # multidimensional madness
    di = DimIndices([1, [2, 3], 4, [5, 6, 7]])
    f1 = [0.1, 0.6]
    f2 = [3.0 2.0 1.0; 6.0 5.0 4.0]
    f3 = [0.5, 0.1, 0.9]
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

    # repeated dimension case
    di = DimIndices([[1, 2], [4, 2, 3], [3, 1]])
    f5 = reshape(10:13, 2, 2)
    # test error
    @test_throws DimensionMismatch fac8 = ArrayFactors([f2, f4, f2'], di)
    # test correct version
    fac9 = ArrayFactors([f2, f4, f5], di)
    @test size(fac9) == (2, 3, 2, 2)
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

@testset "Multidimensional ipf with repeated dimensions" begin
    #Simple case
    X = reshape(repeat(1:6, 4), 2, 3, 4)
    Y = reshape(repeat(1:4, 6), 2, 3, 4) + X
    di = DimIndices([[1, 3], [2, 3]])
    m = ArrayMargins(Y, di)
    AF = ipf(X, m)
    X_prime = Array(AF) .* X
    AM = ArrayMargins(X_prime, di)
    @test AM.am ≈ m.am

    #Larger and more complex case, with unordered dimensions in margin
    X = reshape(repeat(1:15, 24), 3, 2, 4, 3, 5)
    Y = reshape(repeat(1:10, 36), 3, 2, 4, 3, 5) + X
    di = DimIndices([[1, 2], [5, 3, 4], [1, 4, 3], [2, 5]])
    m = ArrayMargins(Y, di)
    AF = ipf(X, m)
    X_prime = Array(AF) .* X
    AM = ArrayMargins(X_prime, di)
    @test AM.am ≈ m.am

    # With multiple complex relationships between overlapping dimensions
    X = reshape(repeat(1:20, 15), 3, 2, 5, 2, 5)
    Y = reshape(repeat(1:6, 50), 3, 2, 5, 2, 5) + X
    di = DimIndices([[5, 2, 4], [1, 4, 3], [2, 5, 1], [4, 2]])
    m = ArrayMargins(Y, di)
    AF = ipf(X, m)
    X_prime = Array(AF) .* X
    AM = ArrayMargins(X_prime, di)
    @test AM.am ≈ m.am
end
