# Tips on general Julia questions

- **Pre-compilation time is killing me.** Check out the `Revise.jl` package that allows you to modify code and use the changes without restarting a Julia session. This can save you the overhead of restarting Julia, loading packages, and waiting for code to JIT-compile. See [Revise github repo](https://github.com/timholy/Revise.jl). Also, look out for Julia version 1.6.0 where developers have done massive amount of work to reduce pre-compilation time.

- **DataFrames.jl seems complex to me.** Check out [this cheat sheet](https://ahsmart.com/assets/pages/data-wrangling-with-data-frames-jl-cheat-sheet/DataFramesCheatSheet_v0.21_rev3.pdf) with the main functions in DataFrames. Also, check out the use of `=>` in DataFrames [here](https://www.juliabloggers.com/how-is-used-in-dataframes-jl/?utm_source=ReviveOldPost&utm_medium=social&utm_campaign=ReviveOldPost). Finally, check the comparisons with pandas and dplyr [here](https://juliadata.github.io/DataFrames.jl/latest/man/comparisons/).

- **How about piping?** Julia supports piping via `|>`, but check out `Pipe.jl` for advanced piping functionalities. See [Pipe github repo](https://github.com/oxinabox/Pipe.jl).

- **I want to learn more about Statistical computing.** [This blog](https://github.com/johnmyleswhite/julia_tutorials/blob/master/Statistics%20in%20Julia%20-%20Maximum%20Likelihood%20Estimation.ipynb) is a good place to start. In particular, check out how the principles on mutating functions, and using `@view` instead of data copies. Also, check out [JuMP](https://jump.dev/) for more on Julia Optimization.

- **I want to learn more about macros for meta-programming.** [This blog](https://github.com/johnmyleswhite/julia_tutorials/blob/master/From%20Macros%20to%20DSLs%20in%20Julia%20-%20Part%201%20-%20Macros.ipynb) is a good place to read after the standard Julia documentation on [meta-programming](https://docs.julialang.org/en/v1/manual/metaprogramming/).

- **I want to create my own Julia package.** Read the Julia documentation about this [here](https://julialang.github.io/Pkg.jl/v1/creating-packages/).
