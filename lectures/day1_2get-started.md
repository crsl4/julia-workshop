# Get started in julia

Let's start by looking at the REPL and try:
- `;` to open shell mode
- `$` to open R mode (after `using RCall`)
- `]` to open package mode: try `status`
- `?` to open help mode
- `\beta+TAB` for math symbols
- `<backspace>` return to Julia mode


## Setting up your project

- You want to set up your project to guarantee reproducibility (for you and your collaborators)
- We will focus on project management with [DrWatson.jl](https://juliadynamics.github.io/DrWatson.jl/dev/), but you can also check out the standard Julia [way](https://julialang.github.io/Pkg.jl/v1/environments/#**4.**-Working-with-Environments-1)


### Why DrWatson.jl?
To avoid:
- "I got your scripts, but none of them work on my computer"
- "Ugh these scripts worked last month, what happened?"

### Project setup workflow

Taken from [DrWatson workflow tutorial](https://juliadynamics.github.io/DrWatson.jl/dev/workflow/).

1. Go to the working directory where you want to create the project folder (not inside the current github repo)

2. In julia:

```julia
julia> using DrWatson

julia> initialize_project("Example"; authors="CSL")

shell> ls
Example        julia-workshop

shell> cd Example/

shell> ls
Manifest.toml Project.toml  README.md     _research     data          notebooks     papers        plots         scripts       src
```
Note that `Example` is a git repository!

Two files are noteworthy:
- `Project.toml`: Defines project
- `Manifest.toml`: Contains exact list of project dependencies

```
shell> head Project.toml
name = "Example"
authors = ["CSL"]

[deps]
DrWatson = "634d3b9d-ee7a-5ddf-bec9-22491ea816e1"

[compat]
julia = "1.5.1"


shell> head Manifest.toml
# This file is machine-generated - editing it directly is not advised

[[Base64]]
 uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[DrWatson]]
 deps = ["Dates", "FileIO", "LibGit2", "Pkg", "Random", "Requires", "UnPack"]
 git-tree-sha1 = "2a022d640d242c7f54e1cf5f8f126604e02ae452"
@@ -19,10 +107,54 @@ git-tree-sha1 = "992b4aeb62f99b69fcf0cb2085094494cc05dfb3"
 uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
 version = "1.4.3"
```
The packages have a [uuid](https://en.wikipedia.org/wiki/Universally_unique_identifier) string which is the universally unique identifier.

More on the `Project.toml` and `Manifest.toml` files [here](https://julialang.github.io/Pkg.jl/v1/toml-files/#Project-and-Manifest-1).

3. Whenever you want to start working on your project, you need to be in your `Example` folder, and type:
```julia
julia> using DrWatson

julia> @quickactivate
 Activating environment at `~/Dropbox/Documents/teaching/julia-workshop/Example/Project.toml`

(Example) pkg> 
```
When we add packages, we are adding them for the project.

4. Add the necessary packages. Let's add `MixedModels`:

```julia
(Example) pkg> add MixedModels

(Example) pkg> status
Status `~/Dropbox/Documents/teaching/julia-workshop/Example/Project.toml`
  [634d3b9d] DrWatson v1.16.0
  [ff71e718] MixedModels v3.0.0
```

#### Let's talk about simulations

Stop parsing parameters in filenames to keep track of simulations: `savename = "w=$w_f=$f_x=$x.txt"`. Instead use `savename` and `@tagsave` as described below.

A simple simulations workflow: 

1. You have your simulation function that runs one job: `fakesim(a, b, v, method = "linear")`

2. You decide all the parameters that you want to try on the simulations:
```julia
allparams = Dict(
    :a => [1, 2], # it is inside vector. It is expanded.
    :b => [3, 4],
    :v => [rand(5)], # single element inside vector; no expansion
    :method => "linear", # not in vector = not expanded
)

dicts = dict_list(allparams)
```
You get all the parameter combinations:
```julia
4-element Array{Dict{Symbol,Any},1}:
 Dict(:a => 1,:b => 3,:method => "linear",:v => [0.9726901391682818, 0.22300183839741217, 0.9093285153487787, 0.5280066726357, 0.7686151029111623])
 Dict(:a => 2,:b => 3,:method => "linear",:v => [0.9726901391682818, 0.22300183839741217, 0.9093285153487787, 0.5280066726357, 0.7686151029111623])
 Dict(:a => 1,:b => 4,:method => "linear",:v => [0.9726901391682818, 0.22300183839741217, 0.9093285153487787, 0.5280066726357, 0.7686151029111623])
 Dict(:a => 2,:b => 4,:method => "linear",:v => [0.9726901391682818, 0.22300183839741217, 0.9093285153487787, 0.5280066726357, 0.7686151029111623])
 ```

3. You create your function that runs the simulation and takes a Dictionary as input:
```julia
function makesim(d::Dict)
    @unpack a, b, v, method = d
    r, y = fakesim(a, b, v, method)
    fulld = copy(d)
    fulld[:r] = r
    fulld[:y] = y
    return fulld
end
```

4. Run your simulations:
```julia
for (i, d) in enumerate(dicts)
    f = makesim(d)
    @tagsave(datadir("simulations", savename(d, "bson")), f)
end
```

See your files:
```shell
$ cd data/simulations/
$ ls
a=1_b=3_method=linear.bson a=2_b=3_method=linear.bson
a=1_b=4_method=linear.bson a=2_b=4_method=linear.bson
```

5. Analyze results
```julia
using DataFrames
df = collect_results(datadir("simulations"))
```

This will provide you a summary of the simulations you have run already:
```
4×7 DataFrame. Omitted printing of 2 columns
│ Row │ a      │ b      │ method  │ y        │ v                                                 │
│     │ Int64? │ Int64? │ String? │ Float64? │ Union{Missing, Array{Float64,1}}                  │
├─────┼────────┼────────┼─────────┼──────────┼───────────────────────────────────────────────────┤
│ 1   │ 1      │ 3      │ linear  │ 1.73205  │ [0.322487, 0.916779, 0.228918, 0.13816, 0.813318] │
│ 2   │ 1      │ 4      │ linear  │ 2.0      │ [0.322487, 0.916779, 0.228918, 0.13816, 0.813318] │
│ 3   │ 2      │ 3      │ linear  │ 1.73205  │ [0.322487, 0.916779, 0.228918, 0.13816, 0.813318] │
│ 4   │ 2      │ 4      │ linear  │ 2.0      │ [0.322487, 0.916779, 0.228918, 0.13816, 0.813318] │
```


#### Easy share with collaborators!

Share your project to colleagues. Send your entire project folder to your colleague, and all they need to do is:
```julia
julia> cd("path/to/project")
pkg> activate .
pkg> instantiate
```
All required packages and dependencies will be installed. Scripts that run in your computer will also run in their computer.

### Cool things about DrWatson

- `projectdir()` will always point at the project directory regardless of where you are
- `datadir()` will always point at the data folder in the project directory

```julia
julia> projectdir()
"/Users/Clauberry/Dropbox/Documents/teaching/julia-workshop/Example"

julia> datadir()
"/Users/Clauberry/Dropbox/Documents/teaching/julia-workshop/Example/data"
```

- Easy to point at files and subfolders too:
```julia
julia> datadir("mydata","tmp.txt")
"/Users/Clauberry/Dropbox/Documents/teaching/julia-workshop/Example/data/mydata/tmp.txt"
```

- Keep track of the simulations you have done, and never again overwrite files!

DrWatson Workflow in a nutshell (copied from DrWatson [tutorial](https://juliadynamics.github.io/DrWatson.jl/dev/workflow/)):
![](https://juliadynamics.github.io/DrWatson.jl/dev/workflow.png)

## Exercise (10 minutes)

Follow the steps from above to run toy simulations in your project. You can design a simulation based on your own research, or you can use the same example above with the following function:
```julia
function fakesim(a, b, v, method = "linear")
    if method == "linear"
        r = @. a + b * v
    elseif method == "cubic"
        r = @. a*b*v^3
    end
    y = sqrt(b)
    return r, y
end
```

**Warning:** You will need to install the package `BSON` if you are following the example above:
```julia
(Example) pkg> add BSON
```
You also need to add the package `DataFrames`.

**Tip:** Check that the simulations produced the files in shell mode:
```julia
shell> ls data/simulations/
a=1_b=3_method=linear.bson a=1_b=4_method=linear.bson a=2_b=3_method=linear.bson a=2_b=4_method=linear.bson
```

## Final thoughts
Look at your `Project.toml` and `Manifest.toml` files now. They have all necessary information about your session.
```
shell> head -n11 Project.toml
name = "Example"
authors = ["CSL"]

[deps]
BSON = "fbb218c0-5317-5bc6-957e-2ee96dd4b1f0"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
DrWatson = "634d3b9d-ee7a-5ddf-bec9-22491ea816e1"
MixedModels = "ff71e718-51f3-5ec2-a782-8ffcbfa3c316"

[compat]
julia = "1.5.1"


shell> head Manifest.toml
# This file is machine-generated - editing it directly is not advised

[[ArrayLayouts]]
deps = ["FillArrays", "LinearAlgebra"]
git-tree-sha1 = "951c3fc1ff93497c88fb1dfa893f4de55d0b38e3"
uuid = "4c555306-a7a7-4459-81d9-ec55ddd5c99a"
version = "0.3.8"

[[BSON]]
git-tree-sha1 = "dd36d7cf3d185eeaaf64db902c15174b22f5dafb"
```

## Post-workshop learning

- Checkout [this youtube](https://www.youtube.com/watch?v=jKATlEAu8eE&feature=youtu.be) video about DrWatson. Kudos to George for package branding!
- Read DrWatson [documentation](https://juliadynamics.github.io/DrWatson.jl/dev/). What is shown here is only the tip of the iceberg!