### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ b6604064-5b4c-11eb-3c85-2dd14f1ebfe9
using Arrow, CSV, DataFrames, Tables

# ╔═╡ 99320640-5b50-11eb-3188-01c0bac978d0
md" # Data checking: consistency"

# ╔═╡ c9964454-5b50-11eb-035d-d3b8e639595b
md"""
A common task in data cleaning or data checking is to establish consistency in columns of values that should be a property of another column of keys.
Suppose, for example, that a longitudinal data set collected on several `subject`s over time also contains a column for the subject's `gender`.
We should check that the gender is recorded consistently for each subject.
(Inconsistently recorded gender may be a choice by a non-binary person but most of the time it is a data error.)

We will use data from the [ManyBabies study](https://github.com/manybabies/mb1-analysis-public/) to illustrate such checks.
This is a valuable data set because the investigators in the study documented the original data and the steps in cleaning it.

First load the packages to be used.
"""

# ╔═╡ e2c7a600-5b52-11eb-0643-5f38bc118074
md"""
The data table we will consider is `processed_data/02_validated_output.csv`.
It can be read directly from github (after `using HTTP`) with
```julia
f = CSV.File(
    HTTP.get("https://github.com/manybabies/mb1-analysis-public/raw/master/processed_data/02_validated_output.csv").body,
    missingstrings = ["NA"],
	truestrings = ["TRUE"],
	falsestrings = ["FALSE"],
)
```
or by downloading the single file (or cloning the repository) then reading the local copy.
"""

# ╔═╡ 22b6d620-5bfb-11eb-2ecb-a10ffeff34fe
datanm = download(
	"https://github.com/manybabies/mb1-analysis-public/raw/master/processed_data/02_validated_output.csv");

# ╔═╡ 05b257c4-5b4d-11eb-00a1-d919079b2d9c
f = CSV.File(datanm, missingstrings = ["NA"],
	truestrings = ["TRUE"],	falsestrings = ["FALSE"])

# ╔═╡ e456acf6-5bfb-11eb-3d7c-57cfd802112e
md"""
An advantage of downloading (or cloning) and reading the local version is that `CSV.File` defaults to using memory-mapping on a local file (using the direct HTTP response body or local file will both use multiple threads to parse if the amount of data is large enough).
"""

# ╔═╡ e43d5458-5b4d-11eb-1952-c5026070a8b1
md"""
## Data Tables

The packages developed by the [JuliaData group](https://github.com/JuliaData/) provide both column-oriented tables, similar to `data.frame` or `tibble` in `R` or `pandas` data frame in `Python`, or row-oriented tables, such as returned from queries to relational database systems.
The [Tables package](https://github.com/JuliaData/Tables.jl) provides the glue between the two representations.

The value returned by `CSV.File` iterates efficient row "views", but stores the data internally in columns.
"""

# ╔═╡ 84a6ada2-5b55-11eb-3136-31be42dd14d2
length(f)

# ╔═╡ e351312e-5b55-11eb-1a2f-21914aada254
schem = Tables.schema(f)

# ╔═╡ baa8cca0-5b55-11eb-1477-25f701ef5db8
md"""
`f` can be converted to a generic column-oriented table with `Tables.columntable`
"""

# ╔═╡ 0c34e306-5b56-11eb-10e8-e77ffcd18908
ct = Tables.columntable(f)

# ╔═╡ 17b3d412-5b56-11eb-0e28-4393d871a854
typeof(ct)

# ╔═╡ 4dfdbe66-5b56-11eb-1a90-4124a0ea18db
md"""
which is a `NamedTuple`, somewhat like a `list` in `R`.
This is an immutable structure in the sense that the names and the locations of the vectors representing the columns cannot be changed.
The values in the vectors can be modified but the structure can't.

A `DataFrame`, provided by the [DataFrames package](https://github.com/JuliaData/DataFrames.jl), is mutable.  The package provides facilities comparable to the tidyverse or pandas.
For example, we use a GroupedDataFrame below to access rows containing a specific `subid`.
"""

# ╔═╡ 587f917e-5b57-11eb-2832-77060bd93856
begin
	df = DataFrame(ct)
	describe(df)
end

# ╔═╡ 40f1f718-5b59-11eb-1532-49a84da41cd4
md"""
## Checking for inconsistent values

The general approach in pandas or tidyverse is to manipulate columns.
In Julia we can choose either row-oriented or column-oriented because the `Tables` interface incorporates both.

One assumption about these data was that the `subid` was unique to each baby.
It turns out that was not the case, which is why the `subid_unique` was created.
Different `lab`s used the same `subid` forms.

To check for unique values in a `value` column according to a `key` column we can iterate over the vectors and store the first value associated with each key in a dictionary.
For each row if a value is stored and it is different from the current value the key is included in the set of inconsistent keys.
(A `Set` is used rather than a `Vector` to avoid recording the same key multiple times.)

A method defined for two vectors could be
"""

