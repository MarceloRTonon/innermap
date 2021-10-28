
<!-- README.md is generated from README.Rmd. Please edit that file -->

# innermap

<!-- badges: start -->
<!-- badges: end -->

The `innermap` package presents the `innermap` family functions. These
in turn, allow the use of map family function but using elements of the
same vectors. This is not the same thing of `purrr::accumulate`
function, since it does not uses any output made by the function in the
process. Now, we also present 2 `bimap` (bilinear map) functions, that
extend the same functionality of `purrr::map_depth` for `map2`.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("MarceloRTonon/innermap")
```

# The innermap function

## Example

``` r
library(innermap)
library(purrr)
```

Bellow we offer a simple example. Important to notice that when dealing
with atomic vectors one could use `apply` instead of `purrr` functions,
however, the latter offer a greater flexebility with the inputs,
specially when dealing with nested lists which the last elements have
`matrix` class.

``` r
inputList <- c(1:30) |>
  as.list() |>
  purrr::map(rep, 9) |>
  purrr::map(matrix, nrow = 3, ncol =3)
```

Now suppose you want to sum every matrix of the `inputLest` with the
following one. Using `base R`, a intuitive way of doing this is through
`for` (we discuss in other possibilities using `base R`):

``` r
#1: For Method
outputListFor <- list()

for(i in 1:(length(inputList)-1)){
  outputListFor[[i]] <- inputList[[i]] + inputList[[i+1]]
}
```

Howver using `for` in R is neither very optimized or a good practice. In
this sense, the `innermap` function family produce strong elements

``` r
outputList <- innermap::innermap(inputList, function(x,y) x+y)

all.equal(outputList, outputListFor)
#> [1] TRUE
```

### Changing the distance between the elements used

In this case, we used each element with the following one, **but** we
can also use it with different distances, using the argument `distance`.
Supposing we want to multiply the `n` element with the `n+2` element we
can do:

``` r
outputList <- innermap::innermap(inputList, distance =2, function(x,y) x+y)
```

The default value for the `distance` argument 1.

## The simple inner structure of innermap

### Comparing with Alternate methods

We could however use `lapply`, using two methods. The first is creating
a list containing indexes of `.x` and `.y`:

``` r
# 2_a: Lapply Index Method
outputList <- list(.x = as.list(c(1:(length(inputList)-1))),
                   .y = as.list(c(2:length(inputList)))) |>
                     purrr::transpose() |>
                     lapply(FUN = function(.index) inputList[[.index$.x]]+inputList[[.index$.y]])
```

Another way is to attribute directly the variables in the list:

``` r
# 2_b: Lapply Subset Method
outputList <- list(.x = inputList[c(1:(length(inputList)-1))],
                          .y = inputList[c(2:length(inputList))]) |>
  purrr::transpose() |>
  lapply(FUN = function(.input) .input$.x+ .input$.y)
```

It is possible to do this using the `purrr` package by, at least, four
ways: 2 using `map` and 2 using `map2`. As for `lapply`, we can use an
*Index Method*, where the indexes are given as `.x` and `.y` parameters
for `map` and `map2`, and the input vector is given inside the function
in the `.f` argument:

``` r
#3_a Purrr::map Index Method
outputList <- list(as.list(c(1:(length(inputList)-1))),
                   as.list(c(2:length(inputList)))) |>
  purrr::transpose() |>
  map(.f = function(x) inputList[[x[[1]]]]+ inputList[[x[[2]]]])



#4_a: Purrr::map2 Index Method
outputList <- purrr::map2(.x = c(1:(length(inputList)-1)),
                     .y = c(2:length(inputList)),
                     .f = function(x,y) inputList[[x]] + inputList[[y]])
```

The second can be through subsetting the

``` r
#3_b: purrr::map Subset Method with purrr::reduce
outputList <- list(.x = inputList[c(1:(length(inputList)-1))],
                          .y = inputList[c(2:length(inputList))]) |>
  purrr::transpose() |>
  map(.f = reduce, `+`)


#4_b: Purrr::map2 Subset Method
outputList <- purrr::map2(.x = inputList[c(1:(length(inputList)-1))],
                          .y = inputList[c(2:length(inputList))],
                          .f = `+`)
