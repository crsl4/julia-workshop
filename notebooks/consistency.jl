### A Pluto.jl notebook ###
# v0.19.0

using Markdown
using InteractiveUtils

# ╔═╡ ff373d15-7311-4653-99c6-cf1c584796d7
using Arrow, CSV, DataFrames, HTTP, Tables

# ╔═╡ ec89f332-bb8c-439f-b5f0-202a23308e12
md"""
# Data checking: consistency

A common task in data cleaning or data checking is to establish consistency in columns of values that should be a property of another column of keys.
Suppose, for example, that a longitudinal data set collected on several `subject`s over time also contains a column for the subject's `gender`.
We should check that the gender is recorded consistently for each subject.
(Inconsistently recorded gender may be a choice by a non-binary person but most of the time it is a data error.)

We will use data from the [ManyBabies study](https://github.com/manybabies/mb1-analysis-public/) to illustrate such checks.
This is a valuable data set because the investigators in the study documented the original data and the steps in cleaning it.

First load the packages to be used.
"""

# ╔═╡ 51a8706e-9118-4ef4-9556-278aca0dffd7
md"""
The data table we will consider is `processed_data/02_validated_output.csv`.
It can be read directly from github (after `using HTTP`) with
"""

# ╔═╡ 467715fe-8950-4a0a-8ab4-5a752c1dc5c7
f = CSV.File(
    HTTP.get("https://github.com/manybabies/mb1-analysis-public/raw/master/processed_data/02_validated_output.csv").body,
    missingstring = ["NA"],
	truestrings = ["TRUE"],
	falsestrings = ["FALSE"],
);

# ╔═╡ af6a751a-fbda-460c-b720-cc9442419927
md"""
## Data Tables

The packages developed by the [JuliaData group](https://github.com/JuliaData/) provide both column-oriented tables, similar to `data.frame` or `tibble` in `R` or `pandas` data frame in `Python`, or row-oriented tables, such as returned from queries to relational database systems.
The [Tables package](https://github.com/JuliaData/Tables.jl) provides the glue between the two representations.

The value returned by `CSV.File` iterates efficient row "views", but stores the data internally in columns.
"""

# ╔═╡ 32c7f89a-3a23-4695-a5b4-ecded311d9c1
length(f)

# ╔═╡ 31e273e9-e831-4ddb-b989-efd6f543d517
schem = Tables.schema(f)

# ╔═╡ 50cf00c6-ddbc-48fb-af89-0c784c053335
md"""
`f` can be converted to a generic column-oriented table with `Tables.columntable`
"""

# ╔═╡ 99750cc9-8e86-49d2-9de1-7aab69d28c71
ct = Tables.columntable(f)

# ╔═╡ 432bd0f2-81e9-4f31-ba1f-0c90e77672e7
typeof(ct)

# ╔═╡ c30a26dc-c0f9-426a-8914-c0b2eb663025
md"""
which is a `NamedTuple`, somewhat like a `list` in `R`.
This is an immutable structure in the sense that the names and the locations of the vectors representing the columns cannot be changed.
The values in the vectors can be modified but the structure can't.

A `DataFrame`, provided by the [DataFrames package](https://github.com/JuliaData/DataFrames.jl), is mutable.  The package provides facilities comparable to the tidyverse or pandas.
For example, we use a GroupedDataFrame below to access rows containing a specific `subid`.
"""

# ╔═╡ 33d30241-45a0-4d8e-90b3-6436a6b65420
begin
	df = DataFrame(ct)
	describe(df)
end

# ╔═╡ d8fca1cd-b43b-45a4-91e6-d49b291ff0e2
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

# ╔═╡ e3381cf3-5b2b-4f8b-be21-2459d4181975
begin
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
	inconsistent(df.subid, df.lab)
end

# ╔═╡ 46bf3f16-16d0-433e-b5ba-d3e743712b05
md"""
A row-oriented approach would simply iterate over the rows
"""

