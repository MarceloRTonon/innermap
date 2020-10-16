innermap: development and benchmarking
================
Marcelo Tonon
16/10/2020

# A Development Journal

As the title spells out, here will be presented how the `innermap`
package was developed, showing how the different versions of the
functions presented in the package perfom. Until now, there were three
versions of the package, being that the second one was not published, as
we will explain futher. The third version is the current one, and it
uses only the `purrr` package. In the path of the development, I own a
lot to [Giuliano Sposito](https://github.com/giulsposito), and also to
my great sock friend [Pedro Cava](https://github.com/pedrocava), for
giving me advice in how to develop it better, and also for pointing to
the possibility of the better perfomance of a `seqApply`\[1\].
Obviously, all eventual mistakes are my own\!

Packages needed

``` r
library(purrr)
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library(microbenchmark)
library(plyr)
```

    ## ------------------------------------------------------------------------------

    ## You have loaded plyr after dplyr - this is likely to cause problems.
    ## If you need functions from both plyr and dplyr, please load plyr first, then dplyr:
    ## library(plyr); library(dplyr)

    ## ------------------------------------------------------------------------------

    ## 
    ## Attaching package: 'plyr'

    ## The following objects are masked from 'package:dplyr':
    ## 
    ##     arrange, count, desc, failwith, id, mutate, rename, summarise,
    ##     summarize

    ## The following object is masked from 'package:purrr':
    ## 
    ##     compact

``` r
library(rlang)
```

    ## 
    ## Attaching package: 'rlang'

    ## The following objects are masked from 'package:purrr':
    ## 
    ##     %@%, as_function, flatten, flatten_chr, flatten_dbl, flatten_int,
    ##     flatten_lgl, flatten_raw, invoke, list_along, modify, prepend,
    ##     splice

# The early, clumsy, approach to the problem.

The first version of `innermap` was structured in the following fashion:

``` r
innermap_V1 <- function(input, .f0, distance = 1){
  .output <- purrr::map2(c(1:(length(input)-distance)), c((1+distance):length(input)),
                  function(x1,x2) rlang::exec(.f0, input[[x1]], input[[x2]])
  )
  return(.output)
}
```

All the `innermap` function family was structured like this. As one can
notice, this version used the `rlang` package.

\# Changing due to feedbacks\!

The early version of the `innermap` package was nothing more then an
more abstracted form of the way I always used `map2` when working with
Input-Output Tables and Structural Decomposition Analysis. As I never
had received any feedback or criticism for that, I did not though of any
other way for doing this. When I published the package, I was then
presented, by pedrocava and giulsposito to the `dplyr::lead` function,
and so I created a new version of `innermap`:

``` r
innermap_V2 <- function(input, .f0, distance = 1){
  .output <- purrr::map2(input,
                         dplyr::lead(input, distance),
                         .f0
                         )[c(1:(length(input)-distance))]
  return(.output)
}
```

This version did not used `rlang::exec`, but used `dplyr::lead`.

### leadApply for atomic vectors

As said in README, the main motivation to create `innermap` was for
dealing with lists of matrices and data.frames. But for the sake of
simplicity\[2\], the first example I gave in the first publication of
the package was of `innermap` dealing with atomic vectors. Giuliano
Sposito then graciously
[appeared](https://twitter.com/gsposito/status/1316597825233465345?s=20)
and using benchmark said that for atomic vectors there was a better way:

``` r
leadApply <- function(input, .f0, distance =1){
  .f0(input,
      dplyr::lead(input, distance)
      )[1:(length(input)-distance)]
}
```

This is certainly true. Let’s compare how the three structures behave in
comparison:

``` r
inputVec <- 1:100000

innermap_dbl_V1  <- function(input, .f0, distance = 1){
  .output <- purrr::map2_dbl(c(1:(length(input)-distance)), c((1+distance):length(input)),
                  function(x1,x2) rlang::exec(.f0, input[[x1]], input[[x2]])
  )
  return(.output)
}

innermap_dbl_V2 <- function(input, .f0, distance = 1){
  .output <- purrr::map2_dbl(input,
                         dplyr::lead(input, distance),
                         .f0
                         )[c(1:(length(input)-distance))]
  return(.output)
}

microbenchmark(
  "innermap_dbl_V1" = {innermap_dbl_V1(inputVec, `+`, 5)},
  "innermap_dbl_V2" = {innermap_dbl_V2(inputVec, `+`, 5)},
  "leadApply" = {leadApply(inputVec, `+`, 5)},
  times =30
)
```

    ## Unit: microseconds
    ##             expr         min          lq        mean      median          uq
    ##  innermap_dbl_V1 1423252.601 1538556.102 1927850.434 2049706.101 2170268.101
    ##  innermap_dbl_V2  335935.702  354889.900  435371.324  428690.051  505641.601
    ##        leadApply     798.001    1021.401    1688.581    1321.101    1888.601
    ##          max neval
    ##  2420695.800    30
    ##   621687.900    30
    ##     5011.501    30

The desavantage of `leadApply` is that it does not support vectors or
formula in `.f0` as `innermap` does. But it does support anonymous
function. It must be said that it will return an error if the function
choosed returns an vector with length higher then 1.

``` r
inputVec2 <- 1:100


microbenchmark(
  "innermap_V1" = {innermap_V1(inputVec2, `+`, 20)},
  "innermap_V2" = {innermap_V2(inputVec2, `+`, 20)},
  times =30
)
```

    ## Unit: microseconds
    ##         expr      min       lq     mean   median       uq       max neval
    ##  innermap_V1 1301.301 1346.902 1904.161 1487.101 1720.901 12217.801    30
    ##  innermap_V2  626.001  815.701 1313.841 1068.701 1272.801  8529.701    30

As we can see giulsposito was right, and `leadApply` clearly perfoms way
better than `innermap_dbl_V1` or `innermap_dbl_V2`. We can see also that
`innermap_dbl_V2` perfomed significantly better than `innermap_dbl_V1`.
We can also see that all of them deliver the same result:

``` r
all.equal(innermap_dbl_V1(inputVec, `+`, 5),
          innermap_dbl_V2(inputVec, `+`, 5))
```

    ## [1] TRUE

``` r
all.equal(innermap_dbl_V1(inputVec, `+`, 5),
          leadApply(inputVec, `+`, 5))
```

    ## [1] TRUE

This holds for any suffix of `innermap` that takes an `atomic vector` as
input. But as we are going to see, this does not holds for a list of
matrices.

### Problems in a lead paradise

The *V2* of this problem was never published as the current one. This
was because of their worse perfomance relative to the their previous
version when operating a matrix.

Examples:

``` r
MatrixList <- ozone %>% plyr::alply(3)

microbenchmark("V1" = {innermap_V1(MatrixList, `/`, 3)},
               "V2" = {innermap_V2(MatrixList, `/`, 3)},
               times = 30)
```

    ## Unit: milliseconds
    ##  expr      min       lq     mean   median       uq      max neval
    ##    V1 1.306701 1.528801 2.177694 1.765651 2.462201 9.387701    30
    ##    V2 2.556301 3.186501 4.025328 3.783601 4.941301 6.716202    30

Cell by cell multiplication:

``` r
microbenchmark("V1" = {innermap_V1(MatrixList, `*`, 3)},
               "V2" = {innermap_V2(MatrixList, `*`, 3)},
               times = 30)
```

    ## Unit: milliseconds
    ##  expr      min       lq     mean   median       uq       max neval
    ##    V1 1.583701 1.787001 2.282301 2.075801 2.633101  4.468701    30
    ##    V2 2.627301 3.121400 3.969358 3.516901 4.645402 10.486501    30

Standard Matrix Multiplications

``` r
microbenchmark("V1" = {innermap_V1(MatrixList, crossprod, 3)},
               "V2" = {innermap_V2(MatrixList, crossprod, 3)},
               times = 30)
```

    ## Unit: milliseconds
    ##  expr      min       lq     mean   median       uq      max neval
    ##    V1 1.923300 2.063600 3.029758 2.397900 3.239201 9.229301    30
    ##    V2 2.650401 3.035702 3.706631 3.366301 3.962801 6.575902    30

``` r
microbenchmark("V1" = {innermap_V1(MatrixList, `+`, 3)},
               "V2" = {innermap_V2(MatrixList, `+`, 3)},
               times = 30)
```

    ## Unit: milliseconds
    ##  expr      min       lq     mean   median       uq       max neval
    ##    V1 1.402201 1.556802 4.362661 1.684951 2.013701 77.030301    30
    ##    V2 2.622301 3.027902 3.686074 3.509601 4.472901  6.304702    30

``` r
innermap_lgl_V1  <- function(input, .f0, distance = 1){
  .output <- purrr::map2_lgl(c(1:(length(input)-distance)), c((1+distance):length(input)),
                  function(x1,x2) rlang::exec(.f0, input[[x1]], input[[x2]])
  )
  return(.output)
}

innermap_lgl_V2 <- function(input, .f0, distance = 1){
  .output <- purrr::map2_lgl(input,
                         dplyr::lead(input, distance),
                         .f0
                         )[c(1:(length(input)-distance))]
  return(.output)
}


microbenchmark("V1" = {innermap_lgl_V1(MatrixList, identical, 3)},
               "V2" = {innermap_lgl_V2(MatrixList, identical, 3)},
               times = 30)
```

    ## Unit: milliseconds
    ##  expr      min       lq     mean   median       uq       max neval
    ##    V1 1.368701 1.765301 2.398498 1.904201 2.215502 12.996101    30
    ##    V2 2.177601 2.536201 3.245624 2.867951 3.163701  9.914901    30

## A base-R subsetting structure (The current structure)

In this version I took away `lead` in favour of a base-r solution for
the subsetting of the lists. This was also another one of the [Giuliano
Sposito’s
recomendations](https://twitter.com/gsposito/status/1316599096833118208?s=20).
This structure was then like this:

``` r
innermap_V3 <- function(input, .f0, distance = 1){
  .output <- purrr::map2(input[c(1:(length(input)-distance))],
                         input[c((1+distance):length(input))],
                         .f0)
  return(.output)
}
```

The perfomance of this structure compared to the formers:

``` r
microbenchmark("V1" = {innermap_V1(MatrixList, `/`, 3)},
               "V2" = {innermap_V2(MatrixList, `/`, 3)},
               "V3" = {innermap_V3(MatrixList, `/`, 3)},
               times = 30)
```

    ## Unit: microseconds
    ##  expr      min       lq     mean   median       uq       max neval
    ##    V1 1507.501 1751.800 2403.181 2021.001 2650.501  7588.002    30
    ##    V2 2585.701 3234.100 3739.831 3575.151 4362.301  5374.301    30
    ##    V3  959.501 1190.701 1789.254 1384.251 1594.701 10095.301    30

``` r
microbenchmark("V1" = {innermap_V1(MatrixList, crossprod, 3)},
               "V2" = {innermap_V2(MatrixList, crossprod, 3)},
               "V3" = {innermap_V3(MatrixList, crossprod, 3)},
               times = 30)
```

    ## Unit: milliseconds
    ##  expr      min       lq     mean   median       uq       max neval
    ##    V1 2.050002 2.371101 2.878371 2.626851 2.995701  5.346401    30
    ##    V2 2.683101 3.031101 3.945448 3.518251 4.185100 11.647701    30
    ##    V3 1.019101 1.258400 1.383681 1.336951 1.504101  2.075501    30

``` r
microbenchmark("V1" = {innermap_V1(MatrixList, `+`)},
               "V2" = {innermap_V2(MatrixList, `+`)},
               "V3" = {innermap_V3(MatrixList, `+`)},
               times = 30)
```

    ## Unit: microseconds
    ##  expr      min       lq     mean   median       uq      max neval
    ##    V1 1348.301 1523.801 1827.788 1737.202 1885.602 3069.801    30
    ##    V2 2408.702 2896.701 3295.241 3285.651 3550.601 4451.801    30
    ##    V3  789.301 1052.502 1323.238 1198.901 1392.501 4427.201    30

``` r
innermap_lgl_V3 <- function(input, .f0, distance = 1){
  .output <- purrr::map2_lgl(input[c(1:(length(input)-distance))],
                         input[c((1+distance):length(input))],
                         .f0)
  return(.output)
}


microbenchmark("V1" = {innermap_lgl_V1(MatrixList, identical, 1)},
               "V2" = {innermap_lgl_V2(MatrixList, identical, 1)},
               "V3" = {innermap_lgl_V3(MatrixList, identical, 1)},
               times = 30)
```

    ## Unit: microseconds
    ##  expr      min       lq      mean   median       uq      max neval
    ##    V1 1456.701 1618.501 1874.4676 1737.101 2031.301 3222.601    30
    ##    V2 2240.200 2433.701 3187.8710 2781.301 3549.900 6859.901    30
    ##    V3  478.601  550.600  939.4709  642.551  736.101 9130.701    30

These improvements happened because of three things:

. The structure of `V1` used the lengths of the `input` as `.x` e `.y`
in `map2()` and subsetted `input` inside the `rlang::exec`. Now is the
input itself that is used. In the end, `V3` has a similar structure of
`V2`, **but**; . `V2` uses `dplyr::lead` instead of `baser`, that is
what `V3` uses. The difference in perfomance is apparent when we deal
with lists:

``` r
exampleDist <- 2

microbenchmark(
"lead" = ({lead(MatrixList, exampleDist)}),
"baseR"= MatrixList[c((1+exampleDist):length(MatrixList))]
)
```

    ## Unit: microseconds
    ##   expr      min        lq       mean   median        uq      max neval
    ##   lead 1340.601 1623.2015 2042.02910 1875.051 2220.0505 6411.701   100
    ##  baseR   17.500   22.1505   35.59499   31.701   39.4015  124.401   100

. `innermap_V2(input, .f0, distance)` runs `map2` a total of
`length(input)` times and then subset it with
`[c(1:(length(input)-distance))]`. The total of times
`innermap_V3(input, .f0, distance)` runs `map2` equals `length(input) -
distance`. This happens because `dplyr::lead(input)` keep the same
length of `input` while `innermap_V3` modifies the lenght of `input` as
it serves as `.x` and `.y` parameter for `map2`.

### Retiring leadApply

We have retired `leadApply` and transformed it in \`innerApply\`\`,
since the latter perfoms way better.

``` r
innerApply <- function(input, .f0, distance =1){
  .f0(input[c(1:(length(input)-distance))],
      input[c((1+distance):length(input))]
      )
}

microbenchmark(
  "leadApply" = {leadApply(inputVec, `+`, 5)},
  "innerApply" = {innerApply(inputVec, `+`, 5)},
  times =30
)
```

    ## Unit: milliseconds
    ##        expr      min       lq     mean   median       uq     max neval
    ##   leadApply 1.017001 1.573701 2.220898 1.766201 2.292801 11.0912    30
    ##  innerApply 3.072501 3.613001 4.836614 4.208151 5.132701 12.7491    30

## Whats next?

Well, for now not that much. Test in the future use `as_mapper` directly
and see if we gain more perfomance in this matter. Writing C/C++ is not
in my plans. I also want to focus in other packages that would help
Input Output Analysis (Structural Decomposition in special) in R.

1.  The function Giuliano Sposito proposed was called `leadApply` since
    it used the function `dplyr::lead`, but as the base R function
    perfom better, made no sense to called `leadApply`. **Important** to
    say that he also said that moving to a base-R structure would have a
    better perfomance.

2.  Also, no idea for an simple matrix example came to mind at that
    moment.
