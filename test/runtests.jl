using Test, ItPropFit, Random

Random.seed!(45)

@testset "Two-dimensional case" begin
    # Basic example
    X = [40 30 20 10; 35 50 100 75; 30 80 70 120; 20 30 40 50]
    u = [150, 300, 400, 150]
    v = [200, 300, 400, 100]

    AF = ipf(X, [u, v])
    @test margins(Array(AF) .* X) ≈ [u, v]

    # Large 100 x 100 matrix
    X = round.(rand(100, 100) * 20)
    Y = round.(X + (rand(100, 100) .- 0.5) .* 5)
    m = margins(Y)
    
    AF = ipf(X, m)
    @test margins(Array(AF) .* X) ≈ m
end

@testset "Multidimensional case" begin
    # Small three-dimensional case
    X = round.(rand(2, 3, 2) * 20)
    Y = round.(X + (rand(2, 3, 2) .- 0.5) .* 5)
    m = margins(Y)
    AF = ipf(X, m)
    @test margins(Array(AF) .* X) ≈ m

    # large six-dimensional case
    X = round.(rand(6, 4, 2, 5, 5) * 20)
    Y = round.(X + (rand(6, 4, 2, 5, 5) .- 0.5) .* 5)
    m = margins(Y)
    AF = ipf(X, m)
    @test margins(Array(AF) .* X) ≈ m
end

