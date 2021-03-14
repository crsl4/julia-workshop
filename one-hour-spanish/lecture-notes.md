---
title: "Julia para Ciencias de Datos"
author: "Claudia Solis-Lemus"
subtitle: "Seminario de Investigación de la Escuela de Estadística de la Universidad de Los Andes, Mérida, Venezuela"
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

# Por qué Julia?

De los creadores de Julia: 

We want a language that is

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

# Por qué Julia?

![](../lectures/pics/julia-headline.png)

---
class: left, top

# Por qué Julia?

- [CliMA 0.1](https://clima.caltech.edu/2020/06/08/clima-0-1-a-first-milestone-in-the-next-generation-of-climate-models/): a first milestone in the next generation of climate models

- [ClimateMachine.jl](https://github.com/CliMA/ClimateMachine.jl)

---
class: left, top

# Por qué Julia?

Ha habido una adopción acelerada del lenguaje en 2020:

<div style="text-align:center"><img src="../lectures/pics/julia-adoption.png" width="350"/></div>


---
class: left, top

# Por qué Julia?

Hay 5 etapas de programación
1. Usar el REPL como una calculadora sofisticada
2. Escribir funciones en vez de repetir operaciones
3. Organizar multiple funciones en scripts
4. Deseo de compartir el código con otras personas a través de la creación de un paquete o librería
5. El paquete es usado por otras personas y necesita ser optimizado para tener buen rendimiento


---
class: left, top

# Por qué Julia?

Julia ofrece muchas ventajas a programadores en Ciencias de Datos. En particular, evitar el "two-language problem" y poder escribir código con buen rendimiento de una manera fácil.

Las principales herramientas en Julia para Ciencias de Datos se pueden clasificar en:

1. Data tools: `Arrow.jl`, `Tables.jl`
2. Model fitting: `MixedModels.jl`
3. Communications with other systems: `RCall.jl` and `PyCall.jl`
4. Package system
5. Profiling

---
class: left, top

# Intro Julia

### Cómo escribo código en Julia?

<div style="text-align:center"><img src="../lectures/pics/julia-editors.png" width="700"/></div>

---
class: left, top

# Intro Julia

En el REPL, intenta:
- `;` abre el modo shell
- `$` abre el modo R (con `using RCall`)
- `]` abre el modo package: escribe `status`
- `?` abre el modo ayuda
- `\beta+TAB` para símbolos matemáticos
- `<backspace>` para regresar a modo Julia


---
class: left, top

## Empezar tu proyecto

- Se quiere garantizar reproducibilidad (para ti y tus colaboradores)
- Project managementÑ [DrWatson.jl](https://juliadynamics.github.io/DrWatson.jl/dev/)


### Xq DrWatson.jl?
Para evitar:
- "Tus scripts no corren en mi computadora"
- "Ugh estos scripts funcionaban en mes pasado, pero ya no funcionan"

---
class: left, top

### Project setup workflow

[DrWatson workflow tutorial](https://juliadynamics.github.io/DrWatson.jl/dev/workflow/).

1) Ir al working directory donde se quiere crear el folder del proyecto (cuidado de no estar adentro de un git repository)

2) En julia:

```julia
julia> using DrWatson

julia> initialize_project("DataScienceWorkshop"; authors="CSL")

shell> ls
DataScienceWorkshop        julia-workshop

shell> cd DataScienceWorkshop/

shell> ls
Manifest.toml Project.toml  README.md     _research     data          notebooks     papers        plots         scripts       src
```
Notar que `DataScienceWorkshop` es un repositorio de git!

---
class: left, top

3) Cuando vayas a trabajar en tu proyecto, necesitas estar en tu folder `DataScienceWorkshop` y escribir:

```julia
julia> using DrWatson

julia> @quickactivate

(DataScienceWorkshop) pkg> 
```

Cuando añades paquetes, lo hacen en el ambiente de tu proyecto.


4) Añade los paquetes que necesitas, por ejemplo `MixedModels`:

