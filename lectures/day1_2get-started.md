# Get started in julia

Let's start by looking at the REPL and try:
- `;` to open shell mode
- `$` to open R mode (after `using RCall`)
- `]` to open package mode: try `status`
- `?` to open help mode
- `\beta` for math symbols
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
 Activating new environment at `~/Dropbox/Documents/teaching/julia-workshop/Example/Project.toml`
  Resolving package versions...
Updating `~/Dropbox/Documents/teaching/julia-workshop/Example/Project.toml`
  [634d3b9d] + DrWatson v1.16.0
Updating `~/Dropbox/Documents/teaching/julia-workshop/Example/Manifest.toml`
  [634d3b9d] + DrWatson v1.16.0
  [5789e2e9] + FileIO v1.4.3
  [ae029012] + Requires v1.1.0
  [3a884ed6] + UnPack v1.0.2
  [2a0f44e3] + Base64
  [ade2ca70] + Dates
  [b77e0a4c] + InteractiveUtils
  [76f85450] + LibGit2
  [8f399da3] + Libdl
  [56ddb016] + Logging
  [d6f4376e] + Markdown
  [44cfe95a] + Pkg
  [de0858da] + Printf
  [3fa0cd96] + REPL
  [9a3f8284] + Random
  [ea8e919c] + SHA
  [9e88b42a] + Serialization
  [6462fe0b] + Sockets
  [cf7118a7] + UUIDs
  [4ec0a83e] + Unicode
"Example"

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

3. Whenever you want to start working on your project, you type:
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
  [ff71e718] MixedModels v2.4.0
```

5. Write scripts in the `scripts` folder

6. Prepare simulations. Stop parsing parameters in filenames to keep track of simulations: `savename = "w=$w_f=$f_x=$x.txt"`. Use `savename` and `@tagsave`.

A simple simulations workflow:
6.1) You have your simulation function that runs one job: `fakesim(a, b, v, method = "linear")`
6.2) You decide all the parameters that you want to try on the simulations:
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
6.3) You create your function that runs the simulation and takes a Dictionary as input:
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

6.4) Run your simulations:
```julia
for (i, d) in enumerate(dicts)
    f = makesim(d)
    @tagsave(datadir("simulations", savename(d, "bson")), f)
end
```

7. Analyze results
```julia
using DataFrames

df = collect_results(datadir("simulations"))
```
This will provide you a summary of the simulations you have run already.

8. Share your project to colleagues: send your entire project folder to your colleague, and all they need to do is:
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

DrWatson Workflow in a nutshell:
![](https://juliadynamics.github.io/DrWatson.jl/dev/workflow.png)


## Post-workshop learning

- Checkout [this youtube](https://www.youtube.com/watch?v=jKATlEAu8eE&feature=youtu.be) video about DrWatson. Kudos George for package branding!
- Read DrWatson [documentation](https://juliadynamics.github.io/DrWatson.jl/dev/). What is shown here was only the tip of the iceberg!