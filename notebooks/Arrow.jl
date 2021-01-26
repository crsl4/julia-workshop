### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 146dfffc-5f58-11eb-3053-d31ada3a5428
using Arrow, DataFrames, PooledArrays, PyCall, RCall

# ╔═╡ 6d417df8-5f48-11eb-1afa-4f148f2f3121
md"""
# Arrow for data saving and transfer

The [Apache Arrow format](https://arrow.apache.org/) is a binary format for column-oriented tabular data.
It is supported by packages for several languages, including `R` and `Python`.

The Julia implementation, https://github.com/JuliaData/Arrow.jl, is unusual in that it is a native implementation and does not rely on the underlying C++ library used by other implementations.

In Julia Arrow is primarily used for saving and restoring data Tables and for exchanging data tables with `R` and `Python`.

### Reading an Arrow table written from Julia

Recall that in the `consistency.jl` notebook the manybabies data were written to files `02_validated_output.arrow` and `02_validated_output_compressed.arrow`
"""

# ╔═╡ 7340991a-5f5b-11eb-310f-594dcc07c68c
tbl = Arrow.Table("02_validated_output.arrow")

# ╔═╡ 9de89dfc-5f5b-11eb-3bf8-7325d9ceb526
describe(DataFrame(tbl))

# ╔═╡ 5c22c946-5f5c-11eb-2003-43080004e3a1
md"""
This is essentially the same table as was written.
The values are the same but the types are equivalent but different from the originals.
"""

# ╔═╡ bf5c2c78-5f5c-11eb-0e66-51750c12c3f0
typeof(tbl.subid)

# ╔═╡ d84387a4-5f5c-11eb-315a-0fcf3bcc650f
md"""
Reading from the compressed arrow file is similar but takes a bit longer because the file must be uncompressed when reading.
"""

# ╔═╡ 02a6cee8-5f5d-11eb-2b82-0305f32de39f
tbl2 = Arrow.Table("02_validated_output_compressed.arrow")

# ╔═╡ a0d348fc-5f59-11eb-1610-33cc30f74060
md"""
### Reading an Arrow table written with R

Suppose we wish to access the `palmerpenguins::penguins` data set from `R`.

We will use some functions from the `RCall` package without much explanation.
Suffice it to say that prepending a quoted string with `R` causes it to be evaluated in an R instance.
If the string contains quote characters it should be wrapped in triple quotes.
"""

# ╔═╡ 304dbd5c-5f58-11eb-3f93-d768a48487d5
R"library(arrow)";

# ╔═╡ 4dfc17e0-5f58-11eb-187a-17f3b589e22a
R"""write_feather(palmerpenguins::penguins, "penguins.arrow")"""

# ╔═╡ 7813ebb6-5f58-11eb-3d10-affbe5c1c60b
md"""
The [`palmerpenguins` package](https://allisonhorst.github.io/palmerpenguins/) contains this table.
The `arrow` package for R and the `pyarrow` Python package both refer to the arrow file format as `feather`.
Feather was an earlier file format and the arrow format is now considered version 2 of Feather.
This is just to explain why these packages use names like `write_feather`.

Now read this file as a table in Julia.
"""

# ╔═╡ 2c82a0c6-5f5a-11eb-0132-f7584460d831
penguins = DataFrame(Arrow.Table("penguins.arrow"))

# ╔═╡ 6e08e19a-5f5a-11eb-33aa-21a284ece05b
describe(penguins)

# ╔═╡ 022743a2-5f5e-11eb-0477-cf77576fdc77
md"""
Notice that all the columns allow for missing data, even when there are no missing values in the column.
This is always the case in `R`.

Also, the numeric types will always be `Int32` or `Float64` and most data tables will contain only these types plus `String`.


That is not a problem coming from R to Julia - at most it is an inconvenience.

To read this in Python we use the `pyarrow` package through the already loaded `PyCall` package for Julia
"""

# ╔═╡ 344e105a-6011-11eb-1247-c79e874ad0e6
feather = pyimport("pyarrow.feather");

# ╔═╡ 4c560c66-6011-11eb-23dd-e575a7449301
fr = feather.read_feather("penguins.arrow")

# ╔═╡ 75bb7640-6011-11eb-10f5-29b200a6eb39
typeof(fr)

# ╔═╡ 8e975c6a-6011-11eb-2843-d5991dabe7c1
feather.read_table("penguins.arrow")   # produces a pyarrow.Table

# ╔═╡ e934fc9a-6011-11eb-1f93-a37558c1d2a9
md"""
## Reading an Arrow file from Julia in R or Python

There is currently one hitch in reading an Arrow file from Julia in R or Python, related to the indices type in a dictionary-encoded column like `species` or `island` in the `penguins` data set.

These are `factor`s in R.
In Julia the corresponding types are `PooledArray` or `CategoricalArray`.
By default the type of the index is an unsigned integer which is a problem for R and
for Pandas, but not for a `pyarrow.Table`.
"""

# ╔═╡ ccd2caee-6013-11eb-3514-211c3a140eec
feather.read_table("02_validated_output.arrow")

# ╔═╡ Cell order:
# ╟─6d417df8-5f48-11eb-1afa-4f148f2f3121
# ╠═146dfffc-5f58-11eb-3053-d31ada3a5428
# ╠═7340991a-5f5b-11eb-310f-594dcc07c68c
# ╠═9de89dfc-5f5b-11eb-3bf8-7325d9ceb526
# ╟─5c22c946-5f5c-11eb-2003-43080004e3a1
# ╠═bf5c2c78-5f5c-11eb-0e66-51750c12c3f0
# ╟─d84387a4-5f5c-11eb-315a-0fcf3bcc650f
# ╠═02a6cee8-5f5d-11eb-2b82-0305f32de39f
# ╟─a0d348fc-5f59-11eb-1610-33cc30f74060
# ╠═304dbd5c-5f58-11eb-3f93-d768a48487d5
# ╠═4dfc17e0-5f58-11eb-187a-17f3b589e22a
# ╟─7813ebb6-5f58-11eb-3d10-affbe5c1c60b
# ╠═2c82a0c6-5f5a-11eb-0132-f7584460d831
# ╠═6e08e19a-5f5a-11eb-33aa-21a284ece05b
# ╟─022743a2-5f5e-11eb-0477-cf77576fdc77
# ╠═344e105a-6011-11eb-1247-c79e874ad0e6
# ╠═4c560c66-6011-11eb-23dd-e575a7449301
# ╠═75bb7640-6011-11eb-10f5-29b200a6eb39
# ╠═8e975c6a-6011-11eb-2843-d5991dabe7c1
# ╟─e934fc9a-6011-11eb-1f93-a37558c1d2a9
# ╠═ccd2caee-6013-11eb-3514-211c3a140eec