```julia
(DataScienceWorkshop) pkg> add MixedModels

(DataScienceWorkshop) pkg> status
Status `~/Documents/DataScienceWorkshop/Project.toml`
  [634d3b9d] DrWatson v1.16.6
  [ff71e718] MixedModels v3.1.4
```

---
class: left, top

## Exercicio: Parte 1

**Instruccioness:** Crear to folder de proyecto con `DrWatson`.

**Tiempo:** 1-2 minutes.

```julia
(@v1.6) pkg> add DrWatson

julia> using DrWatson

julia> initialize_project("DataScienceWorkshop"; authors="YOU")

julia> cd("DataScienceWorkshop")

julia> @quickactivate
```

---
class: left, top

## Exercicio: Parte 2

Instalar paquetes:
```julia
(DataScienceWorkshop) pkg> add CSV DataFrames Arrow Tables HTTP JellyMe4 RCall

julia> ENV["PYTHON"] = ""

(DataScienceWorkshop) pkg> add PyCall

julia> using PyCall

julia> feather = pyimport_conda("pyarrow.feather","pyarrow", "conda-forge")

(DataScienceWorkshop) pkg> add Weave IJulia

(DataScienceWorkshop) pkg> build IJulia
```

---
class: left, top

Dos archivos son importantes:
- `Project.toml`: Define el proyecto
- `Manifest.toml`: Contiene la lista exacta de las dependencias del proyecto

```julia
shell> head Project.toml
name = "DataScienceWorkshop"
authors = ["CSL"]
[compat]
julia = "1.6.0"
[deps]
DrWatson = "634d3b9d-ee7a-5ddf-bec9-22491ea816e1"


shell> head Manifest.toml
# This file is machine-generated - editing it directly is not advised

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
```