# ╔═╡ 1f3e253c-5b5d-11eb-2f15-a3770783880a
function inconsistent(keycol, valuecol)
	dict = Dict{eltype(keycol), eltype(valuecol)}()
	set = Set{eltype(keycol)}()
	for (k,v) in zip(keycol, valuecol)
		if haskey(dict, k) && dict[k] ≠ v
			push!(set, k)
		else
			dict[k] = v
		end
	end
	set
end

# ╔═╡ de58d4e4-5b5d-11eb-0535-cfff56b55c84
md"""
A row-oriented approach would simply iterate over the rows
"""

# ╔═╡ c343d12e-5b79-11eb-14e5-91cb42dc933a
begin
	dict = Dict()
	set = Set()
	for r in Tables.rows(f)
		get!(dict, r.subid, r.lab) ≠ r.lab && push!(set, r.subid)
	end
	set
end

# ╔═╡ 26dfb6a8-5b7a-11eb-01d3-9bbd9a4bec20
md"""
This code chunk uses the `get!` method for a `Dict`, which combines the effect of `haskey`, `setindex` and `getindex`, and the short-circuiting boolean AND, `&&`.

The same effect can be achieved by the "lazy" evaluator `Tables.columns` which creates the effect of having columns as vectors.
"""

# ╔═╡ d0ae8ba4-5b5d-11eb-1759-91cfc28cec09
function inconsistent(tbl, keysym::Symbol, valuesym::Symbol)
	ctbl = Tables.columns(tbl)
	inconsistent(getproperty(ctbl, keysym), getproperty(ctbl, valuesym))
end

# ╔═╡ 13c305b4-5b63-11eb-0165-771fdeccd4d9
md"""
Finally we can go back and rewrite a more specific method for vectors using templated types.
"""

# ╔═╡ 044bc45a-5b76-11eb-2588-011429fe6ae0
function inconsistent(kvec::AbstractVector{T}, vvec::AbstractVector{S}) where {T,S}
	dict = Dict{T,S}()
	set = Set{T}()
	for (k, v) in zip(kvec, vvec)
		get!(dict, k, v) ≠ v && push!(set, k)
	end
	set
end

# ╔═╡ b284b09a-5b5d-11eb-1d13-a78d6efd2d07
dupids = inconsistent(ct.subid, ct.lab)

# ╔═╡ 7e2117ee-5b62-11eb-3f61-51e68aafac47
inconsistent(f, :subid, :lab)

# ╔═╡ 83e955b0-5b76-11eb-3cea-55e06e37c969
inconsistent(df.subid, df.lab)

# ╔═╡ 925b0794-5f39-11eb-2996-af80f33aa04d
md"""
Unfortunately, we are not quite finished.
As frequently happens in data science, missing data values will complicate things.

For example, some of the values in the `preterm` column are missing.
"""

# ╔═╡ 2bd13fe2-5f3a-11eb-221b-f3d58671d556
unique(f.preterm)

# ╔═╡ 40d7ca8c-5f3a-11eb-175c-7fbf9a5e6ed5
md"""
and if we try to check for consistency these values cause an error
"""

# ╔═╡ 5b8de570-5f3a-11eb-0af1-4d8cc6f3397b
inconsistent(f, :subid, :preterm)

# ╔═╡ 2a0db414-5f3b-11eb-2e28-899ac5f269c9
md"""
The problem stems from comparison with values that may be missing.
Most comparisons will, necessarily, return missing.
The only function guaranteed to return a logical value for an argument of `missing` is `ismissing`.

We could add code to check for missing values and take appropriate action but another approach shown below allows us to side-step this problem.
"""

# ╔═╡ f546b60c-5e65-11eb-3dd1-b30eea37b650
md"""
## Using DataFrames to check consistency

If I were just checking for consistency in R I would `select` the key and value columns, find the `unique` rows and check the number of rows against the number of keys.  The same approach could be used with the `DataFrames` package.
"""

# ╔═╡ 75260774-5e66-11eb-34f9-75b1451696aa
nrow(unique(select(df, [:lab, :subid])))

# ╔═╡ 9706d85c-5e66-11eb-138a-7f7bd5023d75
select(df, [:lab, :subid]) |> unique |> nrow # if you feel you must use pipes

# ╔═╡ c1a21ae8-5e66-11eb-38fb-95048e6549a3
length(unique(df.subid))

# ╔═╡ 0aa0a6ce-5e67-11eb-2c2b-c36fe6623e54
md"""
This brings up a couple of "variations on a theme" for the Julia version.  Suppose we just wanted to check if the values are consistent with the keys.  Then we can short-circuit the loop.
"""

