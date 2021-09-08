
<!-- README.md is generated from README.Rmd. Please edit that file -->

-----

# kaggler <img src="man/figures/logo.png" width="160px" align="right" />

> 🏁 An R client for accessing [Kaggle](https://www.kaggle.com)’s API

<!-- badges: start -->

[![R-CMD-check](https://github.com/KoderKow/kaggler/workflows/R-CMD-check/badge.svg)](https://github.com/KoderKow/kaggler/actions)
<!-- badges: end -->

## Installation

You can install the dev version of **{kaggler}** from
[CRAN](https://github.com/koderkow/kaggler) with:

``` r
## install kaggler package from github
devtools::install_packages("koderkow/kaggler")
```

# API Authorization

All users must be authenticated to interact with Kaggle’s APIs. To setup
your API key refer to the [Get
Started](https://koderkow.github.io/kaggler/articles/kaggler.html)
guide.

# Kaggle Flow

This is an **experimental** and **opinionated** reproducible workflow
for working with Kaggle competitions.

``` r
library(kaggler)

kgl_flow("titanic")

#> • These files will be downloaded:
#>   - 'gender_submission'
#>   - 'test'
#>   - 'train'.
#> • Downloading 'gender_submission.csv'...
#> • Downloading 'test.csv'...
#> • Downloading 'train.csv'...
```

For a more in-depth walkthrough visit the [Kaggle
Flow](https://koderkow.github.io/kaggler/articles/kgl-flow.html) page.

# Direct API Interaction

These will be functions the user can call to have custom control over
the returns and interactions with the API, similar to Kaggle’s python
API.

Browse or search for Kaggle competitions.

``` r
## look through all competitions (paginated)
comps1 <- kgl_competitions_list()
comps1
#> # A tibble: 20 x 23
#>      id ref     title     url      description     organization_na… organization_ref category reward
#>   <int> <chr>   <chr>     <chr>    <chr>           <chr>            <chr>            <chr>    <chr> 
#> 1 21733 contra… Contradi… https:/… Detecting cont… Kaggle           kaggle           Getting… Prizes
#> 2 21755 gan-ge… I’m Some… https:/… Use GANs to cr… Kaggle           kaggle           Getting… Prizes
#> 3 21154 tpu-ge… Petals t… https:/… Getting Starte… Kaggle           kaggle           Getting… Knowl…
#> 4  3004 digit-… Digit Re… https:/… Learn computer… Kaggle           kaggle           Getting… Knowl…
#> 5  3136 titanic Titanic … https:/… Start here! Pr… Kaggle           kaggle           Getting… Knowl…
#> # … with 15 more rows, and 14 more variables: deadline <dttm>, kernel_count <int>,
#> #   team_count <int>, user_has_entered <lgl>, user_rank <lgl>, merger_deadline <dttm>,
#> #   new_entrant_deadline <dttm>, enabled_date <dttm>, max_daily_submissions <int>,
#> #   max_team_size <int>, evaluation_metric <chr>, awards_points <lgl>,
#> #   is_kernels_submissions_only <lgl>, submissions_disabled <lgl>

## it's paginated, so to see page two:
comps2 <- kgl_competitions_list(page = 2)
comps2
#> # A tibble: 20 x 23
#>      id ref     title    url       description    organization_name organization_ref category reward
#>   <int> <chr>   <chr>    <chr>     <chr>          <chr>             <chr>            <chr>    <chr> 
#> 1 23304 jane-s… Jane St… https://… "Test your mo… Jane Street Group jane-street-gro… Featured $100,…
#> 2 23652 seti-b… SETI Br… https://… "Find extrate… Berkeley SETI Re… berkeleyseti     Research $15,0…
#> 3 25401 hungry… Hungry … https://… "Don't. Stop.… Kaggle            kaggle           Playgro… Prizes
#> 4 26680 siim-c… SIIM-FI… https://… "Identify and… Society for Imag… siim             Featured $100,…
#> 5 26933 google… Google … https://… "Improve high… Google            google           Research $10,0…
#> # … with 15 more rows, and 14 more variables: deadline <dttm>, kernel_count <int>,
#> #   team_count <int>, user_has_entered <lgl>, user_rank <lgl>, merger_deadline <dttm>,
#> #   new_entrant_deadline <dttm>, enabled_date <dttm>, max_daily_submissions <int>,
#> #   max_team_size <int>, evaluation_metric <chr>, awards_points <lgl>,
#> #   is_kernels_submissions_only <lgl>, submissions_disabled <lgl>

## search by keyword for competitions
imagecomps <- kgl_competitions_list(search = "image")
imagecomps
#> # A tibble: 20 x 23
#>      id ref      title    url      description     organization_na… organization_ref category reward
#>   <int> <chr>    <chr>    <chr>    <chr>           <chr>            <chr>            <chr>    <chr> 
#> 1 29761 landmar… Google … https:/… Given an image… Google           google           Research Swag  
#> 2 19991 alaska2… ALASKA2… https:/… Detect secret … Troyes Universi… UTT              Research $25,0…
#> 3 10418 human-p… Human P… https:/… Classify subce… Human Protein A… human-protein-a… Featured $37,0…
#> 4 14420 recursi… Recursi… https:/… CellSignal: Di… Recursion Pharm… recursionpharma  Research $13,0…
#> 5  6927 carvana… Carvana… https:/… Automatically … Carvana          carvana          Featured $25,0…
#> # … with 15 more rows, and 14 more variables: deadline <dttm>, kernel_count <int>,
#> #   team_count <int>, user_has_entered <lgl>, user_rank <lgl>, merger_deadline <dttm>,
#> #   new_entrant_deadline <dttm>, enabled_date <dttm>, max_daily_submissions <int>,
#> #   max_team_size <int>, evaluation_metric <chr>, awards_points <lgl>,
#> #   is_kernels_submissions_only <lgl>, submissions_disabled <lgl>
```

You can look up the datalist for a given Kaggle competition using the
API.

``` r
## data list for a given competition
c1_datalist <- kgl_competitions_data_list(comps1$ref[1])
c1_datalist
#> # A tibble: 3 × 7
#>   id                           ref                   name  description total_bytes url   creation_date      
#>   <chr>                        <chr>                 <chr> <lgl>             <int> <chr> <dttm>             
#> 1 contradictory-my-dear-watson test.csv              test… NA              1180141 http… 2020-07-27 19:45:43
#> 2 contradictory-my-dear-watson train.csv             trai… NA              2771659 http… 2020-07-27 19:45:43
#> 3 contradictory-my-dear-watson sample_submission.csv samp… NA                67549 http… 2020-07-27 19:45:43
```

For a more in-depth walkthrough visit the [Kaggle
API](https://koderkow.github.io/kaggler/articles/kaggle-api.html) page.

## Note(s)

  - The base of this package was cloned from the original at
    [{kaggler}](https://github.com/mkearney/kaggler). I have decided to
    take the developers work and continue their amazing development\!
    Major props and recognition goes out to the original developer(s) of
    this package.
      - I will be updating all documentation and examples for the README
        and functions for this package as time goes on
  - The the developers are in no way affiliated with Kaggle.com, and, as
    such, makes no assurances that there won’t be breaking changes to
    the API at any time
  - Although the developers are not affiliated, it’s good practice to be
    informed, so here is the link to Kaggle’s terms of service:
    <https://www.kaggle.com/terms>
