# Benchmarks
```@setup bench
using BenchmarkTools, ItPropFit, Logging
Logging.disable_logging(Logging.Info)
```

The benchmarks below were run on Julia 1.7.2.

### Default example
```@example bench
X = [40 30 20 10; 35 50 100 75; 30 80 70 120; 20 30 40 50]
u = [150, 300, 400, 150]
v = [200, 300, 400, 100]
@benchmark ipf(X, [u, v])
```

### Large contingency table
```@example bench
X = reshape(repeat(1:16, 625), 100, 100)
Y = reshape(repeat(1:5, 2000), 100, 100) + X
m = ArrayMargins(Y)
@benchmark ipf(X, m)
```

### Six-dimensional contingency table
```@example bench
X = reshape(repeat(1:12, 100), 6, 4, 2, 5, 5)
Y = reshape(repeat(1:5, 240), 6, 4, 2, 5, 5) + X
m = ArrayMargins(Y)
@benchmark ipf(X, m)
```