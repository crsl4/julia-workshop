---
title: "Session 2: Data Tables and Arrow files"
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

# Exploring Julia packages

- [JuliaHub](https://juliahub.com) provides a [package explorer](https://juliahub.com/ui/Packages)
- You can search by topic or a fuzzy search on names
- Sort order is by number of stars for the github repository
- Almost all packages are github repositories (some in gitlab)
- Almost all use an MIT license
- Various github groups manage packages for specific fields, such as `JuliaData` for Data Science packages
- If you check the source repository for many packages, even advanced packages, you will often see that they are 100% Julia code

---
class: left, top

# Data tables in Julia

- Both `R` and `Python` (through `pandas`) use column-oriented data frames for data tables.
- Relational data bases tend to be row-oriented based on a row schema
- Of course, most data is stored in CSV files or spreadsheets
- It helps to be able to switch back and forth between these views
- The `JuliaData` group produces and maintains several packages built around a `Tables` interface

---
class: left, top

# Notebook on checking consistency

- Copy the file `notebooks/consistency.jmd` from this repository to the `notebooks` directory of your `DrWatson` project.
- This is a `Julia markdown` file, similar to `R markdown` (.Rmd)
- In your project's `notebooks` directory run

```julia
julia> pwd()
"/home/bates/projects/DataScienceWorkshop/notebooks"

julia> using DrWatson

julia> @quickactivate

julia> using Weave

julia> convert_doc("consistency.jmd", "consistency.ipynb")
"consistency.ipynb"
```
---
class: left, top

# Running the Jupyter notebooks

- This produces a Jupyter notebook.  
- You can start `jupyter notebook`or `jupyter lab` as you would normally or
- You can use the IJulia package's functions

```julia
julia> using IJulia

julia> jupyterlab(dir = ".")
```

---
class: left, top

## Exercise: Part 1

**Instructions:** Download the file `processed_data/03_data_trial_main.csv` from the `mb1-analysis-public` repository on github (or clone the repository).  Read the file using Julia's CSV package and convert the table to a DataFrame.  Use `describe` to summarize the data frame.  Can you detect any problems with the data set?

**Time:** 3-5 minutes.

Set up:
```julia
julia> using DrWatson

julia> @quickactivate

julia> using CSV, DataFrames
```

---
class: left, top

# The Arrow notebook

- `Arrow.jmd` uses the Julia `Arrow` package and Python's `pyarrow` and the `arrow` package for R.
- If you are fluent in only one of `R` or `Python` you may want to skip the parts for the other language.

---
class: left, top

## Exercise: Part 2

**Instructions:** Clean up any problems you have encountered in the `03_data_trial_main` frame.  Write the result to an Arrow file and read it into either `R` or `Python` for further analysis.

**Time:** 5-7 minutes.
