# Benchmarks
```julia
using BenchmarkTools, ItPropFit, Logging
Logging.disable_logging(Logging.Info)
```

The benchmarks below were run on Julia 1.7.2.

### Default example
```julia
X = [40 30 20 10; 35 50 100 75; 30 80 70 120; 20 30 40 50]
u = [150, 300, 400, 150]
v = [200, 300, 400, 100]
@benchmark ipf(X, [u, v])
```
```
Range (min … max):  140.900 μs …   4.671 ms  ┊ GC (min … max): 0.00% … 95.78%
Time  (median):     152.100 μs               ┊ GC (median):    0.00%
Time  (mean ± σ):   166.711 μs ± 170.558 μs  ┊ GC (mean ± σ):  4.01% ±  3.82%
```

### Large contingency table
```julia
X = reshape(repeat(1:16, 625), 100, 100)
Y = reshape(repeat(1:5, 2000), 100, 100) + X
m = margins(Y)
@benchmark ipf(X, m)
```
```
Range (min … max):  1.319 ms …   5.078 ms  ┊ GC (min … max): 0.00% … 47.57%
Time  (median):     1.483 ms               ┊ GC (median):    0.00%
Time  (mean ± σ):   1.699 ms ± 518.851 μs  ┊ GC (mean ± σ):  7.66% ± 13.26%
```

### Six-dimensional contingency table
```julia
X = reshape(repeat(1:12, 100), 6, 4, 2, 5, 5)
Y = reshape(repeat(1:5, 240), 6, 4, 2, 5, 5) + X
m = margins(Y)
@benchmark ipf(X, m)
```
```
Range (min … max):  163.341 ms … 195.328 ms  ┊ GC (min … max): 2.67% … 2.66%
Time  (median):     171.324 ms               ┊ GC (median):    2.51%
Time  (mean ± σ):   172.793 ms ±   7.910 ms  ┊ GC (mean ± σ):  2.65% ± 0.44%
```
