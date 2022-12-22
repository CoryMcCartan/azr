
# azr

<!-- badges: start -->
<!-- badges: end -->

The `azr` package provides functionality to install the Azure CLI, set up Azure 
virtual machines, and install the RStudio IDE on a VM instance.

## Installation

You can install azr with:

``` r
remotes::install("CoryMcCartan/azr")
```

## Setting up Azure with azr

You need to point the package to the right Azure subscription.
To do so, set the following environment variables (you can add them to your `.Renviron`).
You will also need to set up an SSH public key on your machine, using `ssh-keygen`.
If you use GitHub or other SSH services you have probably already done this.

``` r
AZURE_DIR='<something like name.onmicrosoft.com>'
AZURE_SUB_ID='<hyphenated hex code>'
```

