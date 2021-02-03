### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 146dfffc-5f58-11eb-3053-d31ada3a5428
using Arrow, DataFrames, PyCall, RCall

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

# ╔═╡ c12b82c2-60ee-11eb-3b0a-81dbbc109227
md"""
The `Arrow.Table` function reads an arrow file and returns a columnar table, which can be converted to a `DataFrame` if desired.
An uncompressed arrow file is memory-mapped so reading even a very large arrow file is fast.
"""

# ╔═╡ 7340991a-5f5b-11eb-310f-594dcc07c68c
tbl = Arrow.Table("02_validated_output.arrow")

# ╔═╡ 9de89dfc-5f5b-11eb-3bf8-7325d9ceb526
begin
	df = DataFrame(tbl)
	describe(df)
end

# ╔═╡ 5c22c946-5f5c-11eb-2003-43080004e3a1
md"""
This is essentially the same table as was written.
The values in the columns are the same as in the original table.
The column types are sometimes different from but equivalent to the original columns.
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
(note that if you install `pyarrow` using `conda` it is important to specify `-c conda-forge` - otherwise you will get a badly out-of-date version).
"""

# ╔═╡ 344e105a-6011-11eb-1247-c79e874ad0e6
feather = pyimport("pyarrow.feather");

# ╔═╡ 4c560c66-6011-11eb-23dd-e575a7449301
fr = feather.read_feather("penguins.arrow")

# ╔═╡ 1d57f6b8-60f4-11eb-3b0d-3f0a7cca045f
md"""
A more basic method, `feather.read_table`, produces a `pyarrow.Table`.
In fact, `read_feather` simply calls `read_table` then converts the result to a pandas dataframe.
Occasionally there are problems in the conversion so it is good to know about `read_table`.
"""

# ╔═╡ 8e975c6a-6011-11eb-2843-d5991dabe7c1
feather.read_table("penguins.arrow")   # produces a pyarrow.Table

# ╔═╡ e934fc9a-6011-11eb-1f93-a37558c1d2a9
md"""
## Reading an Arrow file from Julia in R or Python

Recent additions to the `arrow` package for R and the `pyarrow` package for Python have greatly expanded the flexibility of these packages.
"""

# ╔═╡ 487d7b38-60f5-11eb-0162-6391d5b99b89
R"library(tibble)";

# ╔═╡ 540279a6-60f5-11eb-39b7-ff25a8dad69e
R"""valid <- read_feather("02_validated_output.arrow"); glimpse(valid)"""

# ╔═╡ 9f6a025e-60f5-11eb-2e89-052cce54dcd1
md"""
It is not obvious but there are some conversions necessary to read a general arrow file and create an R `data.frame` or `tibble`.

To see the form as stored in the arrow file it is convenient to use Python's `pyarrow.Table`.
"""

# ╔═╡ ccd2caee-6013-11eb-3514-211c3a140eec
feather.read_table("02_validated_output.arrow")

# ╔═╡ bf9a6a60-60f6-11eb-1d60-5d2749b801c8
md"""
Several columns, such as `trial_num` and `stimulus_num` are returned as the default integer type, `Int64`, from `CSV.File` and these need to be converted to `Int32` in R.
"""

# ╔═╡ 165e118a-60f7-11eb-2ee4-5fc34fdb0413
R"class(valid$trial_num)"

# ╔═╡ 2eec5644-60f7-11eb-2b0e-e91b3a5d397e
R"""write_feather(valid, "02_validated_from_R.arrow")""";

# ╔═╡ 5c0fed50-60f7-11eb-3840-b7bb6567c414
feather.read_table("02_validated_from_R.arrow")

# ╔═╡ 0345cd9c-625b-11eb-08a4-2f0eb3598a02
md"""
Note that there are two changes in some columns: those that were `int64` are now `int32` and there are no columns marked `not null`.
That is, all columns now allow for missing data.

In Julia we can check with
"""

# ╔═╡ 6c29d874-60f7-11eb-2f28-7b024614b47f
Tables.schema(Arrow.Table("02_validated_from_R.arrow"))

# ╔═╡ 326357e0-60f8-11eb-1243-a11b01c54c93
md"""
## Conversion from Int64 vectors to smaller integer types

The `Int64` or `Union{Missing,Int64}` columns in the table, `tbl`, are coded as such because the default integer type, `Int`, is equivalent to `Int64` on a 64-bit implementation of Julia.

It is possible to specify the types of the columns in the call to `CSV.File` when reading the original CSV file but doing so requires knowing the contents of the columns before reading the file.  It is usually easier to read the file with the inferred types then change later.

First, check which columns have element types of `Int64` or `Union{Missing,Int64}`.
For this it helps to use `nonmissingtype` to produce the underlying type from a column that allows for missing data.
"""

# ╔═╡ 8ce3d320-6198-11eb-0c8b-9f89171ca4eb
let et = eltype(df.trial_num)
	et, nonmissingtype(et)
end

# ╔═╡ a612a74a-6198-11eb-03e2-61dc1f6b2d91
let et = eltype(df.stimulus_num)
	et, nonmissingtype(et)
