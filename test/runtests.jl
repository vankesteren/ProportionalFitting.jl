using Test, ItPropFit

@testset "Two-dimensional case" begin
    # Basic example
    X = [40 30 20 10; 35 50 100 75; 30 80 70 120; 20 30 40 50]
    u = [150, 300, 400, 150]
    v = [200, 300, 400, 100]

    AF = ipf(X, [u, v])
    @test margins(Array(AF) .* X) ≈ [u, v]

    # Large 100 x 100 matrix
    X = reshape(repeat(1:16, 625), 100, 100)
    Y = reshape(repeat(1:5, 2000), 100, 100) + X
    m = margins(Y)
    
    AF = ipf(X, m)
    @test margins(Array(AF) .* X) ≈ m
end

@testset "Multidimensional case" begin
    # Small three-dimensional case
    X = reshape(1:12, 2, 3, 2)
    m = [[48, 60], [28, 36, 44], [34, 74]]
    AF = ipf(X, m)
    @test margins(Array(AF) .* X) ≈ m

    # large six-dimensional case
    X = reshape(repeat(1:12, 100), 6, 4, 2, 5, 5)
    Y = reshape(repeat(1:5, 240), 6, 4, 2, 5, 5) + X
    m = margins(Y)
    AF = ipf(X, m)
    @test margins(Array(AF) .* X) ≈ m
end

