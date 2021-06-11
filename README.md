
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gdistanceR

<!-- badges: start -->
<!-- badges: end -->

The goal of gdistanceR is to interact with the Google Distance MAtrix
API.

## Installation

<!--You can install the released version of gdistanceR from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("gdistanceR")
```-->

Install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("Shaunson26/gdistanceR")
```

## Example

``` r
library(gdistanceR)
```

``` r
# Return least formatted object from the API call - JSON to list
rs <- get_distances(origins = 'Liverpool 2170',
                    destinations = 'St Leonards 2065')

# Wrangle into a data.frame
wrs <- wrangle_distances(rs)

wrs
#> # A tibble: 1 x 7
#>   origin    destination   depature_time       distance duration duration_in_tra~
#>   <chr>     <chr>         <dttm>                 <dbl>    <dbl>            <dbl>
#> 1 Liverpoo~ St Leonards ~ 2021-06-11 11:12:36     44.9     38.9             40.0
#> # ... with 1 more variable: status <chr>
```

``` r
# Return least formatted object from the API call - JSON to list
rs_multi <- get_distances(origins = c('298 Macquarie St Liverpool 2170', 'Campbelltown 2560'),
                    destinations = '1 Reserve Road Leonards 2065')

# Wrangle into a data.frame
wrs_multi <- wrangle_distances(rs_multi)

wrs_multi
#> # A tibble: 2 x 7
#>   origin    destination   depature_time       distance duration duration_in_tra~
#>   <chr>     <chr>         <dttm>                 <dbl>    <dbl>            <dbl>
#> 1 298 Macq~ 1 Reserve Rd~ 2021-06-11 11:12:37     45.7     41.6             43.0
#> 2 Campbell~ 1 Reserve Rd~ 2021-06-11 11:12:37     62.9     52.1             53.8
#> # ... with 1 more variable: status <chr>
```
