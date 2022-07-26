# ItPropFit

Documentation for [ItPropFit](https://github.com/vankesteren/ItPropFit.jl): multidimensional iterative proportional fitting (RAS algorithm, raking) in Julia. This package implements a multidimensional version of the [factor estimation method](https://en.wikipedia.org/wiki/Iterative_proportional_fitting#Algorithm_2_(factor_estimation)). 

## Getting started

Assume you have a matrix `X`:
```julia
X = [40 30 20 10; 35 50 100 75; 30 80 70 120; 20 30 40 50]
```
```
4×4 Matrix{Int64}:
 40  30   20   10
 35  50  100   75
 30  80   70  120
 20  30   40   50
```

And the row and column margins of a matrix `Y` (`u` and `v`, respectively) but not the full matrix:
```julia
u = [150, 300, 400, 150]
v = [200, 300, 400, 100]
```

Then the `ipf` function from ItPropFit will find the array factors which adjust matrix `X` to have the margins `u` and `v`:
```julia
fac = ipf(X, [u, v])
```
```
Factors for array of size (4, 4):
  1: [0.9986403503185242, 0.8833622306385376, 1.1698911437112522, 0.8895042701910321]
  2: [1.616160156063788, 1.5431801747375655, 1.771623700829941, 0.38299396265192226]
```

Array factors (`ArrayFactors`) are a specific type exported by ItPropFit with a few methods, for example `Array()`:

```julia
Array(fac)
```
```
4×4 Matrix{Float64}:
 1.61396  1.54108  1.76921  0.382473
 1.42765  1.36319  1.56499  0.338322
 1.89073  1.80535  2.07261  0.448061
 1.43758  1.37267  1.57587  0.340675
```

To create the adjusted matrix `Z` with the margins `u` and `v`, we perform elementwise multiplication of this matrix with `X`:
```julia
Z = Array(AF) .* X
```
```
4×4 Matrix{Float64}:
 64.5585   46.2325   35.3843   3.82473
 49.9679   68.1594  156.499   25.3742
 56.7219  144.428   145.082   53.7673
 28.7516   41.18     63.0347  17.0337
```

We can then check that the marginal sum totals are correct:

```julia
margins(Z)
```
```
2-element Vector{Vector{Float64}}:
 [150.0000000009452, 299.99999999962523, 399.99999999949796, 149.99999999993148]
 [200.0, 299.99999999999994, 399.99999999999994, 99.99999999999997]
```

## Multidimensional arrays

ItPropFit can also deal with multidimensional arrays of arbitrary shape. For example, consider the following `(3, 2, 3)` array and target margins:
```julia
X = reshape(1:12, 2, 3, 2)
```
```
2×3×2 reshape(::UnitRange{Int64}, 2, 3, 2) with eltype Int64:
[:, :, 1] =
 1  3  5
 2  4  6

[:, :, 2] =
 7   9  11
 8  10  12
```
```julia
m = [[48, 60], [28, 36, 44], [34, 74]]
```
```
3-element Vector{Vector{Int64}}:
 [48, 60]
 [28, 36, 44]
 [34, 74]
```

Now we can run `ipf` to compute the adjustment:

```julia
fac = ipf(X, m)
```
```
Factors for array of size (2, 3, 2):
  1: [0.7012649814229596, 0.7413620380098563]
  2: [1.59452605457307, 1.3830398765538434, 1.2753933840995484]
  3: [1.6474060813606772, 1.2880517029245548]
```

And we can create the adjusted array `Z`:

```julia
Array(fac) .* X
```
```
2×3×2 Array{Float64, 3}:
[:, :, 1] =
 1.84211  4.79335  7.36711
 3.89487  6.75656  9.34601

[:, :, 2] =
 10.082   11.2433  12.6722
 12.1811  13.2068  14.6147
```

## Benchmarks
```julia
using BenchmarkTools, ItPropFit
```

### Default example
```julia
X = [40 30 20 10; 35 50 100 75; 30 80 70 120; 20 30 40 50]
u = [150, 300, 400, 150]
v = [200, 300, 400, 100]
@benchmark ipf(X, [u, v])
```
```
Range (min … max):  141.600 μs …   5.430 ms  ┊ GC (min … max): 0.00% … 95.50%
Time  (median):     164.600 μs               ┊ GC (median):    0.00%
Time  (mean ± σ):   172.824 μs ± 187.560 μs  ┊ GC (mean ± σ):  4.25% ±  3.81%
```

### Large contingency table

```julia
X = reshape(repeat(1:16, 625), 100, 100)
Y = reshape(repeat(1:5, 2000), 100, 100) + X
m = margins(Y)
@benchmark ipf(X, m)
```
```
 Range (min … max):  1.810 ms …   6.187 ms  ┊ GC (min … max): 0.00% … 52.10%
 Time  (median):     2.388 ms               ┊ GC (median):    0.00%
 Time  (mean ± σ):   2.505 ms ± 634.073 μs  ┊ GC (mean ± σ):  6.53% ± 12.41%
```

### Six-dimensional contingency table

```julia
X = reshape(repeat(1:12, 100), 6, 4, 2, 5, 5)
Y = reshape(repeat(1:5, 240), 6, 4, 2, 5, 5) + X
m = margins(Y)
@benchmark ipf(X, m)
```
```
Range (min … max):  212.638 ms … 275.426 ms  ┊ GC (min … max): 1.61% … 1.46%
Time  (median):     222.012 ms               ┊ GC (median):    1.66%
Time  (mean ± σ):   228.216 ms ±  17.316 ms  ┊ GC (mean ± σ):  1.76% ± 0.41%
```
