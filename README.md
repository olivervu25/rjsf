
# rjsf

<!-- badges: start -->
<!-- badges: end -->

The goal of rjsf is to ...

## Installation

You can install the development version of rjsf from [GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("olivervu25/rjsf")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(rjsf)
## basic example code
```

## Setup

1. Install `reticulate`
2. `py_install(c("python-libsbml", "numpy", "ipykernel"))`
3. `py_install(
    "git+https://github.com/DGermano8/jsf.git",
    method = "virtualenv",
    pip = TRUE
    )`
4. `jsf_available()` should return `TRUE`

