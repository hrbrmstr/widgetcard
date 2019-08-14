
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Signed
by](https://img.shields.io/badge/Keybase-Verified-brightgreen.svg)](https://keybase.io/hrbrmstr)
![Signed commit
%](https://img.shields.io/badge/Signed_Commits-87.5%25-lightgrey.svg)
[![Linux build
Status](https://travis-ci.org/hrbrmstr/widgetcard.svg?branch=master)](https://travis-ci.org/hrbrmstr/widgetcard)
[![Coverage
Status](https://codecov.io/gh/hrbrmstr/widgetcard/branch/master/graph/badge.svg)](https://codecov.io/gh/hrbrmstr/widgetcard)
![Minimal R
Version](https://img.shields.io/badge/R%3E%3D-3.2.0-blue.svg)
![License](https://img.shields.io/badge/License-MIT-blue.svg)

# widgetcard

Tools to Enable Easier Content Embedding in Tweets

## Description

Tools to enable easier content embedding in tweets.

## What’s Inside The Tin

The following functions are implemented:

  - `card_widget`: Turn an htmlwidget into a web deployable, interactive
    Twitter card
  - `gg_preview`: Generate a Twitter Player card preview image from a
    ggplot2 plot
  - `twitter_document`: Standard HTML Document with Twitter Tags

## Installation

``` r
install.packages("widgetcard", repos = "https://cinc.rud.is")
# or
remotes::install_git("https://git.rud.is/hrbrmstr/widgetcard.git")
# or
remotes::install_git("https://git.sr.ht/~hrbrmstr/widgetcard")
# or
remotes::install_gitlab("hrbrmstr/widgetcard")
# or
remotes::install_bitbucket("hrbrmstr/widgetcard")
# or
remotes::install_github("hrbrmstr/widgetcard")
```

NOTE: To use the ‘remotes’ install options you will need to have the
[{remotes} package](https://github.com/r-lib/remotes) installed.

## Usage

See [the
vignette](https://rud.is/dl/creating-interactive-player-cards.html).

## widgetcard Metrics

| Lang | \# Files |  (%) | LoC |  (%) | Blank lines |  (%) | \# Lines |  (%) |
| :--- | -------: | ---: | --: | ---: | ----------: | ---: | -------: | ---: |
| HTML |        1 | 0.08 | 370 | 0.44 |          31 | 0.19 |        1 | 0.00 |
| R    |        8 | 0.67 | 370 | 0.44 |          70 | 0.44 |      172 | 0.49 |
| Rmd  |        3 | 0.25 |  92 | 0.11 |          58 | 0.36 |      175 | 0.50 |

## Code of Conduct

Please note that this project is released with a Contributor Code of
Conduct. By participating in this project you agree to abide by its
terms.
