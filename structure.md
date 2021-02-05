# Main topics for the Julia for Data Science workshop

The five stages of programming for data science:
1. Use the REPL as a sophisticated calculator
2. Realize that you are repeating many operations, so you decide to write some functions
3. To organize all your functions, you begin scripting
4. You want to share your code with others and thus, you want to write a package
5. Your package is actually used by others and thus, it should be optimized and have good performance

Someone who is in stages 1, 2 or 3 does not need to learn to use Julia. Whatever language that they are using will be good for their purposes. However, anyone in stage 4 or 5 should seriously look into Julia as an alternative for their data science computing needs.

In a nutshell, Julia offers two main advantages to data scientists:
1. You avoid the two-language problem
2. You can easily write performant code

Julia provides a set of tools (like in a professional kitchen) that make it easy to write efficient code that is written 100% in Julia.

Among the main Julia tools, we will highlight five:
1. Data tools:
    - [Arrow.jl](https://github.com/JuliaData/Arrow.jl): memory, layout, data frame, binary form. The binary form allows for cross-platform use (julia, R, python).
    - [Tables.jl](https://github.com/JuliaData/Tables.jl): generic idea of data table; row oriented (vector of named tuples) or column oriented (named tuple of vectors)
    - [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl): [ideas](https://ahsmart.com/assets/pages/data-wrangling-with-data-frames-jl-cheat-sheet/DataFramesCheatSheet_v0.22_rev1.pdf) similar to `tidyverse`; split-apply-combine

2. Model fitting:
    - [MixedModels.jl](https://github.com/JuliaStats/MixedModels.jl): 100% julia package

3. Communications with other systems:
    - [RCall.jl](https://github.com/JuliaInterop/RCall.jl): 100% julia package
    - [PyCall.jl](https://github.com/JuliaPy/PyCall.jl): 100% julia package

4. Package system
    - With Julia 1.6, precompilation is done when the package is added
    - A local environment can be established and preserved with `Project.toml` and `Manifest.toml` files.
    - Use of `Artifacts.toml` allows for binary dependencies

5. Tuning performance
    - [Profiling](https://docs.julialang.org/en/v1/manual/profile/)

Disadvantages of Julia
- Lack of literate programming tools like `knitr`
    - Some packages exist (e.g. [Literate.jl](https://github.com/fredrikekre/Literate.jl) and [Weave.jl](https://github.com/JunoLab/Weave.jl)) but they are not as well developed as `knitr`.
    - Notebook systems like [Jupyter](https://jupyter.org) and [Pluto.jl](https://github.com/fonsp/Pluto.jl) can be used.  Pluto is different from Jupyter in that these are julia scripts with structured comments; no heavy metadata and no out of sequence evaluations

Other things worth mentioning for more savy programmers:
- Julia's multiple dispatching: generic functions; this is different to Java, C++, or Python where methods are part of classes. Multiple dispatch allows good implementation of linear algebra


# Potential structure

- Introduction (15 minutes by Claudia)
    - Getting started with Julia; highlight Julia's growth (table in email)
    - High level description of the main advantages
    - Illustration of DrWatson and potential for reproducible research; make attendees start a project to follow along the exercises of the tutorial

- Description of data tools (30 minutes by Doug)
    - Description of `Arrow.jl` and `Tables.jl`
    - Exercise with real data: checking consistency

- Description of `MixedModels` (30 minutes by Doug)
    - Exercise to illustrate main functionalities

- Brief illustration of other tools (30 minutes by Claudia)
    - Communication with other systems
    - Package system
    - Tuning performance

- Conclusions (15 minutes by Claudia)
    - Disadvantages: lack of `knitr`, others?
    - Resources/links for people who want to learn more