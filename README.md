# rjsf

<!-- badges: start -->
<!-- badges: end -->

`rjsf` provides an R interface to the Python `jsf` package for Jump-Switch-Flow simulation.

The main function is `jsf_simulate()`, which lets users define compartmental reaction models in R, call the Python `jsf` backend through `reticulate`, and return simulation output as either a regular `data.frame` or a structured `JSFResult` object.

## Installation

You can install the development version of `rjsf` from GitHub with:

```r
# install.packages("pak")
pak::pak("olivervu25/rjsf")
```

## Python setup

`rjsf` uses `reticulate` to call the Python `jsf` package. This means Python `jsf` must be installed in the same Python environment that `reticulate` is using.

A recommended setup is to create a local virtual environment:

```bash
python3 -m venv .venv
source .venv/bin/activate

python -m pip install --upgrade pip setuptools wheel
python -m pip install numpy scipy pandas matplotlib python-libsbml
python -m pip install git+https://github.com/DGermano8/jsf.git
```

Then in R, point `reticulate` to that environment:

```r
Sys.setenv(RETICULATE_PYTHON = ".venv/bin/python")

library(reticulate)
py_config()
```

Check that Python `jsf` is available:

```r
library(rjsf)

jsf_available()
```

This should return:

```r
[1] TRUE
```

## Alternative setup using reticulate

You can also install the Python dependencies from R using `reticulate`:

```r
library(reticulate)

virtualenv_create("rjsf-env")

py_install(
  packages = c("numpy", "scipy", "pandas", "matplotlib", "python-libsbml"),
  envname = "rjsf-env",
  method = "virtualenv"
)

py_install(
  packages = "git+https://github.com/DGermano8/jsf.git",
  envname = "rjsf-env",
  method = "virtualenv",
  pip = TRUE
)

use_virtualenv("rjsf-env", required = TRUE)
```

Then check:

```r
library(rjsf)

jsf_available()
```

## Quick example

```r
library(rjsf)
library(reticulate)

rates_lv <- reticulate::py_eval(
  "lambda x, t: [2.0 * x[0], 1.5 * x[1], 0.05 * x[0] * x[1]]"
)

result <- jsf_simulate(
  x0 = c(prey = 50, predator = 10),
  rates = rates_lv,
  reactant = matrix(
    c(
      1, 0,
      0, 1,
      1, 1
    ),
    ncol = 2,
    byrow = TRUE
  ),
  product = matrix(
    c(
      2, 0,
      0, 0,
      0, 2
    ),
    ncol = 2,
    byrow = TRUE
  ),
  do_disc = c(1, 1),
  t_max = 10,
  dt = 0.01,
  switching_threshold = c(30, 30),
  species_names = c("prey", "predator"),
  return_type = "JSFResult"
)

result
summary(result)
plot(result)
```

## Output types

`jsf_simulate()` can return either a regular data frame:

```r
df <- jsf_simulate(..., return_type = "data.frame")
```

or a structured `JSFResult` object:

```r
result <- jsf_simulate(..., return_type = "JSFResult")
```

A `JSFResult` stores simulation trajectories and metadata, and supports:

```r
print(result)
summary(result)
plot(result)
```

## Vignettes

See the getting started vignette for full Lotka-Volterra and SIR examples.