# ╔═╡ e7dcd9d0-4bd3-4953-950c-68bdec4eef67
let dict = Dict()
	set = Set()
	for r in Tables.rows(f)
		get!(dict, r.subid, r.lab) ≠ r.lab && push!(set, r.subid)
	end
	set
end

# ╔═╡ 9b0c9a59-008e-4bcb-92f0-b47f5d41b4b6
md"""
Note that the returned value is a `Set{Any}` as we did not specify an element type in the constructor.

This code chunk uses the `get!` method for a `Dict`, which combines the effect of `haskey`, `setindex` and `getindex`. It also uses the short-circuiting boolean AND, `&&`.

The same effect can be achieved by the "lazy" evaluator `Tables.columns` which creates the effect of having columns as vectors.
"""

# ╔═╡ 8e163074-59ae-4bd9-8d23-83af3115ecdd
begin
	function inconsistent(tbl, keysym::Symbol, valuesym::Symbol)
		ctbl = Tables.columns(tbl)
		inconsistent(getproperty(ctbl, keysym), getproperty(ctbl, valuesym))
	end
	inconsistent(f, :subid, :lab)
end

# ╔═╡ 8938b29d-ac9e-48f4-9387-b8eef12ed2e4
md"""
Finally we can go back and rewrite a more specific method for vectors using templated types.
"""

# ╔═╡ 54c081e6-677b-4ece-835a-670a0bf9456a
dupids = begin
	function inconsistent(kvec::AbstractVector{T}, vvec::AbstractVector{S}) where {T,S}
		dict = Dict{T,S}()
		set = Set{T}()
		for (k, v) in zip(kvec, vvec)
			get!(dict, k, v) ≠ v && push!(set, k)
		end
		set
	end
	inconsistent(ct.subid, ct.lab)
end

# ╔═╡ 72b2f435-6b39-4414-8c9c-1874d7c8e2db
md"""
or, passing the Table and column names,
"""

# ╔═╡ b76879aa-4ae5-4cdd-b9d1-efa9992816ee
inconsistent(f, :subid, :lab)

# ╔═╡ 0defcb99-3d49-4b43-9840-17801646dcc7
md"""
Unfortunately, we are not quite finished.
As frequently happens in data science, missing data values will complicate things.

For example, some of the values in the `preterm` column are missing.
"""

# ╔═╡ 3499dc13-e29e-4b0a-91aa-21df9fcb3f5e
unique(f.preterm)

# ╔═╡ 3e2e956a-b521-448d-9adb-ad2655636e60
md"""
and if we try to check for consistency these values cause an error
"""

# ╔═╡ a1c1230d-078a-409f-8ccc-e3de594a1fb9
inconsistent(f, :subid, :preterm)

# ╔═╡ f5983b96-552b-4da6-9bf0-664e1d477eba
md"""
The problem stems from comparison with values that may be missing.
Most comparisons will, necessarily, return missing.
The only function guaranteed to return a logical value for an argument of `missing` is `ismissing`.

We could add code to check for missing values and take appropriate action but another approach shown below allows us to side-step this problem.

## Using DataFrames to check consistency

If I were just checking for consistency in R I would `select` the key and value columns, find the `unique` rows and check the number of rows against the number of keys.  The same approach could be used with the `DataFrames` package.
"""

# ╔═╡ 74631e26-becf-45c9-9941-59cb37462092
nrow(unique(select(df, [:lab, :subid])))

# ╔═╡ 2f5b9b04-69c8-4682-bc9d-2860e5ef832b
select(df, [:lab, :subid]) |> unique |> nrow # if you feel you must use pipes

# ╔═╡ 1bbfe575-1c01-4e91-b47a-1a8693d66b8d
length(unique(df.subid))

