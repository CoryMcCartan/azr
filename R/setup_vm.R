#' Set Up an Azure Virtual Machine for R
#'
#' @param name the name of the resource group. Will also be the username on the VM.
#' @param password the local VM password to set (will be the Rstudio password as well)
#' @param spatial if `TRUE` install spatial libraries as well
#' @param rstudio if `TRUE` install RStudio Server
#' @param size Machine specs. Some recommended options:
#'     * `Standard_B2s`: 2 cores, 4 GB RAM
#'     * `Standard_D2s_v5`: 2 cores, 8 GB RAM
#'     * `Standard_D4s_v3`: 4 cores, 6 GB RAM
#'   See <https://learn.microsoft.com/en-us/azure/virtual-machines/sizes> for more information.
#' @param loc The physical location of the VM. Defaults to `eastus` in Virginia.
#' @param dir,sub_id Azure identifiers that should be set in your `.Renviron`. See
#'   the package README for details.
#'
#' @returns A reference to the VM. See `AzureVM` package for details.
#' @export
azr_vm_setup <- function(name=make.names(Sys.info()["user"]),
                         password=NULL,
                         spatial=FALSE,
                         rstudio=FALSE,
                         size="Standard_D2s_v5",
                         loc="eastus",
                         dir=Sys.getenv("AZURE_DIR"),
                         sub_id=Sys.getenv("AZURE_SUB_ID")) {
    if (is.null(password) || !is.character(password))
        cli_abort("Must provide a password")

    cli_process_start("Logging in")
    sub = azr_auth(dir, sub_id)
    cli_process_done()

    cli_process_start("Creating resource group {.strong {name}}")
    rg = azr_make_resource_group(sub, name, loc)
    cli_process_done()

    cli_process_start("Creating VM {.strong {name}}")
    vm = azr_make_vm(rg, name, size)
    cli_process_done()

    cli_process_start("Setting password")
    session = ssh::ssh_connect(ssh_addr(vm), azr_ssh_priv())
    cmd = str_c("echo '", name, ":", password, "' | sudo chpasswd")
    ssh::ssh_exec_internal(session, cmd)
    cli_process_done()

    cli_process_start("Installing R")
    azr_install_r(session)
    cli_process_done()

    cli_process_start("Installing R spatial libraries")
    if (spatial) azr_install_spatial(session)
    cli_process_done()

    cli_process_start("Installing RStudio Server")
    if (rstudio) azr_install_rstudio(session)
    cli_process_done()

    cli_process_start("Copying R configuration")
    azr_copy_config(session)
    cli_process_done()

    ssh::ssh_disconnect(session)

    vm
}


azr_make_resource_group <- function(sub, name, loc) {
    sub$create_resource_group(name, loc)
}

azr_make_vm <- function(rg, name, size) {
    vm_name = str_c(name, "-vm")

    login = AzureVM::user_config(name, get_ssh(rg, name))

    rg$create_vm(
        vm_name,
        login_user=login,
        size=size,
        location=rg$location,
        nsg=AzureVM::nsg_config(list(AzureVM::nsg_rule_allow_rstudio))
    )
}


azr_install_r <- function(session) {
    ssh::ssh_exec_internal(session, get_script("install_r.sh"))
    ssh::ssh_exec_internal(session, "R -e 'install.packages(\"tidyverse\")'")
}


azr_install_spatial <- function(session) {
    ssh::ssh_exec_internal(session, get_script("install_spatial.sh"))
}

azr_install_rstudio <- function(session) {
    ssh::ssh_exec_internal(session, get_script("install_rstudio.sh"))
}

azr_copy_config <- function(session) {
    paths = c("~/.Rprofile", "~/.Renviron", "~/.R")

    for (path in paths) {
        path_exp = sub("~", Sys.getenv("HOME"), path, fixed=TRUE)
        if (file.exists(path_exp)) {
            ssh::scp_upload(session, path_exp, verbose=FALSE)
        }
    }
}
