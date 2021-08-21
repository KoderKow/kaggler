
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ATTENTION

The base of this package was cloned from the original at
[{kaggler}](https://github.com/mkearney/kaggler). I have decided to take
the developers work and continue their amazing development\! Major props
and recognition goes out to the original developer(s) of this package.

I will be updating all documentation and examples for the README and
functions for this package.

-----

# kaggler <img src="man/figures/logo.png" width="160px" align="right" />

> 🏁 An R client for accessing [Kaggle](https://www.kaggle.com)’s API

<!-- badges: start -->

[![R-CMD-check](https://github.com/KoderKow/kaggler/workflows/R-CMD-check/badge.svg)](https://github.com/KoderKow/kaggler/actions)
<!-- badges: end -->

## Installation

You can install the dev version of **{kaggler}** from
[CRAN](https://github.com/mkearney/kaggler) with:

``` r
## install kaggler package from github
devtools::install_packages("koderkow/kaggler")
```

## API authorization

<span>1.</span> Go to [https://www.kaggle.com/](kaggle.com) and sign in

<span>2.</span> Click `Account` or navigate to
`https://www.kaggle.com/{username}/account`

<span>3.</span> Scroll down to the `API` section and click `Create New
API Token` (which should cause you to download a `kaggle.json` file with
your username and API key)

<p style="align:center">

<img src='tools/readme/kag.png' />

</p>

<span>4.</span> There are a few different ways to store your credentials

  - Save/move the `kaggle.json` file as `~/.kaggle/kaggle.json`
  - Save/move the `kaggle.json` file to your current working directory
  - Enter your `username` and `key` and use the `kgl_auth()` function
    like in the example below

<!-- end list -->

``` r
kgl_auth(username = "koderkow", key = "example")
#> Your Kaggle key has been recorded for this session and saved as `KAGGLE_PAT` environment variable for future sessions.
```

## `kgl_competitions_list_.*()`

Browse or search for Kaggle compeitions.

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
#> 1 19991 alaska2… ALASKA2… https:/… Detect secret … Troyes Universi… UTT              Research $25,0…
#> 2 10418 human-p… Human P… https:/… Classify subce… Human Protein A… human-protein-a… Featured $37,0…
#> 3 14420 recursi… Recursi… https:/… CellSignal: Di… Recursion Pharm… recursionpharma  Research $13,0…
#> 4  6927 carvana… Carvana… https:/… Automatically … Carvana          carvana          Featured $25,0…
#> 5  7115 cdiscou… Cdiscou… https:/… Categorize e-c… Cdiscount        cdiscount        Featured $35,0…
#> # … with 15 more rows, and 14 more variables: deadline <dttm>, kernel_count <int>,
#> #   team_count <int>, user_has_entered <lgl>, user_rank <lgl>, merger_deadline <dttm>,
#> #   new_entrant_deadline <dttm>, enabled_date <dttm>, max_daily_submissions <int>,
#> #   max_team_size <int>, evaluation_metric <chr>, awards_points <lgl>,
#> #   is_kernels_submissions_only <lgl>, submissions_disabled <lgl>
```

## `kgl_competitions_data_.*()`

You can look up the datalist for a given Kaggle competition using the
API.

``` r
## data list for a given competition
c1_datalist <- kgl_competitions_data_list(comps1$ref[1])
c1_datalist
#> # A tibble: 3 x 6
#>   id                 ref            name           total_bytes url             creation_date        
#>   <chr>              <chr>          <chr>                <int> <chr>           <chr>                
#> 1 contradictory-my-… sample_submis… sample_submis…       67549 https://www.ka… 2020-07-27T19:45:43.…
#> 2 contradictory-my-… test.csv       test.csv           1180141 https://www.ka… 2020-07-27T19:45:43.…
#> 3 contradictory-my-… train.csv      train.csv          2771659 https://www.ka… 2020-07-27T19:45:43.…
```

Downloading single files is possible by supplying the competition ID and
the wanted file.

``` r
## download set sets (IF YOU HAVE ACCEPTED COMPETITION RULES)
c1_data <- kgl_competitions_data_download(
  id = comps1$ref[1],
  file_name = c1_datalist$name[1]
  )
#> x You must accept this competition's rules before you'll be able to download files.
```

### Downloading all data for a competition

#### ID input

Methods have been built out to accept multiple forms of `id`.

1.  The competition URL
      - `https://www.kaggle.com/c/titanic` and
        `https://www.kaggle.com/c/titanic/code` will recognize `titanic`
        as the ID
2.  Kaggle’s API command
      - Kaggles official API is built in python and they supply a
        command to download the data on the data tab of a competition.
        The download functions will take `kaggle competitions download
        -c titanic`and recognize the ID as `titanic`
3.  Explicit ID
      - If the above two cases don’t match in the logic then everything
        else will be considered an ID
      - Example; entering `titanic` directly

#### `kgl_competitions_data_download_all()`

This function will download all the competitions data files into a dir
called `_kaggle_data` into the main working directory.

``` r
kgl_data <- kgl_competitions_data_download_all(
  id = "https://www.kaggle.com/c/titanic/"
  )
#> ● Iterating over all files names to download...
#> ✓ Setting active project to '/Users/Kow/projects/kaggler'
#> ● Downloading 'gender_submission.csv'...
#> ✓ Data has been saved in '/Users/Kow/projects/kaggler/_kaggle_data/'.
#> ● Downloading 'train.csv'...
#> ✓ Data has been saved in '/Users/Kow/projects/kaggler/_kaggle_data/'.
#> ● Downloading 'test.csv'...
#> ✓ Data has been saved in '/Users/Kow/projects/kaggler/_kaggle_data/'.
#> ✓ Iteration complete! Returning all data in a list and data is available in '_kaggle_data'!
```

The data is available in the `_kaggle_data` directory.

``` r
list.files("_kaggle_data")
#> [1] "gender_submission.csv" "test.csv"              "train.csv"
```

The data is also returned in a list and available in the variable you
assigned it to, in this example its `kgl_data`.

``` r
kgl_data$train
#> # A tibble: 891 x 12
#>   PassengerId Survived Pclass Name             Sex     Age SibSp Parch Ticket    Fare Cabin Embarked
#>         <dbl>    <dbl>  <dbl> <chr>            <chr> <dbl> <dbl> <dbl> <chr>    <dbl> <chr> <chr>   
#> 1           1        0      3 Braund, Mr. Owe… male     22     1     0 A/5 211…  7.25 <NA>  S       
#> 2           2        1      1 Cumings, Mrs. J… fema…    38     1     0 PC 17599 71.3  C85   C       
#> 3           3        1      3 Heikkinen, Miss… fema…    26     0     0 STON/O2…  7.92 <NA>  S       
#> 4           4        1      1 Futrelle, Mrs. … fema…    35     1     0 113803   53.1  C123  S       
#> 5           5        0      3 Allen, Mr. Will… male     35     0     0 373450    8.05 <NA>  S       
#> # … with 886 more rows
kgl_data$test
#> # A tibble: 418 x 11
#>   PassengerId Pclass Name                       Sex      Age SibSp Parch Ticket  Fare Cabin Embarked
#>         <dbl>  <dbl> <chr>                      <chr>  <dbl> <dbl> <dbl> <chr>  <dbl> <chr> <chr>   
#> 1         892      3 Kelly, Mr. James           male    34.5     0     0 330911  7.83 <NA>  Q       
#> 2         893      3 Wilkes, Mrs. James (Ellen… female  47       1     0 363272  7    <NA>  S       
#> 3         894      2 Myles, Mr. Thomas Francis  male    62       0     0 240276  9.69 <NA>  Q       
#> 4         895      3 Wirz, Mr. Albert           male    27       0     0 315154  8.66 <NA>  S       
#> 5         896      3 Hirvonen, Mrs. Alexander … female  22       1     1 31012… 12.3  <NA>  S       
#> # … with 413 more rows
kgl_data$gender_submission
#> # A tibble: 418 x 2
#>   PassengerId Survived
#>         <dbl>    <dbl>
#> 1         892        0
#> 2         893        1
#> 3         894        0
#> 4         895        0
#> 5         896        1
#> # … with 413 more rows
```

### Future goals for downloads

  - Check the download folder to see if any of the files exists. If yes,
    prompt the user to redownload the ones that exist. If they dont
    exist, download them
  - Easily load/attach all kaggle data with a function, similar to
    `{targets}`’s `tar_load()`

## `kgl_datasets_.*()`

Get a list of all of the datasets.

``` r
## get competitions data list
datasets <- kgl_datasets_list()
datasets
#> # A tibble: 20 x 23
#>        id ref   subtitle  creatorName creatorUrl totalBytes url    lastUpdated         downloadCount
#>     <int> <chr> <chr>     <chr>       <chr>           <dbl> <chr>  <dttm>                      <int>
#> 1 1187302 gpre… r/Vaccin… Gabriel Pr… gpreda        2.39e 5 https… NA                          10860
#> 2 1165452 crow… A Large-… Oğuzhan Ul… crowww        3.48e 9 https… NA                           6641
#> 3 1167622 imsp… A curate… Sparsh Gup… imsparsh      2.31e10 https… NA                           2512
#> 4 1167113 dhru… Complete… Dhruvil Da… dhruvilda…    1.94e 9 https… NA                           2674
#> 5 1193668 prom… A full s… PromptCloud promptclo…    4.39e 7 https… NA                           1637
#> # … with 15 more rows, and 14 more variables: isPrivate <lgl>, isReviewed <lgl>, isFeatured <lgl>,
#> #   licenseName <chr>, description <lgl>, ownerName <chr>, ownerRef <chr>, kernelCount <int>,
#> #   title <chr>, topicCount <int>, viewCount <int>, voteCount <int>, currentVersionNumber <int>,
#> #   usabilityRating <dbl>
```

## `kgl_competitions_leaderboard_.*()`

View the leaderboard for a given competition.

``` r
## get competitions data list
c1_leaderboard <- kgl_competitions_leaderboard_view(comps1$ref[1])
c1_leaderboard
#> # A tibble: 50 x 4
#>   team_id team_name                       submission_date     score  
#>     <int> <chr>                           <dttm>              <chr>  
#> 1 6997448 cindylee1018                    2021-06-29 09:16:31 0.95611
#> 2 7053758 David Roberts                   2021-07-06 18:18:40 0.95014
#> 3 5824147 YUZHE NI                        2021-08-07 04:06:06 0.94513
#> 4 7028450 OrS The Crazy DS and Yaniv Roth 2021-08-01 14:11:17 0.94282
#> 5 6840575 Pradeep Kumar Mahato            2021-08-17 05:52:17 0.94148
#> # … with 45 more rows
```

## Note(s)

  - The the developers are in no way affiliated with Kaggle.com, and, as
    such, makes no assurances that there won’t be breaking changes to
    the API at any time
  - Although the developers are not affiliated, it’s good practice to be
    informed, so here is the link to Kaggle’s terms of service:
    <https://www.kaggle.com/terms>