# ╔═╡ 815c44ac-ad6f-47e6-8e7c-3839119d3f3a
md"""
This brings up a couple of "variations on a theme" for the Julia version.  Suppose we just wanted to check if the values are consistent with the keys.  Then we can short-circuit the loop.
"""

# ╔═╡ bdaca49e-786a-4198-9af7-b4c6a0975b30
begin
	function isconsistent(kvec::AbstractVector{T}, vvec::AbstractVector{S}) where {T,S}
		dict = Dict{T,S}()
		for (k, v) in zip(kvec, vvec)
			get!(dict, k, v) ≠ v && return false
		end
		true
	end
	isconsistent(ct.subid, ct.lab)
end

# ╔═╡ f8159891-f7bd-4852-b422-8c9b697bc93a
md"""
Alternatively, suppose we wanted to find all the `lab`s that used a particular `subid`.
"""

# ╔═╡ d3fc587f-84c1-4405-a96f-9dd982d20bd3
begin
	function allvals(kvec::AbstractVector{T}, vvec::AbstractVector{S}) where {T,S}
		dict = Dict{T,Set{S}}()
		for (k, v) in zip(kvec, vvec)
			push!(get!(dict, k, Set{S}()), v)
		end
		dict
	end
	setslab = allvals(ct.subid, ct.lab)
end

# ╔═╡ 68a5fa64-b46e-40ac-87c9-f16e3f4ed101
md"""
This allows us to get around the problem of missing values in the `preterm` column.
"""

# ╔═╡ ba000ae0-a20f-4037-9ece-d9411aa4d221
setspreterm = allvals(f.subid_unique, f.preterm)

# ╔═╡ dd9064f1-0ecd-463f-b58a-4fa47627667d
repeatedlab = filter(pr -> length(last(pr)) > 1, setslab)

# ╔═╡ 6234c50f-90d0-477f-9c86-429bf1590518
md"""
The construction using `->` (sometimes called a "stabby lambda") creates an anonymous function.
The argument to this function will be a `(key, value)` pair and `last(pr)` extracts the value, a `Set{String}` in this case.
"""

# ╔═╡ dc3ef214-5531-46c7-baab-f250f3d71160
md"""
`preterm`, on the other hand, is coded consistently for each `subid_unique`.
"""

# ╔═╡ ab193913-7776-4483-b6a2-3700b42319b2
repeatedpreterm = filter(pr -> length(last(pr)) > 1, setspreterm)

# ╔═╡ b12da7d5-41a1-40ca-bcaf-8b234cc0d6cf
md"""
## Extracting the inconsistent cases

The `DataFrames` package provides a `groupby` function to create a `GroupedDataFrame`.
Generally it is use in a split-apply-combine strategy but it can be used to extract subsets of rows according to the values in one or more columns.
It is effective if the operation is to be repeated for different values, such as here.
"""

# ╔═╡ 6b008853-9a2c-4eff-9885-ff034cd4b993
begin
	gdf = groupby(df, :subid);
	typeof(gdf)
end

# ╔═╡ ab3ca35a-7c30-4c53-a98f-77f31db7efa5
g1 = gdf[(subid = "1",)]

# ╔═╡ b40031ba-d4c5-40fe-9960-5f30b3423bca
unique(g1.lab)

# ╔═╡ 31e51339-e3b6-44f3-88fd-2e0fc8b5c666
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

# ╔═╡ 23db4642-ad43-434b-a48c-4b8588f1e79e
Arrow.write("02_validated_output.arrow", f);

# ╔═╡ 71b2c810-1d3b-4b86-bd8f-4540e2073195
filesize("02_validated_output.arrow")

# ╔═╡ b331ebc6-de4c-4c95-a283-3fcb362a2dab
Arrow.write("02_validated_output_compressed.arrow", f, compress = :zstd)

# ╔═╡ 199835fd-7793-42a5-b52c-16ea711cf350
filesize("02_validated_output_compressed.arrow")

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Arrow = "69666777-d1a9-59fb-9406-91d4454c9d45"
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
Tables = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"

