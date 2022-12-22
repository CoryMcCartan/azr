azr_auth <- function(dir, sub_id) {
    tryCatch(
        get_azure_login(tenant=dir)$get_subscription(sub_id),
        error = function(e) {
            create_azure_login(tenant=dir)$get_subscription(sub_id)
        }
    )
}

# get script text from pkg file
get_script <- function(name) {
    path = system.file(file.path("scripts", name), package="azr", mustWork=TRUE)
    paste0(readLines(path), collapse="\n")
}


# run a system command but check that it exists first
exec_check <- function(cmd, args=NULL, ...) {
    tryCatch({
        sys::exec_wait(cmd, args, ...)
    },
    error = function(e) {
        if (str_detect(e$message, "No such file or directory")) {
            if (get_os() == "windows") {
                cli_abort(c("System command {.code {cmd}} not found.",
                            ">"="Make sure GNU/Linux utilities are enabled by installing
                            the WSL: {.url https://learn.microsoft.com/en-us/windows/wsl/install}"),
                          call=parent.frame())
            } else {
                cli_abort(c("System command {.code {cmd}} not found.",
                            ">"="Please report this to the maintainer, {maintainer('azr')}"),
                          call=parent.frame())
            }
        } else {
            cli_abort(e$message, call=parent.frame())
        }
    })

}

str_detect <- function(string, pattern) {
    grepl(pattern, string, ignore.case=FALSE, perl=FALSE, fixed=FALSE)
}

str_c <- function(...) {
    paste0(...)
}

# detect OS
get_os <- function() {
    sysinf <- Sys.info()
    if (!is.null(sysinf)) {
        os <- tolower(sysinf["sysname"])
        if (os == "darwin")
            os <- "osx"
    } else { ## mystery machine
        os <- .Platform$OS.type
        if (grepl("^darwin", R.version$os))
            os <- "osx"
        if (grepl("linux-gnu", R.version$os))
            os <- "linux"
    }
    tolower(os)
}
