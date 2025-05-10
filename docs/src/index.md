# ProportionalFitting

Multidimensional iterative proportional fitting in Julia. 

[ProportionalFitting](https://github.com/vankesteren/ProportionalFitting.jl) implements a multidimensional version of the [factor estimation method](https://en.wikipedia.org/wiki/Iterative_proportional_fitting#Algorithm_2_(factor_estimation)) for performing iterative proportional fitting (also called RAS algorithm, raking, matrix scaling). 

In the two-dimensional case, iterative proportional fitting means changing a matrix $X$ to have marginal sum totals $u, v$. One prime use is in survey data analysis, where $X$ could be your data's cross-tabulation of demographic characteristics, and $u, v$ the known population proportions of those characteristics.

## Getting started
```@setup ex
using ProportionalFitting
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

Then the `ipf` function from ProportionalFitting will find the array factors which adjust matrix `X` to have the margins `u` and `v`:
```@example ex
fac = ipf(X, [u, v])
```

Array factors (`ArrayFactors`) are a specific type exported by ProportionalFitting with a few methods, for example `Array()`:

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

## Inconsistent margins
If the margins are inconsistent (i.e., the margins do not sum to the same amounts) then both `X` and the margins will be transformed to proportions.
```@example ex
m = ArrayMargins([[12, 23, 14, 35], [17, 44, 12, 33]])
af = ipf(X, m)
```

Then, `Z` needs to be computed in a different way as well:
```@example ex
X_prop = X ./ sum(X)
Z = X_prop .* Array(af)
```

## Multidimensional arrays

ProportionalFitting can also deal with multidimensional arrays of arbitrary shape. For example, consider the following `(3, 2, 3)` array and target margins:
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

ProportionalFitting can also deal with multidimensional margins of arbitrary shape. For example, consider the same `(3, 2, 3)` array as before:
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

## Repeated margins

With multidimensional margins, it is also possible to enter a single margin multiple times in different target margins. This is allowed as long as the margin totals match, and as long as no two target margins are about the exact same dimensions. For example:

```@example ex
# Create a 2×3×4 array with seed value 1
initial_array = ones(2, 3, 4)

# Specify target margins for dimensions 1 and 3
tgt_13 = [
    10.0 15.0 20.0 25.0;
    30.0 35.0 40.0 45.0
]

# Specify target margins for dimensions 2 and 3
tgt_23 = [
    12.0 16.0 20.0 24.0;
    18.0 22.0 26.0 30.0;
    10.0 12.0 14.0 16.0
]

# dimension 3 occurs twice!
target_dims = [[1, 3], [2, 3]]
target_margins = [tgt_13, tgt_23]

# at this point, the margins are checked for consistency
AM = ArrayMargins(target_margins, target_dims)

# We can run ipf with these duplicated margins
AF = ipf(initial_array, AM)

# check that the margins are as specified
ArrayMargins(Array(AF), target_dims)
```