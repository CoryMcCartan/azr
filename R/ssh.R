
get_ssh <- function(rg, name) {
    name_ssh = str_c(name, "-ssh")
    TYPE = "Microsoft.Compute/sshPublicKeys"

    ssh_dir = file.path(Sys.getenv("HOME"), ".ssh")
    if (!dir.exists(ssh_dir)) {
        dir.create(ssh_dir)
    }

    if (rg$resource_exists(type=TYPE, name=name_ssh)) {
        rg$get_resource(type=TYPE, name=name_ssh)
    } else {
        keyres = rg$create_resource(type=TYPE, name=name_ssh)
        keys = keyres$do_operation("generateKeyPair", http_verb="POST")
        keyres$sync_fields()

        path_private = azr_ssh_priv(ssh_dir)
        writeBin(keys$privateKey, path_private)
        Sys.chmod(path_private, "600")
        cli_alert_success("RSA private key saved to {.path {path_private}}")

        path_pub = azr_ssh_pub(ssh_dir)
        writeBin(keys$publicKey, path_pub)
        cli_alert_success("RSA public key saved to {.path {path_pub}}")
    }
}

#' Path to the Saved RSA Public Key
#' @param ssh_dir The directory to store SSH files
#' @export
azr_ssh_pub <- function(name=make.names(Sys.info()["user"]),
                        ssh_dir=file.path(Sys.getenv("HOME"), ".ssh")) {
    name_ssh = str_c(name, "-ssh")
    if (get_os() != "windows") {
        ssh_dir = sub(Sys.getenv("HOME"), "~", ssh_dir, fixed=TRUE)
    }
    file.path(ssh_dir, str_c("azure-", name_ssh, ".pub"))
}

#' Path to the Saved RSA Private Key
#' @param ssh_dir The directory to store SSH files
#' @export
azr_ssh_priv <- function(name=make.names(Sys.info()["user"]),
                         ssh_dir=file.path(Sys.getenv("HOME"), ".ssh")) {
    name_ssh = str_c(name, "-ssh")
    if (get_os() != "windows") {
        ssh_dir = sub(Sys.getenv("HOME"), "~", ssh_dir, fixed=TRUE)
    }
    file.path(ssh_dir, str_c("azure-", name_ssh, ".pem"))
}

#' Command to SSH into Azure VM
#' @param ssh_dir The username on the VM
#' @param ssh_dir The directory to store SSH files
#' @export
azr_ssh_cmd <- function(vm,
                        ssh_dir=file.path(Sys.getenv("HOME"), ".ssh")) {
    cli_text("ssh -i {azr_ssh_priv(ssh_dir)} {ssh_addr(vm)}")
}

ssh_addr <- function(vm) {
    str_c(vm$properties$outputs$adminUsername$value, "@", vm$dns_name)
}

ssh_config <- function(name, ssh_pub) {
    AzureVM::user_config(name, ssh_pub)
}

find_ssh <- function(homedir=Sys.getenv("HOME")) {
    opts = Sys.glob(file.path(homedir, ".ssh", "*.pub"))
    if (length(opts) == 1) {
        opts
    } else {
        cli_abort("Specify path to SSH public key manually with {.arg ssh} argument.",
                  call=parent.frame())
    }
}
