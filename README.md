# ItPropFit.jl

[![CI](https://github.com/vankesteren/ItPropFit.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/vankesteren/ItPropFit.jl/actions/workflows/CI.yml)

Multidimensional iterative proportional fitting in Julia. 

[ItPropFit](https://github.com/vankesteren/ItPropFit.jl) implements a multidimensional version of the [factor estimation method](https://en.wikipedia.org/wiki/Iterative_proportional_fitting#Algorithm_2_(factor_estimation)) for performing iterative proportional fitting (also called RAS algorithm, raking, matrix scaling)

## Showcase
See the full documentation and getting started [here](https://vankesteren.github.io/ItPropFit.jl/).

```julia
# matrix to be adjusted
X = [40 30 20 10; 35 50 100 75; 30 80 70 120; 20 30 40 50]

# target margins
u = [150, 300, 400, 150]
v = [200, 300, 400, 100]

# Perform iterative proportional fitting
fac = ipf(X, [u, v])
```
```
Factors for array of size (4, 4):
  1: [0.9986403503185242, 0.8833622306385376, 1.1698911437112522, 0.8895042701910321]
  2: [1.616160156063788, 1.5431801747375655, 1.771623700829941, 0.38299396265192226]
```
```julia
# compute adjusted matrix
Z = Array(fac) .* X
```
```
4×4 Matrix{Float64}:
 64.5585   46.2325   35.3843   3.82473
 49.9679   68.1594  156.499   25.3742
 56.7219  144.428   145.082   53.7673
 28.7516   41.18     63.0347  17.0337
```
```julia
# check that the margins are indeed [u, v]
margins(Z)
```
```
2-element Vector{Vector{Float64}}:
 [150.0000000009452, 299.99999999962523, 399.99999999949796, 149.99999999993148]
 [200.0, 299.99999999999994, 399.99999999999994, 99.99999999999997]
```