[compat]
Arrow = "~2.3.0"
CSV = "~0.10.4"
DataFrames = "~1.3.2"
HTTP = "~0.9.17"
Tables = "~1.7.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.2"
manifest_format = "2.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Arrow]]
deps = ["ArrowTypes", "BitIntegers", "CodecLz4", "CodecZstd", "DataAPI", "Dates", "Mmap", "PooledArrays", "SentinelArrays", "Tables", "TimeZones", "UUIDs"]
git-tree-sha1 = "4e7aa2021204bd9456ad3e87372237e84ee2c3c1"
uuid = "69666777-d1a9-59fb-9406-91d4454c9d45"
version = "2.3.0"

[[deps.ArrowTypes]]
deps = ["UUIDs"]
git-tree-sha1 = "a0633b6d6efabf3f76dacd6eb1b3ec6c42ab0552"
uuid = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
version = "1.2.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitIntegers]]
deps = ["Random"]
git-tree-sha1 = "5a814467bda636f3dde5c4ef83c30dd0a19928e0"
uuid = "c3b6d118-76ef-56ca-8cc7-ebb389d030a1"
version = "0.2.6"

[[deps.CEnum]]
git-tree-sha1 = "215a9aa4a1f23fbd05b92769fdd62559488d70e9"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.1"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "873fb188a4b9d76549b81465b1f75c82aaf59238"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.4"

