# ItPropFit

Documentation for [ItPropFit](https://github.com/vankesteren/ItPropFit.jl): multidimensional iterative proportional fitting in Julia.

## Getting started

```julia
X = [40 30 20 10; 35 50 100 75; 30 80 70 120; 20 30 40 50]
u = [150, 300, 400, 150]
v = [200, 300, 400, 100]
AF = ipf(X, [u, v])
Array(AF) .* X
```
```
4×4 Matrix{Float64}:
 64.5585   46.2325   35.3843   3.82473
 49.9679   68.1594  156.499   25.3742
 56.7219  144.428   145.082   53.7673
 28.7516   41.18     63.0347  17.0337
```
