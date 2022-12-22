
#' Install the Azure CLI
#'
#' @export
azr_install_cli <- function() {
    tryCatch(
        switch(get_os(),
               windows = azr_install_cli_windows(),
               osx = azr_install_cli_mac(),
               linux = azr_install_cli_linux()
        ),
        error = function(e) {
            cli_abort(c("Error installing Azure CLI.",
                        ">"="Try installing manually following the instructions
                        at {.url https://learn.microsoft.com/en-us/cli/azure/install-azure-cli}"))
        }
    )
    invisible(NULL)
}

azr_install_cli_windows <- function() {
    exec_check("winget", c("install", "-e", "--id", "Microsoft.AzureCLI"))
}

azr_install_cli_mac <- function() {
    exec_check("brew", c("install", "azure-cli"))
}

azr_install_cli_linux <- function() {
    path = file.path(tempdir(), "azure_install_script.sh")
    download.file("https://aka.ms/InstallAzureCLIDeb", path)
    exec_check("bash", path)
}