Los paquetes tienen un [uuid](https://en.wikipedia.org/wiki/Universally_unique_identifier) que es el "universally unique identifier".
Para leer más del `Project.toml` y `Manifest.toml`, ver este [link](https://julialang.github.io/Pkg.jl/v1/toml-files/#Project-and-Manifest-1).



---
class: left, top

Si miramos los archivos `Project.toml` y `Manifest.toml` después de la instalación de los paquetes, podemos ver que tienen toda la información.

```julia
shell> head Project.toml
name = "DataScienceWorkshop"
authors = ["CSL"]

[deps]
DrWatson = "634d3b9d-ee7a-5ddf-bec9-22491ea816e1"
MixedModels = "ff71e718-51f3-5ec2-a782-8ffcbfa3c316"

[compat]
julia = "1.6.0"


shell> head Manifest.toml
# This file is machine-generated - editing it directly is not advised

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[ArrayLayouts]]
deps = ["Compat", "FillArrays", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "a577e27915fdcb3f6b96118b56655b38e3b466f2"
uuid = "4c555306-a7a7-4459-81d9-ec55ddd5c99a"
version = "0.4.12"
```

---
class: left, top

#### Colaboraciones fáciles

Envía tu folder a tus colaboradores y ellos sólo tienen que hacer lo siguiente:

```julia
julia> cd("path/to/project")
pkg> activate .
pkg> instantiate
```

Todos los paquetes y dependencias serán instalados.

---
class: left, top


DrWatson Workflow in a nutshell (copied from DrWatson [tutorial](https://juliadynamics.github.io/DrWatson.jl/dev/workflow/)):

<div style="text-align:center"><img src="https://juliadynamics.github.io/DrWatson.jl/dev/workflow.png" width="700"/></div>

---
class: left, top

## Aprende por tu cuenta

- Mira este video en [youtube](https://www.youtube.com/watch?v=jKATlEAu8eE&feature=youtu.be) sobre `DrWatson`
- Lee la documentacion de `DrWatson` [aqui](https://juliadynamics.github.io/DrWatson.jl/dev/)


---
class: left, top

# `Arrow` para transferencia de datos

El formato [Apache Arrow](https://arrow.apache.org/) es un formato binario para datos en tables orientados en columnas. Distintos lenguages como `Julia`, `R` y `python` pueden utilizar este tipo de formato.

En `Julia`, `Arrow` se usa para guardar y leer datos en `Tables` y para intercambiar datos con `R` y `python`.


```julia
using Arrow, CSV, DataFrames, HTTP, Tables

f = CSV.File(
    HTTP.get("https://github.com/manybabies/mb1-analysis-public/raw/master/processed_data/02_validated_output.csv").body,
    missingstrings = ["NA"],
	truestrings = ["TRUE"],
	falsestrings = ["FALSE"],
);
```

---
class: left, top

`f` puede convertirse en una tabla genérica orientada en columnas con `Tables.columntable`

```julia
ct = Tables.columntable(f)
```
que es un `NamedTuple`, como una `list` en `R`.
Es una estructure inmutable en el sentido de que los nombres y direcciones de los vectores que representan las columnas no pueden ser cambiados.
Los valores en los vectores pueden ser modificados, pero la estructura no.

---
class: left, top

Un objeto `DataFrame` del paquete [DataFrames](https://github.com/JuliaData/DataFrames.jl) es mutable.  Este paquete ofrece funciones comparables con `tidyverse` o `pandas`.

```julia
julia> begin
           df = DataFrame(ct);
           describe(df)
       end
80×7 DataFrame
 Row │ variable                     mean      min                                median   max                                nmissing  eltype                  
     │ Symbol                       Union…    Any                                Union…   Any                                Int64     Type                    
─────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ lab                                    babylabbrookes                              wsigoettingen                             0  String
   2 │ subid                                  1                                           zu247                                     0  String
   3 │ trial_num                    7.35365   -2                                 7.0      16                                        0  Int64
   4 │ trial_type                             ADS                                         TRAIN                                   636  Union{Missing, String}
   5 │ stimulus_num                 3.85648   -1                                 4.0      8                                       636  Union{Missing, Int64}
   6 │ looking_time                 6.72888   0.0                                5.2      18.0                                   4703  Union{Missing, Float64}
   7 │ trial_error                  0.149401  false                              0.0      true                                      0  Bool
  ⋮  │              ⋮                  ⋮                      ⋮                     ⋮                     ⋮                     ⋮                 ⋮
  74 │ session_error_change_reason            age exclusion - in age range                trial level error                     44846  Union{Missing, String}
  75 │ session_error_type_recoded             equipment failure                           outside interference                  47900  Union{Missing, String}
  76 │ trial_error_recoded          1.0       1                                  1.0      1                                     49302  Union{Missing, Int64}
  77 │ trial_error_change_reason              exclude as error based on lab re…           trial level error for fussiness …     49302  Union{Missing, String}
  78 │ nae                          0.452756  false                              0.0      true                                      0  Bool
  79 │ age_mo                       9.88087   2.92402                            9.79055  24.3121                                 119  Union{Missing, Float64}
  80 │ age_group                              12-15 mo                                    9-12 mo                                1165  Union{Missing, String}
                                                                                                                                                66 rows omitted
```

---
class: left, top

```julia
julia> df
50080×80 DataFrame
   Row │ lab             subid   trial_num  trial_type  stimulus_num  looking_time  trial_error  trial_error_type  method        ra       age_days  trial_order   ⋯
       │ String          String  Int64      String?     Int64?        Float64?      Bool         String?           String        String?  Int64?    Int64?        ⋯
───────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     1 │ babylabbrookes  mb07           -2  TRAIN                 -1         11.21        false  missing           singlescreen  N1            493            3   ⋯
     2 │ babylabbrookes  mb07           -1  TRAIN                 -1          4.57        false  missing           singlescreen  N1            493            3
     3 │ babylabbrookes  mb07            1  IDS                    5          9.35        false  missing           singlescreen  N1            493            3
     4 │ babylabbrookes  mb07            2  ADS                    5          8.18        false  missing           singlescreen  N1            493            3
     5 │ babylabbrookes  mb07            3  ADS                    7          5.58        false  missing           singlescreen  N1            493            3   ⋯
     6 │ babylabbrookes  mb07            4  IDS                    7          8.94        false  missing           singlescreen  N1            493            3
     7 │ babylabbrookes  mb07            5  ADS                    1         18.0         false  missing           singlescreen  N1            493            3
   ⋮   │       ⋮           ⋮         ⋮          ⋮            ⋮             ⋮             ⋮              ⋮               ⋮           ⋮        ⋮           ⋮        ⋱
 50074 │ wsigoettingen   m417           10  IDS                    5          1.58        false  missing           singlescreen  Natalie       400            1
 50075 │ wsigoettingen   m417           11  ADS                    6          3.93        false  missing           singlescreen  Natalie       400            1   ⋯
 50076 │ wsigoettingen   m417           12  IDS                    6          2.12        false  missing           singlescreen  Natalie       400            1
 50077 │ wsigoettingen   m417           13  IDS                    7          2.95        false  missing           singlescreen  Natalie       400            1
 50078 │ wsigoettingen   m417           14  ADS                    7          2.78        false  missing           singlescreen  Natalie       400            1
 50079 │ wsigoettingen   m417           15  ADS                    8          2.97        false  missing           singlescreen  Natalie       400            1   ⋯
 50080 │ wsigoettingen   m417           16  IDS                    8          3.67        false  missing           singlescreen  Natalie       400            1
                                                                                                                                  68 columns and 50066 rows omitted
```

---
class: left, top

La tabla se puede guardar como objeto `Arrow`:
```julia
julia> Arrow.write("02_validated_output.arrow", f);

julia> filesize("02_validated_output.arrow")
13736194

julia> Arrow.write("02_validated_output_compressed.arrow", f, compress = :zstd)
"02_validated_output_compressed.arrow"

julia> filesize("02_validated_output_compressed.arrow")
780258
```

---
class: left, top

### Leer un objeto `Arrow` escrito con Julia

```julia
using Arrow, DataFrames, PyCall, RCall
```

La función `Arrow.Table` lee un archivo Arrow y regresa una tabla en columnas que se puede convertir a `DataFrame` si se desea.

```julia
tbl = Arrow.Table("02_validated_output.arrow");
```
---
class: left, top

```julia
julia> df = DataFrame(tbl);

julia> describe(df)

80×7 DataFrame
 Row │ variable                     mean      min                                median   max                                nmissing  eltype                  
     │ Symbol                       Union…    Any                                Union…   Any                                Int64     Type                    
─────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ lab                                    babylabbrookes                              wsigoettingen                             0  String
   2 │ subid                                  1                                           zu247                                     0  String
   3 │ trial_num                    7.35365   -2                                 7.0      16                                        0  Int64
   4 │ trial_type                             ADS                                         TRAIN                                   636  Union{Missing, String}
   5 │ stimulus_num                 3.85648   -1                                 4.0      8                                       636  Union{Missing, Int64}
   6 │ looking_time                 6.72888   0.0                                5.2      18.0                                   4703  Union{Missing, Float64}
   7 │ trial_error                  0.149401  false                              0.0      true                                      0  Bool
   8 │ trial_error_type                       "experimenter error"                        wiggly                                41611  Union{Missing, String}
  ⋮  │              ⋮                  ⋮                      ⋮                     ⋮                     ⋮                     ⋮                 ⋮
  73 │ session_error_recoded        0.104513  0                                  0.0      1                                         0  Int64
  74 │ session_error_change_reason            age exclusion - in age range                trial level error                     44846  Union{Missing, String}
  75 │ session_error_type_recoded             equipment failure                           outside interference                  47900  Union{Missing, String}
  76 │ trial_error_recoded          1.0       1                                  1.0      1                                     49302  Union{Missing, Int64}
  77 │ trial_error_change_reason              exclude as error based on lab re…           trial level error for fussiness …     49302  Union{Missing, String}
  78 │ nae                          0.452756  false                              0.0      true                                      0  Bool
  79 │ age_mo                       9.88087   2.92402                            9.79055  24.3121                                 119  Union{Missing, Float64}
  80 │ age_group                              12-15 mo                                    9-12 mo                                1165  Union{Missing, String}
                                                                                                                                                64 rows omitted

julia> typeof(tbl.subid)
Arrow.DictEncoded{String, Int16, Arrow.List{String, Int32, Vector{UInt8}}}
```

---
class: left, top

### Consistencia de tus datos

Para aprender más acerca de cómo verificar consitencia de tus datos, revisa estos [scripts](https://github.com/crsl4/julia-workshop/blob/main/notebooks/consistency.jmd).

### Leer un archivo Arrow de Julia en R

```r
library(tibble)
valid <- read_feather("02_validated_output.arrow")
glimpse(valid)
```

De manera similar, se puede usar python con `pyarrow.Table`.

---
class: left, top

# Modelos de efectos mixtos con `MixedModels`

### Belenky et al. (2003) study on sleep deprivation
- 18 individuos
- 10 días de prueba
- Tiempo de reacción medido

```julia
julia> sleepstudy = DataFrame(MixedModels.dataset(:sleepstudy));
julia> describe(sleepstudy)

3×8 DataFrame
│ Row │ variable │ mean    │ min     │ median  │ max     │ nunique │ nmissing │ eltype   │
│     │ Symbol   │ Union…  │ Any     │ Union…  │ Any     │ Union…  │ Nothing  │ DataType │
├─────┼──────────┼─────────┼─────────┼─────────┼─────────┼─────────┼──────────┼──────────┤
│ 1   │ subj     │         │ S308    │         │ S372    │ 18      │          │ String   │
│ 2   │ days     │ 4.5     │ 0       │ 4.5     │ 9       │         │          │ Int8     │
│ 3   │ reaction │ 298.508 │ 194.332 │ 288.651 │ 466.353 │         │          │ Float64  │
```

---
class: left, top

<div style="text-align:center"><img src="../2day-workshop/figures/xy-sleep.png" width="750"/></div>


Script para crear la figura en este [link](https://github.com/crsl4/julia-workshop/blob/main/2day-workshop/scripts/day2_1mixedmodels.jl).

---
class: left, top

### Model fit

```julia
julia> f1 =  @formula(reaction ~ 1 + days + (1+days|subj));

julia> m1 = fit(MixedModel, f1, sleepstudy)
Linear mixed model fit by maximum likelihood
 reaction ~ 1 + days + (1 + days | subj)
   logLik   -2 logLik     AIC       AICc        BIC    
  -875.9697  1751.9393  1763.9393  1764.4249  1783.0971

Variance components:
            Column   Variance Std.Dev.   Corr.
subj     (Intercept)  565.5107 23.78047
         days          32.6821  5.71683 +0.08
Residual              654.9414 25.59182
 Number of obs: 180; levels of grouping factors: 18

  Fixed-effects parameters:
──────────────────────────────────────────────────
                Coef.  Std. Error      z  Pr(>|z|)
──────────────────────────────────────────────────
(Intercept)  251.405      6.63226  37.91    <1e-99
days          10.4673     1.50224   6.97    <1e-11
──────────────────────────────────────────────────
```

---
class: left, top


```julia
julia> ranefvals = DataFrame(only(raneftables(m1)))
18×3 DataFrame
│ Row │ subj   │ (Intercept) │ days      │
│     │ String │ Float64     │ Float64   │
├─────┼────────┼─────────────┼───────────┤
│ 1   │ S308   │ 2.81582     │ 9.07551   │
│ 2   │ S309   │ -40.0484    │ -8.64408  │
│ 3   │ S310   │ -38.4331    │ -5.5134   │
│ 4   │ S330   │ 22.8321     │ -4.65872  │
│ 5   │ S331   │ 21.5498     │ -2.94449  │
│ 6   │ S332   │ 8.81554     │ -0.235201 │
│ 7   │ S333   │ 16.4419     │ -0.158809 │
│ 8   │ S334   │ -6.99667    │ 1.03273   │
│ 9   │ S335   │ -1.03759    │ -10.5994  │
│ 10  │ S337   │ 34.6663     │ 8.63238   │
│ 11  │ S349   │ -24.558     │ 1.06438   │
│ 12  │ S350   │ -12.3345    │ 6.47168   │
│ 13  │ S351   │ 4.274       │ -2.95533  │
│ 14  │ S352   │ 20.6222     │ 3.56171   │
│ 15  │ S369   │ 3.25854     │ 0.871711  │
│ 16  │ S370   │ -24.7101    │ 4.6597    │
│ 17  │ S371   │ 0.723262    │ -0.971053 │
│ 18  │ S372   │ 12.1189     │ 1.3107    │
```

---
class: left, top

# Communicación con otros sistemas: Julia interoperability

[JuliaInterop](https://github.com/JuliaInterop)

![](pics/juliainterop.png)

**Note:** Both `RCall` and `PyCall` are written 100% julia

---
class: left, top

## RCall

[Documentacion](https://juliainterop.github.io/RCall.jl/stable/)


Cambiar entre julia y R:

```julia
julia> foo = 1
1

R> x <- $foo

R> x
[1] 1
```

---
class: left, top

`@rget` y `@rput` macros:

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

# Conclusiones

- Julia provee muchas ventajas para los programadores de Ciencias de Datos especialmente para los que están creando programas que necesitan ser eficientes y que se desea compartir con la comunidad científica
- Julia permite a los programadores escribir código eficiente y de buen rendimiento de manera fácil y evitando el two-language problem

1. Data tools:
  -  [Arrow.jl](https://github.com/JuliaData/Arrow.jl) estructura binaria que permite la transferencia de datos entre julia, R y python
  - [Tables.jl](https://github.com/JuliaData/Tables.jl)
  - [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl): [ideas](https://ahsmart.com/assets/pages/data-wrangling-with-data-frames-jl-cheat-sheet/DataFramesCheatSheet_v0.22_rev1.pdf) similar a `tidyverse`

2. Model fitting:
  - [MixedModels.jl](https://github.com/JuliaStats/MixedModels.jl): 100% julia package
  
---
class: left, top

# Conclusiones

3. Communicaciones con otros sistemas
  - [RCall.jl](https://github.com/JuliaInterop/RCall.jl): 100% julia package
  - [PyCall.jl](https://github.com/JuliaPy/PyCall.jl): 100% julia package

4. Package system
  - With Julia 1.6, precompilation is done when the package is added

5. Tuning performance
  - [Performance tips](https://docs.julialang.org/en/v1/manual/performance-tips/)
  - [Profiling](https://docs.julialang.org/en/v1/manual/profile/)
  
---
class: left, top

# Cuáles son las desventajas de Julia?

- Data visualization: no `ggplot2` aún
- Literate programming: no `knitr` aún
  - [Literate.jl](https://github.com/fredrikekre/Literate.jl)
  - [Weave.jl](https://github.com/JunoLab/Weave.jl))
  - Notebooks como [Jupyter](https://jupyter.org) y [Pluto.jl](https://github.com/fonsp/Pluto.jl) pueden ser usados
  
---
class: left, top

<div style="text-align:center"><img src="../lectures/pics/julia-logo.png" width="350"/></div>



# Preguntas?