# ╔═╡ 35cdc246-5e67-11eb-002d-b39084a7dbd8
function isconsistent(kvec::AbstractVector{T}, vvec::AbstractVector{S}) where {T,S}
	dict = Dict{T,S}()
	for (k, v) in zip(kvec, vvec)
		get!(dict, k, v) ≠ v && return false
	end
	true
end

# ╔═╡ 93b3feca-5e67-11eb-174b-71b130678bf7
isconsistent(ct.subid, ct.lab)

# ╔═╡ b409e5b8-5e67-11eb-299f-77d93e36f9ee
md"""
Alternatively, suppose we wanted to find all the `lab`s that used a particular `subid`.
"""

# ╔═╡ f1239c82-5e67-11eb-34ff-79960f238b48
function allvals(kvec::AbstractVector{T}, vvec::AbstractVector{S}) where {T,S}
	dict = Dict{T,Set{S}}()
	for (k, v) in zip(kvec, vvec)
		push!(get!(dict, k, Set{S}()), v)
	end
	dict
end

# ╔═╡ 4a6a81fc-5e68-11eb-0f22-cd64244b7d52
setslab = allvals(ct.subid, ct.lab)

# ╔═╡ dc08ce42-5f3b-11eb-0719-3901bf18657b
md"""
This allows us to get around the problem of missing values in the `preterm` column.
"""

# ╔═╡ 3e5da9b4-5f3c-11eb-1656-c3c52ae3afdb
setspreterm = allvals(f.subid_unique, f.preterm)

# ╔═╡ 62732da8-5e68-11eb-351d-b90c1fb85326
repeatedlab = filter(pr -> length(last(pr)) > 1, setslab)

# ╔═╡ f7d0a374-5f3c-11eb-2bc1-559f3f0e57d3
md"""
The construction using `->` creates an anonymous function.
The argument to this function will be a `(key, value)` pair and `last(pr)` extracts the value, a `Set{String}` in this case.
"""

# ╔═╡ 07eb03d2-5e69-11eb-1cb6-3b0b70a63dfe
length(repeatedlab)

# ╔═╡ 144a0e34-5e69-11eb-2131-7958d811f9ac
sort(collect(keys(repeatedlab)))  # subid values that are repeated in different labs

# ╔═╡ bd740f16-5f3c-11eb-18c6-df7593e7068b
md"""
`preterm`, on the other hand, is coded consistently for each `subid_unique`.
"""

# ╔═╡ 7fd94baa-5f3c-11eb-23a6-59e20f7249a6
repeatedpreterm = filter(pr -> length(last(pr)) > 1, setspreterm)

# ╔═╡ b2f82b88-5b76-11eb-00b4-ab003fe595d3
md"""
## Extracting the inconsistent cases

The `DataFrames` package provides a `groupby` function to create a `GroupedDataFrame`.
Generally it is use in a split-apply-combine strategy but it can be used to extract subsets of rows according to the values in one or more columns.
It is effective if the operation is to be repeated for different values, such as here.
"""

# ╔═╡ 2b9449d0-5b77-11eb-247a-2d3c5cafa748
begin
	gdf = groupby(df, :subid)
	typeof(gdf)
end

# ╔═╡ 53a6ed6c-5b77-11eb-1aa0-19b998da8fa9
g1 = gdf[(subid = "1",)]

# ╔═╡ 673ad4a2-5b7b-11eb-2970-17c8a16b9db2
unique(g1.lab)

# ╔═╡ ad5f6b34-5bfd-11eb-3b66-f1eff84d942e
md"""
## Summary

The point of this example is not that one should expect to custom program each step in a data cleaning operation.
The facilities in the `DataFrames` package could be used in a tidyverse-like approach.

However, if the particular tool for a task is not available or, more likely, you don't know offhand where it is and what it is called, there are low-level tools easily available.
And using the low-level tools inside of loops doesn't impede performance.

As a last action in this notebook, we will save the table as an `Arrow` file that will be used in the next notebook.

Arrow files can be written with or without compression.
As may be expected, the file size of the compressed version is smaller but it takes longer to read it because it must be uncompressed.
"""

# ╔═╡ 031fd26c-5f3e-11eb-0ac0-4b1110d55d8f
Arrow.write("02_validated_output.arrow", f)

# ╔═╡ 890e0a2a-5f3d-11eb-3c67-b985257837ec
filesize("02_validated_output.arrow")

# ╔═╡ 51cad7ea-5f3e-11eb-323e-8ba75781305f
Arrow.write("02_validated_output_compressed.arrow", f, compress = :zstd)

# ╔═╡ 6a3e8e70-5f3e-11eb-1131-c59353b87d1b
filesize("02_validated_output_compressed.arrow")