```

To say the truth when using `map`, there is another choice to be made:
using `purrr::reduce` or not. There is consequence in using it, as we
shall discuss latter. Bellow we present a tabble using the
`microbenchmark` package. The code for the benchmark can be seen in the
end of this document

    #> Unit: microseconds
    #>                expr      min        lq       mean    median        uq       max
    #>               1_For 3777.086 4185.7280 5190.52915 4518.9050 5322.4295 16073.342
    #>      2a_lapplyIndex   55.314   67.9905   98.16749   74.1365   92.1205  1727.175
    #>     2a2_lapplyIndex   65.302   74.9390  112.14202   84.9615   98.8255  2156.909
    #>     2b_lapplySubset   44.279   53.8825  104.65361   60.6920   80.7015  3619.664
    #>    2b2_lapplySubset   56.571   63.9740   92.21349   72.8445   87.0920  1433.842
    #>         3a_mapIndex   58.667   70.4000  110.02377   80.1085  102.1780  2019.391
    #>   3aReduce_mapIndex 4226.026 4632.3275 5654.94700 4921.5400 5736.3440 13627.500
    #>        3b_mapSubset   47.911   61.1455   97.14358   69.7720   92.5395  1724.940
    #>       3b2_mapSubset   58.527   70.1900  133.87722   81.4005  100.5710  3090.546
    #>  3bReduce_mapSubset 4180.839 4450.8795 5570.84416 4787.2355 5639.0900 15734.611
    #>        4a_map2Index   56.781   68.1305   98.94976   74.4510   90.2000  1657.892
    #>       4a2_map2Index   67.676   79.2350  119.44604   89.9905  104.2725  2374.604
    #>       4b_map2Subset  210.153  228.5560  297.44144  256.8765  340.1970   710.426
    #>            innermap  211.549  231.3490  323.47337  272.4860  357.4475  2404.007
    #>  neval
    #>    100
    #>    100
    #>    100
    #>    100
    #>    100
    #>    100
    #>    100
    #>    100
    #>    100
    #>    100
    #>    100
    #>    100
    #>    100
    #>    100

From the table above we can draw some pretty sweet conclusions: - Using
`for` is very ineficient. - Using `reduce` inside `purrr::map` is also
very ineficient (even more than for) - lapply

But one can easily argue that writing explicitly the lengths of the
vector in the arguments is at least very anoying, when very confusing to
read. The `innermap` approach do the same thing that was done in the
example prior, but in the backstage. Let’s use `innermap_dbl` in this
example:

It is undoubtely more pratical to do this than it is to do the former
way. This also allows you to be even more pratical:

``` r
outputVec <- innermap::innermap_dbl(inputVec, sum)
outputVec <- innermap::innermap_dbl(inputVec, `+`)
```

# A whole family

We used until now the `innermap_dbl` function, but in the same way we
have `map`, `map_lgl`, `map_chr`,`map_int`, `map_raw`, `map_dfr`,
`map_dfc` there is a `innermap`, `innermap_lgl`,
`innermap_chr`,`innermap_int`, `innermap_dbl`, `innermap_raw`,
`innermap_dfr`, `innermap_dfc`.

## Motivation

There is no native function in `purrr` that takes elements of the same
vector or list and applies a function to them. As a researcher in the
field of Structural Decomposition Analysis (SDA), I use a purrr::map
quite often, and need quite often functions like the ones from
`innermap` family. Since the Input-Output tables are quite heavy, there
is no way one can give up the use of the optimized `purrr` functions.
Also, the SDA methodology needs as input the original matrix, making
functions like `accumulate` not suited for this.

I hope other will find this useful too! Really hope to receive comments
about it!

# Appendix

## microbenchmark Code

We display below the code used to generate the microbenchmark of the
options

``` r
library(microbenchmark)

microbenchmark::microbenchmark(

    "1_For" = {outputList <- list()
    for(i in 1:(length(inputList)-1)){
  outputList[[i]] <- inputList[[i]] + inputList[[i+1]]
}},

  "2a_lapplyIndex" = {list(.x = as.list(c(1:(length(inputList)-1))),
                   .y = as.list(c(2:length(inputList)))) |>
                     purrr::transpose() |>
                     lapply(FUN = function(.index) inputList[[.index$.x]]+inputList[[.index$.y]])},

  "2b_lapplySubset" = { list(.x = inputList[c(1:(length(inputList)-1))],
                          .y = inputList[c(2:length(inputList))]) |>
  purrr::transpose() |>
  lapply(FUN = function(.input) .input$.x+ .input$.y)},

  "3a1_mapIndex" = {list(as.list(c(1:(length(inputList)-1))),
                   as.list(c(2:length(inputList)))) |>
  purrr::transpose() |>
  map(.f = function(x) inputList[[x[[1]]]]+ inputList[[x[[2]]]])},
 
  "3aReduce_mapIndex" = { {list(as.list(c(1:(length(inputList)-1))),
                   as.list(c(2:length(inputList)))) |>
  purrr::transpose() |>
  map(.f = function(.index)purrr::reduce(list(inputList[[.index[[1]]]],
                                              inputList[[.index[[2]]]]),
                                         `+`))}},
  "3b_mapSubset" = {list(.x = inputList[c(1:(length(inputList)-1))],
                          .y = inputList[c(2:length(inputList))]) |>
  purrr::transpose() |>
  map(.f = function(x) x[[1]]+x[[2]])},
  "3bReduce_mapSubset" = {list(.x = inputList[c(1:(length(inputList)-1))],
                          .y = inputList[c(2:length(inputList))]) |>
  purrr::transpose() |>
  map(.f = reduce, `+`)},

  "4a_map2Index" = {purrr::map2(.x = c(1:(length(inputList)-1)),
                     .y = c(2:length(inputList)),
                     .f = function(x,y) inputList[[x]] + inputList[[y]])},

  "4b_map2Subset" = {purrr::map2(.x = inputList[c(1:(length(inputList)-1))],
                          .y = inputList[c(2:length(inputList))],
                          .f = `+`)},

"innermap" = innermap::innermap(inputList, .f0 = `+`),
 times= 100L
)
```

# Thanks

Big thanks to [pedroocava](https://github.com/pedrocava/) and
[kimjoaoun](https://github.com/kimjoaoun/) for their early comments on
this matter. Any mistakes are my own.

These functions were much improved by the feedback and suggestions of
[Giuliano Sposito](https://github.com/giulsposito).

# Important to note

As I am an Economics PhD Student, I do not have the time, nor the
skills, to make a hardcore low level coding in C++ to create super fast
functions as is in the `purrr` package. Nonetheless, I still think this
functions I presented perfom quite well, since I kept them simple and
based in the `purrr` package. I already set an
[issue](https://github.com/tidyverse/purrr/issues/797#issue-721645404)
in the `purrr` Github repository today. If they add this feature in the
`purrr` package, **what I hope they do**, I will not take this project
forward or update it in anyway.
