---
title: "Session 5: Conclusions"
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

# Today you have learned

- Julia provides many advantages to data science programmers especially those creating programs that need to be efficient and that will be shared with the scientific community
- Julia allows programmers to easily write good performant code and avoid the two language problem

Among the main Julia tools, we focused on five:
1. Data tools:
  -  [Arrow.jl](https://github.com/JuliaData/Arrow.jl): memory, layout, data frame, binary form. The binary form allows for cross-platform use (julia, R, python). Need to be careful going from Julia to R
  - [Tables.jl](https://github.com/JuliaData/Tables.jl): generic idea of data table; row oriented (vector of named tuples) or column oriented (named tuple of vectors)
  - [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl): [ideas](https://ahsmart.com/assets/pages/data-wrangling-with-data-frames-jl-cheat-sheet/DataFramesCheatSheet_v0.22_rev1.pdf) similar to `tidyverse`; split-apply-combine

2. Model fitting:
  - [MixedModels.jl](https://github.com/JuliaStats/MixedModels.jl): 100% julia package
  
---
class: left, top

# Today you have learned

3. Communications with other systems:
  - [RCall.jl](https://github.com/JuliaInterop/RCall.jl): 100% julia package
  - [PyCall.jl](https://github.com/JuliaPy/PyCall.jl): 100% julia package

4. Package system
  - With Julia 1.6, precompilation is done when the package is added

5. Tuning performance
  - [Performance tips](https://docs.julialang.org/en/v1/manual/performance-tips/)
  - [Profiling](https://docs.julialang.org/en/v1/manual/profile/)
  
---
class: left, top

# What are Julia's disadvantages?

- Data visualization: no `ggplot2` yet
- Literate programming: no `knitr` yet
  - [Literate.jl](https://github.com/fredrikekre/Literate.jl)
  - [Pluto.jl](https://github.com/fonsp/Pluto.jl): different from jupyer notebook in that these are julia scripts with structured comments; no heavy metadata and no out of sequence evaluations
  
---
class: left, top

<div style="text-align:center"><img src="pics/julia-logo.png" width="350"/></div>


# Take home message!

A programming language has tools for a programmer like a kitchen has tools for a cook.

Julia is like a well-organized kitchen of a master chef. Cooking scrambled eggs or a Michelin-star dish is up to the cook. All the tools are there!


# Questions?