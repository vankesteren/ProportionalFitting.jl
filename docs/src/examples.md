# Examples

## Regression poststratification

```@example
# Weight calibration of linear regression estimates
using StatsKit, FreqTables, ItPropFit

# Generate some data
N = 100
p_sex = Categorical([0.49, 0.51])
p_edu = Categorical([0.1, 0.3, 0.4, 0.2])
p_age = Categorical([0.1, 0.3, 0.3, 0.2, 0.1])
p_inc = LogNormal(5, 3)
p_opn = Normal(0, 3)
df = DataFrame(
    :sex => CategoricalArray(["m", "f"][rand(p_sex, N)]),
    :edu => CategoricalArray(["no", "lo", "med", "hi"][rand(p_edu, N)], ordered = true),
    :age => CategoricalArray(["<10", "11<25", "26<50", "51<70", ">70"][rand(p_age, N)], ordered = true),
    :inc => rand(p_inc, N)
)
df.opn = df.inc .* .1 + rand(p_opn, N)

# Create a cross-table of background characteristics
tab = freqtable(df, :sex, :edu, :age)

# Create margins from the population (aggregates obtained from statistical agency)
pop_margins = [[0.49, 0.51], [0.05, 0.2, 0.5, 0.25], [0.1, 0.2, 0.4, 0.15, 0.15]]

# Compute array factors
fac = ipf(Array(tab), pop_margins)

# Compute adjusted table
# NB: as population margins sum to 1, the table is already normalized!
tab_adj = Array(fac) .* tab

# Create a poststratification weight variable
df.w = [tab_adj[row...] for row in eachrow(df[:, [:sex, :edu, :age]])]
df.w = df.w ./ sum(df.w) .* N

# perform weighted regression
frm = @formula(opn ~ inc)
res_w = lm(frm, df, wts = df.w)
```