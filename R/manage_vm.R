#' Get Reference to VM
#'
#' @inheritParams azr_vm_setup
#'
#' @export
azr_vm <- function(name=make.names(Sys.info()["user"]),
                   dir=Sys.getenv("AZURE_DIR"),
                   sub_id=Sys.getenv("AZURE_SUB_ID")) {
    cli_process_start("Logging in")
    rg = azr_auth(dir, sub_id)$get_resource_group(name)
    cli_process_done()

    vm_name = str_c(name, "-vm")
    rg$get_vm(vm_name)
}

#' Start VM instance
#'
#' @inheritParams azr_vm_setup
#'
#' @export
azr_vm_start <- function(name=make.names(Sys.info()["user"]),
                         dir=Sys.getenv("AZURE_DIR"),
                         sub_id=Sys.getenv("AZURE_SUB_ID")) {
    azr_vm(name, dir, sub_id)$start()
}

#' Stop VM instance
#'
#' @inheritParams azr_vm_setup
#'
#' @export
azr_vm_stop <- function(name=make.names(Sys.info()["user"]),
                         dir=Sys.getenv("AZURE_DIR"),
                         sub_id=Sys.getenv("AZURE_SUB_ID")) {
    azr_vm(name, dir, sub_id)$stop()
}
