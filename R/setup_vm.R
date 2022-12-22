#' Set Up an Azure Virtual Machine for R
#'
#' @param name the name of the resource group. Defaults to your computer's username.
#' @param spatial if `TRUE` install spatial libraries as well
#' @param size Machine specs. Some recommended options:
#'     * `Standard_B2s`: 2 cores, 4 GB RAM
#'     * `Standard_D2s_v5`: 2 cores, 8 GB RAM
#'     * `Standard_D4s_v3`: 4 cores, 6 GB RAM
#'   See <https://learn.microsoft.com/en-us/azure/virtual-machines/sizes> for more information.
#' @param loc The physical location of the VM. Defaults to `eastus` in Virginia.
#' @param dir,sub_id Azure identifiers that should be set in your `.Renviron`. See
#'   the package README for details.
#'
#' @returns A reference to the VM, invisibly
#' @export
azr_setup_vm <- function(name=make.names(Sys.info()["user"]),
                         spatial=FALSE,
                         size="Standard_D2s_v5",
                         loc="eastus",
                         dir=Sys.getenv("AZURE_DIR"),
                         sub_id=Sys.getenv("AZURE_SUB_ID")) {
    cli_process_start("Logging in")
    sub = azr_auth(dir, sub_id)
    cli_process_done()

    cli_process_start("Creating resource group {.strong {name}}")
    rg = azr_make_resource_group(sub, name, loc)
    cli_process_done()

    cli_process_start("Creating VM {.strong {name}}")
    vm = azr_make_vm(rg, name, size)
    cli_process_done()

    cli_process_start("Installing R")
    session = ssh::ssh_connect(ssh_addr(vm), azr_ssh_priv())

}

azr_make_resource_group <- function(sub, name, loc) {
    sub$create_resource_group(name, loc)
}

azr_make_vm <- function(rg, name, size) {
    vm_name = str_c(name, "-vm")

    login = AzureVM::user_config(name, get_ssh(rg, name))

    rg$create_vm(vm_name,
                 login_user=login,
                 size=size,
                 location=rg$location)
}

azr_install_r <- function(session) {
    ssh::ssh_exec_wait(session, get_script("install_r.sh"))
    ssh::ssh_exec_wait(session, "R -e 'install.packages(\"tidyverse\")'")
}


azr_install_spatial <- function(session) {
    ssh::ssh_exec_wait(session, get_script("install_spatial.sh"))
}
