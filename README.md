
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

To set up a virtual machine with R installed, run

``` r
azr::azr_vm_setup()
```

You can specify the type of machine with `size=`, and additionally install a
recent version of Rstudio Server with `rstudio=TRUE` and install R spatial
packages with `spatial=TRUE`.
Any R configuration files on your local machine (`.Rprofile`, etc.) will also be transferred to the VM.

Once a machine is set up, you can get the command to SSH into it with
`azr_ssh_cmd()`.
You can also start and stop the VM with `azr_vm_start()` and `azr_vm_stop()`.