end

# ╔═╡ cde9956c-6198-11eb-3ecf-d5b20a829eb7
md"""
Now we want to examine all the columns to find those whose nonmissing eltype is `Int64`.

For a dataframe `df` the `eachcol` function returns an iterator over the columns.  Wrapping this in `pairs` produces an iterator of `name, value` pairs which we can use to discover which columns are coded as `Int64`, with or without missing values.
"""

# ╔═╡ c640e170-6199-11eb-2b53-59932c869eeb
begin
	intcols = Symbol[]
	for (n,v) in pairs(eachcol(df))
		Int64 == nonmissingtype(eltype(v)) && push!(intcols, n)
	end
	intcols
end

# ╔═╡ 4f0d6f46-619a-11eb-3885-3b274bf30cd0
md"""
For each of these columns we determine the extrema (minimum and maximum), using `skipmissing` to avoid the missing values, then compare against the `typemin` and `typemax` for various integer types to determine the smallest type of integer that can encode the data.
"""

# ╔═╡ fce28458-619a-11eb-2a0d-a90f00f1d7b8
function inttype(x)
	mn, mx = extrema(skipmissing(x))
	if typemin(Int8) ≤ mn ≤ mx ≤ typemax(Int8)
		Int8
	elseif typemin(Int16) ≤ mn ≤ mx ≤ typemax(Int16)
		Int16
	elseif typemin(Int32) ≤ mn ≤ mx ≤ typemax(Int32)
		Int32
	else
		Int64
	end
end

# ╔═╡ bc14c3c6-61ba-11eb-0713-8b0102504a75
conv = map(sym -> Pair(sym, inttype(getproperty(df, sym))), intcols)

# ╔═╡ 2f15c8a6-61bc-11eb-33b5-dbbec9adc3e6
for pr in conv
	setproperty!(df, first(pr), passmissing(last(pr)).(getproperty(df, first(pr))))
end

# ╔═╡ 09d16a40-61bd-11eb-0a01-116e5ef1e1c4
Tables.schema(df)

# ╔═╡ 436a2e7c-61bd-11eb-1fbf-1f3dc862f710
md"""
Finally we write a new Arrow file.
"""

# ╔═╡ 9200d74a-625b-11eb-3a39-21b57ab3fc4b
Arrow.write("02_compact.arrow", df, compress=:zstd);

# ╔═╡ be25db36-625b-11eb-2033-cb284fffd5b8
filesize("02_compact.arrow")

# ╔═╡ 03108a5c-625c-11eb-1add-2ff36f5d4bdb
feather.read_table("02_compact.arrow")

# ╔═╡ Cell order:
# ╟─6d417df8-5f48-11eb-1afa-4f148f2f3121
# ╠═146dfffc-5f58-11eb-3053-d31ada3a5428
# ╟─c12b82c2-60ee-11eb-3b0a-81dbbc109227
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
# ╟─1d57f6b8-60f4-11eb-3b0d-3f0a7cca045f
# ╠═8e975c6a-6011-11eb-2843-d5991dabe7c1
# ╟─e934fc9a-6011-11eb-1f93-a37558c1d2a9
# ╠═487d7b38-60f5-11eb-0162-6391d5b99b89
# ╠═540279a6-60f5-11eb-39b7-ff25a8dad69e
# ╟─9f6a025e-60f5-11eb-2e89-052cce54dcd1
# ╠═ccd2caee-6013-11eb-3514-211c3a140eec
# ╟─bf9a6a60-60f6-11eb-1d60-5d2749b801c8
# ╠═165e118a-60f7-11eb-2ee4-5fc34fdb0413
# ╠═2eec5644-60f7-11eb-2b0e-e91b3a5d397e
# ╠═5c0fed50-60f7-11eb-3840-b7bb6567c414
# ╟─0345cd9c-625b-11eb-08a4-2f0eb3598a02
# ╠═6c29d874-60f7-11eb-2f28-7b024614b47f
# ╟─326357e0-60f8-11eb-1243-a11b01c54c93
# ╠═8ce3d320-6198-11eb-0c8b-9f89171ca4eb
# ╠═a612a74a-6198-11eb-03e2-61dc1f6b2d91
# ╟─cde9956c-6198-11eb-3ecf-d5b20a829eb7
# ╠═c640e170-6199-11eb-2b53-59932c869eeb
# ╟─4f0d6f46-619a-11eb-3885-3b274bf30cd0
# ╠═fce28458-619a-11eb-2a0d-a90f00f1d7b8
# ╠═bc14c3c6-61ba-11eb-0713-8b0102504a75
# ╠═2f15c8a6-61bc-11eb-33b5-dbbec9adc3e6
# ╠═09d16a40-61bd-11eb-0a01-116e5ef1e1c4
# ╟─436a2e7c-61bd-11eb-1fbf-1f3dc862f710
# ╠═9200d74a-625b-11eb-3a39-21b57ab3fc4b
# ╠═be25db36-625b-11eb-2033-cb284fffd5b8
# ╠═03108a5c-625c-11eb-1add-2ff36f5d4bdb