# ╔═╡ Cell order:
# ╟─99320640-5b50-11eb-3188-01c0bac978d0
# ╟─c9964454-5b50-11eb-035d-d3b8e639595b
# ╠═b6604064-5b4c-11eb-3c85-2dd14f1ebfe9
# ╟─e2c7a600-5b52-11eb-0643-5f38bc118074
# ╠═22b6d620-5bfb-11eb-2ecb-a10ffeff34fe
# ╠═05b257c4-5b4d-11eb-00a1-d919079b2d9c
# ╟─e456acf6-5bfb-11eb-3d7c-57cfd802112e
# ╟─e43d5458-5b4d-11eb-1952-c5026070a8b1
# ╠═84a6ada2-5b55-11eb-3136-31be42dd14d2
# ╠═e351312e-5b55-11eb-1a2f-21914aada254
# ╟─baa8cca0-5b55-11eb-1477-25f701ef5db8
# ╠═0c34e306-5b56-11eb-10e8-e77ffcd18908
# ╠═17b3d412-5b56-11eb-0e28-4393d871a854
# ╟─4dfdbe66-5b56-11eb-1a90-4124a0ea18db
# ╠═587f917e-5b57-11eb-2832-77060bd93856
# ╟─40f1f718-5b59-11eb-1532-49a84da41cd4
# ╠═1f3e253c-5b5d-11eb-2f15-a3770783880a
# ╠═b284b09a-5b5d-11eb-1d13-a78d6efd2d07
# ╟─de58d4e4-5b5d-11eb-0535-cfff56b55c84
# ╠═c343d12e-5b79-11eb-14e5-91cb42dc933a
# ╟─26dfb6a8-5b7a-11eb-01d3-9bbd9a4bec20
# ╠═d0ae8ba4-5b5d-11eb-1759-91cfc28cec09
# ╠═7e2117ee-5b62-11eb-3f61-51e68aafac47
# ╟─13c305b4-5b63-11eb-0165-771fdeccd4d9
# ╠═044bc45a-5b76-11eb-2588-011429fe6ae0
# ╠═83e955b0-5b76-11eb-3cea-55e06e37c969
# ╟─925b0794-5f39-11eb-2996-af80f33aa04d
# ╠═2bd13fe2-5f3a-11eb-221b-f3d58671d556
# ╟─40d7ca8c-5f3a-11eb-175c-7fbf9a5e6ed5
# ╠═5b8de570-5f3a-11eb-0af1-4d8cc6f3397b
# ╟─2a0db414-5f3b-11eb-2e28-899ac5f269c9
# ╟─f546b60c-5e65-11eb-3dd1-b30eea37b650
# ╠═75260774-5e66-11eb-34f9-75b1451696aa
# ╠═9706d85c-5e66-11eb-138a-7f7bd5023d75
# ╠═c1a21ae8-5e66-11eb-38fb-95048e6549a3
# ╟─0aa0a6ce-5e67-11eb-2c2b-c36fe6623e54
# ╠═35cdc246-5e67-11eb-002d-b39084a7dbd8
# ╠═93b3feca-5e67-11eb-174b-71b130678bf7
# ╟─b409e5b8-5e67-11eb-299f-77d93e36f9ee
# ╠═f1239c82-5e67-11eb-34ff-79960f238b48
# ╠═4a6a81fc-5e68-11eb-0f22-cd64244b7d52
# ╟─dc08ce42-5f3b-11eb-0719-3901bf18657b
# ╠═3e5da9b4-5f3c-11eb-1656-c3c52ae3afdb
# ╠═62732da8-5e68-11eb-351d-b90c1fb85326
# ╟─f7d0a374-5f3c-11eb-2bc1-559f3f0e57d3
# ╠═07eb03d2-5e69-11eb-1cb6-3b0b70a63dfe
# ╠═144a0e34-5e69-11eb-2131-7958d811f9ac
# ╟─bd740f16-5f3c-11eb-18c6-df7593e7068b
# ╠═7fd94baa-5f3c-11eb-23a6-59e20f7249a6
# ╟─b2f82b88-5b76-11eb-00b4-ab003fe595d3
# ╠═2b9449d0-5b77-11eb-247a-2d3c5cafa748
# ╠═53a6ed6c-5b77-11eb-1aa0-19b998da8fa9
# ╠═673ad4a2-5b7b-11eb-2970-17c8a16b9db2
# ╟─ad5f6b34-5bfd-11eb-3b66-f1eff84d942e
# ╠═031fd26c-5f3e-11eb-0ac0-4b1110d55d8f
# ╠═890e0a2a-5f3d-11eb-3c67-b985257837ec
# ╠═51cad7ea-5f3e-11eb-323e-8ba75781305f
# ╠═6a3e8e70-5f3e-11eb-1131-c59353b87d1b