[[deps.CodecLz4]]
deps = ["Lz4_jll", "TranscodingStreams"]
git-tree-sha1 = "59fe0cb37784288d6b9f1baebddbf75457395d40"
uuid = "5ba52731-8f18-5e0d-9241-30f10d1ec561"
version = "0.4.0"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.CodecZstd]]
deps = ["CEnum", "TranscodingStreams", "Zstd_jll"]
git-tree-sha1 = "849470b337d0fa8449c21061de922386f32949d9"
uuid = "6b39b394-51ab-5f42-8807-6242bab2b4c2"
version = "0.7.2"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "b153278a25dd42c65abbf4e62344f9d22e59191b"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.43.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "ae02104e835f219b8930c7664b8012c93475c340"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.2"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.ExprTools]]
git-tree-sha1 = "56559bbef6ca5ea0c0818fa5c90320398a6fbf8d"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.8"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "129b104185df66e408edd6625d480b7f9e9823a0"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.18"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "61feba885fac3a407465726d0c330b3055df897f"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Lz4_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "5d494bc6e85c4c9b626ee0cab05daa4085486ab1"
uuid = "5ced341a-0733-55b8-9ab6-a4889d929147"
version = "1.9.3+0"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.Mocking]]
deps = ["Compat", "ExprTools"]
git-tree-sha1 = "29714d0a7a8083bba8427a4fbfb00a540c681ce7"
uuid = "78c3b35d-d492-501b-9361-3d52fe80e533"
version = "0.7.3"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "621f4f3b4977325b9128d5fae7a8b4829a0c2222"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.4"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "28ef6c7ce353f0b35d0df0d5930e0d072c1f5b9b"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "d3538e7f8a790dc8903519090857ef8e1283eecd"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.5"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "6a2f7d70512d205ca8c7ee31bfa9f142fe74310c"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.12"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "5ce79ce186cc678bbb5c5681ca3379d1ddae11a1"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.7.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TimeZones]]
deps = ["Dates", "Downloads", "InlineStrings", "LazyArtifacts", "Mocking", "Printf", "RecipesBase", "Serialization", "Unicode"]
git-tree-sha1 = "0a359b0ee27e4fbc90d9b3da1f48ddc6f98a0c9e"
uuid = "f269a46b-ccf7-5d73-abea-4c690281aa53"
version = "1.7.3"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[deps.URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─ec89f332-bb8c-439f-b5f0-202a23308e12
# ╠═ff373d15-7311-4653-99c6-cf1c584796d7
# ╟─51a8706e-9118-4ef4-9556-278aca0dffd7
# ╠═467715fe-8950-4a0a-8ab4-5a752c1dc5c7
# ╟─af6a751a-fbda-460c-b720-cc9442419927
# ╠═32c7f89a-3a23-4695-a5b4-ecded311d9c1
# ╠═31e273e9-e831-4ddb-b989-efd6f543d517
# ╟─50cf00c6-ddbc-48fb-af89-0c784c053335
# ╠═99750cc9-8e86-49d2-9de1-7aab69d28c71
# ╠═432bd0f2-81e9-4f31-ba1f-0c90e77672e7
# ╟─c30a26dc-c0f9-426a-8914-c0b2eb663025
# ╠═33d30241-45a0-4d8e-90b3-6436a6b65420
# ╟─d8fca1cd-b43b-45a4-91e6-d49b291ff0e2
# ╠═e3381cf3-5b2b-4f8b-be21-2459d4181975
# ╟─46bf3f16-16d0-433e-b5ba-d3e743712b05
# ╠═e7dcd9d0-4bd3-4953-950c-68bdec4eef67
# ╟─9b0c9a59-008e-4bcb-92f0-b47f5d41b4b6
# ╠═8e163074-59ae-4bd9-8d23-83af3115ecdd
# ╟─8938b29d-ac9e-48f4-9387-b8eef12ed2e4
# ╠═54c081e6-677b-4ece-835a-670a0bf9456a
# ╟─72b2f435-6b39-4414-8c9c-1874d7c8e2db
# ╠═b76879aa-4ae5-4cdd-b9d1-efa9992816ee
# ╟─0defcb99-3d49-4b43-9840-17801646dcc7
# ╠═3499dc13-e29e-4b0a-91aa-21df9fcb3f5e
# ╟─3e2e956a-b521-448d-9adb-ad2655636e60
# ╠═a1c1230d-078a-409f-8ccc-e3de594a1fb9
# ╟─f5983b96-552b-4da6-9bf0-664e1d477eba
# ╠═74631e26-becf-45c9-9941-59cb37462092
# ╠═2f5b9b04-69c8-4682-bc9d-2860e5ef832b
# ╠═1bbfe575-1c01-4e91-b47a-1a8693d66b8d
# ╟─815c44ac-ad6f-47e6-8e7c-3839119d3f3a
# ╠═bdaca49e-786a-4198-9af7-b4c6a0975b30
# ╟─f8159891-f7bd-4852-b422-8c9b697bc93a
# ╠═d3fc587f-84c1-4405-a96f-9dd982d20bd3
# ╟─68a5fa64-b46e-40ac-87c9-f16e3f4ed101
# ╠═ba000ae0-a20f-4037-9ece-d9411aa4d221
# ╠═dd9064f1-0ecd-463f-b58a-4fa47627667d
# ╟─6234c50f-90d0-477f-9c86-429bf1590518
# ╟─dc3ef214-5531-46c7-baab-f250f3d71160
# ╠═ab193913-7776-4483-b6a2-3700b42319b2
# ╟─b12da7d5-41a1-40ca-bcaf-8b234cc0d6cf
# ╠═6b008853-9a2c-4eff-9885-ff034cd4b993
# ╠═ab3ca35a-7c30-4c53-a98f-77f31db7efa5
# ╠═b40031ba-d4c5-40fe-9960-5f30b3423bca
# ╟─31e51339-e3b6-44f3-88fd-2e0fc8b5c666
# ╠═23db4642-ad43-434b-a48c-4b8588f1e79e
# ╠═71b2c810-1d3b-4b86-bd8f-4540e2073195
# ╠═b331ebc6-de4c-4c95-a283-3fcb362a2dab
# ╠═199835fd-7793-42a5-b52c-16ea711cf350
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
