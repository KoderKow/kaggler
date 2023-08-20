
<!-- README.md is generated from README.Rmd. Please edit that file -->

------------------------------------------------------------------------

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
devtools::install_github("koderkow/kaggler")
```

# API Authorization

All users must be authenticated to interact with Kaggle’s APIs. To setup
your API key refer to the [Get
Started](https://koderkow.github.io/kaggler/articles/kaggler.html)
guide.

# Interacting with the API

These will be functions the user can call to have custom control over
the returns and interactions with the Kaggle API.

Browse or search for Kaggle competitions.

``` r
## look through all competitions (paginated)
comps1 <- kgl_competitions_list()
comps1
#> # A tibble: 40 × 42
#>   title_nullable          url_nullable description_nullable organization_name_nu…¹ category_nullable
#>   <chr>                   <chr>        <chr>                <chr>                  <chr>            
#> 1 Google - American Sign… https://www… Train fast and accu… Google                 Research         
#> 2 CommonLit - Evaluate S… https://www… Automatically asses… The Learning Agency L… Featured         
#> 3 CommonLit - Evaluate S… https://www… Automatically asses… The Learning Agency L… Featured         
#> 4 CommonLit - Evaluate S… https://www… Automatically asses… The Learning Agency L… Featured         
#> 5 Bengali.AI Speech Reco… https://www… Recognize Bengali s… Bengali.AI             Research         
#> # ℹ 35 more rows
#> # ℹ abbreviated name: ¹​organization_name_nullable
#> # ℹ 37 more variables: reward_nullable <chr>, max_team_size_nullable <int>,
#> #   evaluation_metric_nullable <chr>, id <int>, ref <chr>, title <chr>, has_title <lgl>, url <chr>,
#> #   has_url <lgl>, description <chr>, has_description <lgl>, organization_name <chr>,
#> #   has_organization_name <lgl>, organization_ref <lgl>, has_organization_ref <lgl>,
#> #   category <chr>, has_category <lgl>, reward <chr>, has_reward <lgl>, tags <list>, …

## search by keyword for competitions
imagecomps <- kgl_competitions_list(search = "image")
imagecomps
#> # A tibble: 9 × 42
#>   title_nullable          url_nullable description_nullable organization_name_nu…¹ category_nullable
#>   <chr>                   <chr>        <chr>                <chr>                  <chr>            
#> 1 RSNA 2023 Abdominal Tr… https://www… Detect and classify… Radiological Society … Featured         
#> 2 RSNA 2023 Abdominal Tr… https://www… Detect and classify… Radiological Society … Featured         
#> 3 Digit Recognizer        https://www… Learn computer visi… Kaggle                 Getting Started  
#> 4 Digit Recognizer        https://www… Learn computer visi… Kaggle                 Getting Started  
#> 5 Digit Recognizer        https://www… Learn computer visi… Kaggle                 Getting Started  
#> # ℹ 4 more rows
#> # ℹ abbreviated name: ¹​organization_name_nullable
#> # ℹ 37 more variables: reward_nullable <chr>, max_team_size_nullable <int>,
#> #   evaluation_metric_nullable <chr>, id <int>, ref <chr>, title <chr>, has_title <lgl>, url <chr>,
#> #   has_url <lgl>, description <chr>, has_description <lgl>, organization_name <chr>,
#> #   has_organization_name <lgl>, organization_ref <lgl>, has_organization_ref <lgl>,
#> #   category <chr>, has_category <lgl>, reward <chr>, has_reward <lgl>, tags <list>, …
```

You can look up the datalist for a given Kaggle competition using the
API.

``` r
## data list for a given competition
c1_datalist <- kgl_competitions_data_list("titanic")
c1_datalist
#> # A tibble: 3 × 12
#>   name_nullable   description_nullable url_nullable ref   name  has_name description has_description
#>   <chr>           <chr>                <chr>        <chr> <chr> <lgl>    <chr>       <lgl>          
#> 1 gender_submiss… "An example of what… https://www… gend… gend… TRUE     "An exampl… TRUE           
#> 2 train.csv       "contains data"      https://www… trai… trai… TRUE     "contains … TRUE           
#> 3 test.csv        "test data to check… https://www… test… test… TRUE     "test data… TRUE           
#> # ℹ 4 more variables: total_bytes <int>, url <chr>, has_url <lgl>, creation_date <dttm>
```

For a more in-depth walkthrough visit the [Kaggle
API](https://koderkow.github.io/kaggler/articles/kaggle-api.html) page.

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

## Note(s)

- The base of this package was cloned from the original at
  [{kaggler}](https://github.com/mkearney/kaggler). I have decided to
  take the developers work and continue their amazing development! Major
  props and recognition goes out to the original developer(s) of this
  package.
  - I will be updating all documentation and examples for the README and
    functions for this package as time goes on
- The the developers are in no way affiliated with Kaggle.com, and, as
  such, makes no assurances that there won’t be breaking changes to the
  API at any time
- Although the developers are not affiliated, it’s good practice to be
  informed, so here is the link to Kaggle’s terms of service:
  <https://www.kaggle.com/terms>
