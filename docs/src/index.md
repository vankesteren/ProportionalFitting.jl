# ItPropFit

Multidimensional iterative proportional fitting in Julia. 

[ItPropFit](https://github.com/vankesteren/ItPropFit.jl) implements a multidimensional version of the [factor estimation method](https://en.wikipedia.org/wiki/Iterative_proportional_fitting#Algorithm_2_(factor_estimation)) for performing iterative proportional fitting (also called RAS algorithm, raking, matrix scaling). 

In the two-dimensional case, iterative proportional fitting means changing a matrix $X$ to have marginal sum totals $u, v$. One prime use is in survey data analysis, where $X$ could be your data's cross-tabulation of demographic characteristics, and $u, v$ the known population proportions of those characteristics.

## Getting started
```@setup ex
using ItPropFit
```

Assume you have a matrix `X`:
```@example ex
X = [40 30 20 10; 35 50 100 75; 30 80 70 120; 20 30 40 50]
```

And the row and column margins of another matrix `Y` (`u` and `v`, respectively) but not the full matrix:
```@example ex
u = [150, 300, 400, 150]
v = [200, 300, 400, 100]
```

Then the `ipf` function from ItPropFit will find the array factors which adjust matrix `X` to have the margins `u` and `v`:
```@example ex
fac = ipf(X, [u, v])
```

Array factors (`ArrayFactors`) are a specific type exported by ItPropFit with a few methods, for example `Array()`:

```@example ex
Array(fac)
```

To create the adjusted matrix `Z` with the margins `u` and `v`, we perform elementwise multiplication of this matrix with `X`:
```@example ex
Z = Array(fac) .* X
```


We can then check that the marginal sum totals are correct:

```@example ex
ArrayMargins(Z)
```

## Multidimensional arrays

ItPropFit can also deal with multidimensional arrays of arbitrary shape. For example, consider the following `(3, 2, 3)` array and target margins:
```@example ex
X = reshape(1:12, 2, 3, 2)
m = [[48, 60], [28, 36, 44], [34, 74]]
```

Now we can run `ipf` to compute the adjustment:

```@example ex
fac = ipf(X, m)
```

And we can create the adjusted array `Z`:

```@example ex
Array(fac) .* X
```

## Multidimensional margins

ItPropFit can also deal with multidimensional margins of arbitrary shape. For example, consider the same `(3, 2, 3)` array as before:
```@example ex
X = reshape(1:12, 2, 3, 2)
```

We have multidimensional target margins (a 1D vector and a 2D matrix):
```@example ex
m1 = [48, 60]
m2 = [9 11 14; 19 25 30]
mar = [m1, m2]
```
Here, `m1` belongs to the first dimension of target matrix, and `m2` belongs to the third and second dimension (in that order). This can be encoded in a `DimIndices` object as follows:
```@example ex
dimid = DimIndices([1, [3, 2]])
```

Together, the margins and dimension indices they belong to constitute an `ArrayMargins` object:
```@example ex
m = ArrayMargins(mar, dimid)
```

Now we can run `ipf` to compute the adjustment:
```@example ex
fac = ipf(X, m)
```

And we can create the adjusted array `Z`:

```@example ex
Z = Array(fac) .* X
```

We then also use `ArrayMargins` to check whether the margins of this array are indeed as expected!
```@example ex
ArrayMargins(Z, dimid)
```
