#' Start VM instance
#'
#' @inheritParams azr_make_vm
#'
#' @export
azr_start_vm <- function(name=make.names(Sys.info()["user"]),
                         dir=Sys.getenv("AZURE_DIR"),
                         sub_id=Sys.getenv("AZURE_SUB_ID")) {
    cli_process_start("Logging in")
    rg = azr_auth(dir, sub_id)$get_resource_group(name)
    cli_process_done()

    vm_name = str_c(name, "-vm")
    rg$get_vm(vm_name)$start()
}

#' Stop VM instance
#'
#' @inheritParams azr_make_vm
#'
#' @export
azr_stop_vm <- function(name=make.names(Sys.info()["user"]),
                         dir=Sys.getenv("AZURE_DIR"),
                         sub_id=Sys.getenv("AZURE_SUB_ID")) {
    cli_process_start("Logging in")
    rg = azr_auth(dir, sub_id)$get_resource_group(name)
    cli_process_done()

    vm_name = str_c(name, "-vm")
    rg$get_vm(vm_name)$stop()
}
