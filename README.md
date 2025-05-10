# ProportionalFitting.jl

[![CI](https://github.com/vankesteren/ProportionalFitting.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/vankesteren/ProportionalFitting.jl/actions/workflows/CI.yml) 
[![devdoc](https://img.shields.io/badge/docs-dev-blue.svg)](https://vankesteren.github.io/ProportionalFitting.jl/dev)
[![stabledoc](https://img.shields.io/badge/docs-stable-blue.svg)](https://vankesteren.github.io/ProportionalFitting.jl/stable)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/JuliaDiff/BlueStyle)

Multidimensional iterative proportional fitting in Julia. 

[ProportionalFitting](https://github.com/vankesteren/ProportionalFitting.jl) implements a multidimensional version of the [factor estimation method](https://en.wikipedia.org/wiki/Iterative_proportional_fitting#Algorithm_2_(factor_estimation)) for performing iterative proportional fitting (also called RAS algorithm, raking, matrix scaling)

> Before version `0.3.0`, this package was called `ItPropFit.jl`.

## Showcase
See the full documentation and getting started [here](https://vankesteren.github.io/ProportionalFitting.jl/).

```julia
using ProportionalFitting

# matrix to be adjusted
X = [40 30 20 10; 35 50 100 75; 30 80 70 120; 20 30 40 50]

# target margins
u = [150, 300, 400, 150]
v = [200, 300, 400, 100]

# Perform iterative proportional fitting
fac = ipf(X, [u, v])
```
```
[ Info: Converged in 8 iterations.
Factors for 2D array:
  [1]: [0.9986403503185242, 0.8833622306385376, 1.1698911437112522, 0.8895042701910321]
  [2]: [1.616160156063788, 1.5431801747375655, 1.771623700829941, 0.38299396265192226]
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
ArrayMargins(Z)
```
```
Margins of 2D array:
  [1]: [150.0000000009452, 299.99999999962523, 399.99999999949796, 149.99999999993148]
  [2]: [200.0, 299.99999999999994, 399.99999999999994, 99.99999999999997]
```
