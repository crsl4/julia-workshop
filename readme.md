# Welcome to the Julia workshop for Data Science

This repository contains the material for the "Julia workshop for Data Science" taught at the ISMB 2022 conference on July 10th, 2022.

  - Welcome to the Julia workshop for Data Science!
  - The goal for the workshop is to highlight the main features that make Julia an attractive option for data science programmers
  - The workshop is intended for any data scientist with experience in R and/or python who is interested in learning the attractive features of Julia for Data Science. No knowledge of Julia is required.
  - Workshop materials in the github repository [julia-workshop](https://github.com/crsl4/julia-workshop)

## Learning Objectives for Tutorial

At the end of the tutorial, participants will be able to:

  - Identify the main features that make Julia an attractive language for Data Science
  - Set up a Julia environment to run their data analysis
  - Efficiently handle datasets (even across different languages) through Tables.jl and Arrow.jl
  - Fit (generalized) linear mixed models with MixedModels.jl
  - Communicate across languages (Julia, R, python)

Intended audience and level:
The tutorial is intended for any data scientist with experience in R and/or python who is interested in learning the attractive features of Julia for Data Science. No knowledge of Julia is required.

# Schedule

| Time          | Topic                                                                     | Presenter                    |
|:-------------:|:-------------------------------------------------------------------------:|:----------------------------:|
| 11:00 - 11:30 | [Session 1: Get Started with Julia](session1-get-started.qmd)             | Claudia Solis-Lemus          |
| 11:30 - 12:30 | [Session 2a: Data Tables and Arrow files](session2a-tables-and-arrow.qmd) | Douglas Bates                |
| 12:30 - 1:00  | [Session 2b: Interval Overlap](session2b-interval-overlap.qmd)            | Douglas Bates                |
| 1:00 - 2:00   | Lunch break                                                               |                              |
| 2:00 - 3:00   | Session 3: Model fitting                                                  |                              |
| 3:00 - 4:00   | [Session 4: Hands-on exercise](session4-exercise.qmd)                     | Sam Ozminkowski and Bella Wu |
| 4:00 - 4:15   | Coffee break                                                              |                              |
| 4:15 - 5:00   | Presentation of selected participants' scripts and Q&A                    |                              |
| 5:00 - 5:30   | [Session 5: Other important Data Science tools](session5-other-tools.qmd) | Claudia Solis-Lemus          |
| 5:30 - 6:00   | [Session 6: Conclusions and questions](session6-conclusions.qmd)          | Claudia Solis-Lemus          |

# In preparation for the workshop

Participants are required to follow the next steps before the day of the workshop:

 1. Git clone the workshop repository: `git clone https://github.com/crsl4/julia-workshop.git`

 2. Install Julia. The recommended option is to use [JuliaUp](https://github.com/JuliaLang/juliaup):

  - Windows: `winget install julia -s msstore`

  - Mac and Linux: `curl -fsSL https://install.julialang.org | sh`
  - Homebrew users: `brew install juliaup`

After JuliaUp is installed, you can install different Julia versions with:

```shell
juliaup add release  ## installs release version
juliaup add rc     ## installs rc version
juliaup st           ## status of julia versions installed
juliaup default rc ## making beta version the default
```

 3. Choose a dataset along with a script to analyze it written in another language (R or python) as we will spend part of the workshop translating participants' scripts to Julia.

# Want to learn more?

Checkout the great resources in [Julia learning](https://julialang.org/learning/).

# Previous versions of workshops

  - This "WID Julia workshop" release contains the notes of the Julia workshop taught at the WID Data Science Research Bazaar on February 10th, 2021.
  - The "CIMAT workshop" release contains the notes of the Julia workshop taught at CIMAT in October 26-27, 2020.
