---
title: "Session 1: Getting started with Julia"
author: "Claudia Solis-Lemus and Douglas Bates"
subtitle: "WID Data Science Research Bazaar 2021"
output:
  xaringan::moon_reader:
    lib_dir: libs
    nature:
      ratio: '16:9'
      highlightStyle: github
      highlightLines: yes
      countIncrementalSlides: no
  html_document:
    df_print: paged
---
class: left, top

# Why Julia?

From the creators: We want a language that is

- open source 
- with the speed of C 
- obvious, familiar mathematical notation like Matlab
- as usable for general programming as Python
- as easy for statistics as R
- as natural for string processing as Perl
- as powerful for linear algebra as Matlab
- as good at gluing programs together as the shell
- dirt simple to learn, yet keeps the most serious hackers happy

---
class: left, top

# Why Julia?

![](pics/julia-headline.png)

---
class: left, top

# Why Julia?

Julia adoption accelerated at a rapid pace in 2020:

<div style="text-align:center"><img src="pics/julia-adoption.png" width="350"/></div>


---
class: left, top

# Why Julia?

The five stages of programming:
1. Use the REPL as a sophisticated calculator
2. Realize that you are repeating many operations, so you decide to write some functions
3. To organize all your functions, you begin scripting
4. You want to share your code with others and thus, you want to write a package
5. Your package is actually used by others and thus, it should be optimized and have a good performance

---
class: left, top

# Why Julia?

Julia offers many advantages to data science programmers. In particular, you avoid the two-language problem and are able to easily write good performance code.

In this workshop, we will focus on five topics:

1. Data tools: `Arrow.jl`, `Tables.jl`
2. Model fitting: `MixedModels.jl`
3. Communications with other systems: `RCall.jl` and `PyCall.jl`
4. Package system
5. Profiling

---
class: left, top

# Get started in Julia

### How do I write code?

<div style="text-align:center"><img src="pics/julia-editors.png" width="700"/></div>

---
class: left, top

# Get started in Julia

Let's start by looking at the REPL and try:
- `;` to open shell mode
- `$` to open R mode (after `using RCall`)
- `]` to open package mode: try `status`
- `?` to open help mode
- `\beta+TAB` for math symbols
- `<backspace>` return to Julia mode


---
class: left, top

## Setting up your project

- You want to set up your project to guarantee reproducibility (for you and your collaborators)
- We will focus on project management with [DrWatson.jl](https://juliadynamics.github.io/DrWatson.jl/dev/), but you can also check out the standard Julia [way](https://julialang.github.io/Pkg.jl/v1/environments/#**4.**-Working-with-Environments-1)


### Why DrWatson.jl?
To avoid:
- "I got your scripts, but none of them work on my computer"
- "Ugh these scripts worked last month, what happened?"

---
class: left, top

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

---
class: left, top

Two files are noteworthy:
- `Project.toml`: Defines project
- `Manifest.toml`: Contains exact list of project dependencies

```julia
shell> head Project.toml
name = "Example"
authors = ["CSL"]
[compat]
julia = "1.5.1"
[deps]
DrWatson = "634d3b9d-ee7a-5ddf-bec9-22491ea816e1"


shell> head Manifest.toml
# This file is machine-generated - editing it directly is not advised

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DrWatson]]
```

The packages have a [uuid](https://en.wikipedia.org/wiki/Universally_unique_identifier) string which is the universally unique identifier.
More on the `Project.toml` and `Manifest.toml` files [here](https://julialang.github.io/Pkg.jl/v1/toml-files/#Project-and-Manifest-1).

---
class: left, top

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
Status `~/Desktop/Example/Project.toml`
  [634d3b9d] DrWatson v1.16.6
  [ff71e718] MixedModels v3.1.4
```

---
class: left, top

Look at your `Project.toml` and `Manifest.toml` files now. They have all necessary information about your session.

```julia
shell> head Project.toml
name = "Example"
authors = ["CSL"]

[deps]
DrWatson = "634d3b9d-ee7a-5ddf-bec9-22491ea816e1"
MixedModels = "ff71e718-51f3-5ec2-a782-8ffcbfa3c316"

[compat]
julia = "1.5.1"


shell> head Manifest.toml
# This file is machine-generated - editing it directly is not advised

[[ArrayLayouts]]
deps = ["Compat", "FillArrays", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "a577e27915fdcb3f6b96118b56655b38e3b466f2"
uuid = "4c555306-a7a7-4459-81d9-ec55ddd5c99a"
version = "0.4.12"

[[Arrow]]
deps = ["BitIntegers", "CodecLz4", "CodecZstd", "DataAPI", "Dates", "Mmap", "PooledArrays", "SentinelArrays", "Tables", "TimeZones", "UUIDs"]
```

---
class: left, top

#### Easy share with collaborators!

Share your project to colleagues. Send your entire project folder to your colleague, and all they need to do is:

```julia
julia> cd("path/to/project")
pkg> activate .
pkg> instantiate
```

All required packages and dependencies will be installed. Scripts that run in your computer will also run in their computer.

---
class: left, top

### Other cool things about DrWatson

- `projectdir()` will always point at the project directory regardless of where you are
- `datadir()` will always point at the data folder in the project directory

```julia
julia> projectdir()
"/Users/Clauberry/Desktop/Example"

julia> datadir()
"/Users/Clauberry/Desktop/Example/data"
```

- Easy to point at files and subfolders too:

```julia
julia> datadir("mydata","tmp.txt")
"/Users/Clauberry/Desktop/Example/data/mydata/tmp.txt"
```

- Keep track of the simulations you have done, and never again overwrite files!

---
class: left, top

DrWatson Workflow in a nutshell (copied from DrWatson [tutorial](https://juliadynamics.github.io/DrWatson.jl/dev/workflow/)):

<div style="text-align:center"><img src="https://juliadynamics.github.io/DrWatson.jl/dev/workflow.png" width="700"/></div>

---
class: left, top

## Exercise

**Instructions:** Create your own project folder with `DrWatson` to follow along with the julia code in the next sessions.

Recall

```julia
julia> using DrWatson

julia> initialize_project("Example"; authors="CSL")

julia> cd("Example")

julia> @quickactivate
```


## Post-workshop learning

- Checkout [this youtube](https://www.youtube.com/watch?v=jKATlEAu8eE&feature=youtu.be) video about DrWatson
- Read DrWatson [documentation](https://juliadynamics.github.io/DrWatson.jl/dev/). What is shown here is only the tip of the iceberg!