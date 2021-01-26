---
title: "Session 4: Other tools for Data Science"
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

# So far you have learned

- Data tools with `Arrow.jl` and `Tables.jl`
- Model fitting with `MixedModels.jl`

# Other Data Science tools in Julia

- Communication with other systems: R and python
- Package system
- Tuning performance 

---
class: left, top

# Communication with other systems: Julia interoperability

[JuliaInterop](https://github.com/JuliaInterop)

![](pics/juliainterop.png)

**Note:** Both `RCall` and `PyCall` are written 100% julia

---
class: left, top

## RCall

[Documentation](https://juliainterop.github.io/RCall.jl/stable/)


Switching between julia and R:

```julia
julia> foo = 1
1

R> x <- $foo

R> x
[1] 1
```

---
class: left, top

`@rget` and `@rput` macros:

```julia
julia> z = 1
1

julia> @rput z
1

R> z
[1] 1

R> r = 2

julia> @rget r
2.0

julia> r
2.0
```

---
class: left, top

`R""` string macro

```julia
julia> R"rnorm(10)"
RObject{RealSxp}
 [1]  0.9515526 -2.1268329 -1.1197652 -1.3737837 -0.5308834 -0.1053615
 [7]  1.0949319 -0.8180752  0.7316163 -1.3735100
```

Large chunk of code

```julia
julia> y=1
1

julia> R"""
       f<-function(x,y) x+y
       ret<- f(1,$y)
       """
RObject{RealSxp}
[1] 2
```

---
class: left, top

## A small example from [this blog](http://luiarthur.github.io/usingrcall)

Simulate data

```julia
julia> using Random

julia> Random.seed!(1234)
MersenneTwister(1234)

julia> X = randn(3,2)
3×2 Matrix{Float64}:
  0.867347  -0.902914
 -0.901744   0.864401
 -0.494479   2.21188

julia> b = reshape([2.0, 3.0], 2,1)
2×1 Matrix{Float64}:
 2.0
 3.0

julia> y = X * b + randn(3,1)
3×1 Matrix{Float64}:
 -0.4412351955236954
  0.5179809120122916
  6.149009488103242
```

---
class: left, top

Fit a model

```julia
julia> @rput y
3×1 Matrix{Float64}:
 -0.4412351955236954
  0.5179809120122916
  6.149009488103242

julia> @rput X
3×2 Matrix{Float64}:
  0.867347  -0.902914
 -0.901744   0.864401
 -0.494479   2.21188

julia> R"mod <- lm(y ~ X-1)"
RObject{VecSxp}

Call:
lm(formula = y ~ X - 1)

Coefficients:
   X1     X2  
2.867  3.418 
```

---
class: left, top

```julia
julia> R"summary(mod)"
RObject{VecSxp}

Call:
lm(formula = y ~ X - 1)

Residuals:
       1        2        3 
0.158301 0.148692 0.006511 

Coefficients:
   Estimate Std. Error t value Pr(>|t|)  
X1   2.8669     0.2566   11.17   0.0568 .
X2   3.4180     0.1359   25.15   0.0253 *
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.2173 on 1 degrees of freedom
Multiple R-squared:  0.9988,	Adjusted R-squared:  0.9963 
F-statistic: 404.8 on 2 and 1 DF,  p-value: 0.03512

julia> R"plot(X[,1],y)"
```

---
class: left, top

## PyCall

[Documentation](https://github.com/JuliaPy/PyCall.jl)

`(@v1.6) pkg> add PyCall` will use the `Conda.jl` package to install a minimal Python distribution (via Miniconda) that is private to Julia (not in your PATH)

Simple example:

```julia
using PyCall
math = pyimport("math")
math.sin(math.pi / 4)
```

---
class: left, top

`py"..."` evaluates `"..."` as Python code:

```julia
py"""
import numpy as np

def sinpi(x):
    return np.sin(np.pi * x)
"""
py"sinpi"(1)
```

#### More on Julia/python connectivity

- The [pyjulia](https://github.com/JuliaPy/pyjulia) module allows you to call Julia directly from Python
- Check out the packages in [JuliaPy](https://github.com/JuliaPy)

---
class: left, top

# Package system

- Starting on Julia 1.6, precompilation is much faster
- Many changes under the hood that allow things to work faster and more smoothly

---
class: left, top

# Performance tips

See more in [Julia docs](https://docs.julialang.org/en/v1/manual/performance-tips/)

#### `@time` to measure performance

```julia
julia> x = rand(1000);

julia> function sum_global()
           s = 0.0
           for i in x
               s += i
           end
           return s
       end;

julia> @time sum_global()  ## function gets compiled
  0.017705 seconds (15.28 k allocations: 694.484 KiB)
496.84883432553846

julia> @time sum_global()
  0.000140 seconds (3.49 k allocations: 70.313 KiB)
496.84883432553846
```

---
class: left, top

#### Break functions into multiple definitions

The function

```julia
using LinearAlgebra

function mynorm(A)
    if isa(A, Vector)
        return sqrt(real(dot(A,A)))
    elseif isa(A, Matrix)
        return maximum(svdvals(A))
    else
        error("mynorm: invalid argument")
    end
end
```

should really be written as
```julia
norm(x::Vector) = sqrt(real(dot(x, x)))
norm(A::Matrix) = maximum(svdvals(A))
```

to allow the compiler to directly call the most applicable code.

---
class: left, top

#### Multiple dispatch

- The choice of which method to execute when a function is applied is called _dispatch_
- Julia allows the dispatch process to choose based on the number of arguments given, and on the types of all of the function's arguments
- This is denoted _multiple dispatch_
- This is different than traditional object-oriented languages, where dispatch occurs based only on the first argument

```julia
julia> f(x::Float64, y::Float64) = 2x + y
f (generic function with 1 method)

julia> f(2.0, 3.0)
7.0

julia> f(2.0, 3)
ERROR: MethodError: no method matching f(::Float64, ::Int64)
Closest candidates are:
  f(::Float64, !Matched::Float64) at none:1
```

---
class: left, top

Compare to

```julia
julia> f(x::Number, y::Number) = 2x + y
f (generic function with 2 methods)

julia> f(2.0, 3.0)
7.0

julia> f(2, 3.0)
7.0

julia> f(2.0, 3)
7.0

julia> f(2, 3)
7
```

---
class: left, top

#### Profiling

Read more in [Julia docs](https://docs.julialang.org/en/v1/manual/profile/#Profiling).

```julia
julia> function myfunc()
           A = rand(200, 200, 400)
           maximum(A)
       end

julia> myfunc() # run once to force compilation

julia> using Profile

julia> @profile myfunc()

julia> Profile.print()
```

To see the profiling results, there are several graphical browsers (see [Julia docs](https://docs.julialang.org/en/v1/manual/profile/#Profiling)).

---
class: left, top

### Other packages for performance

- [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl): performance tracking of Julia code
- [Traceur.jl](https://github.com/JunoLab/Traceur.jl): You run your code, it tells you about any obvious performance traps

---
class: left, top

# Exercise

**Instructions:** Choose one function that was defined in the previous sessions and test its performance with `@time`, `@allocated` or whatever profiling tools you choose

**Time:** 5 minutes

_Optional:_ Re-write the function in R or python and run it through julia with `RCall` or `PyCall`. Compare the performance with the julia implementation.