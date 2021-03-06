#' @import knitr
generate_visualization <- function(opts){
    visualization <- knit_expand(opts$path$template_file)
    capture.output(knit(text = visualization, output = opts$path$html_file))
}

#' Generates a JavaScript visualization
#'
#' @param data input data
#' @param ractive template id, it must match a folder within \code{set_root_path}
#' @param browse open browser, default TRUE
#' @param ... additional arguments for \code{get_opts}
#' @export
#' @examples
#'
#' library(clickme)
#'
#' # visualize a force-directed interactive graph
#' items <- paste0("GENE_", 1:40)
#' n <- 30
#' df1 <- data.frame(source = sample(items, n, replace = TRUE), target = sample(items, n, replace = TRUE), type = sample(letters[1:3], n, replace = TRUE))
#' clickme(df1, "force_directed")
clickme <- function(data, ractive, browse = interactive(), ...){
    opts <- get_opts(ractive, ...)

    if (opts$template_config$require_server && (is.null(getOption("clickme_server_warning")) || getOption("clickme_server_warning")) ) {
        separator <- paste0(rep("=", 70, collapse = ""))
        message(separator)
        message(paste0("If you don't have a server running in your Clickme root path, open a new ", ifelse(.Platform$OS.type == "unix", "terminal", "Command Prompt"), " and type:"))
        message("cd \"", get_root_path(), "\"\npython -m SimpleHTTPServer")

        message("\n(add: options(clickme_server_warning = FALSE) in your .Rprofile to avoid seeing this warning again.)")
        message("Press Enter to continue or \"c\" to cancel: ", appendLF = FALSE)
        response <- readline()
        if (tolower(response) %in% c("c")) {
            capture.output(return())
        }
        message(separator)
    }

    if (opts$template_config$require_coffeescript && system("coffee -v", ignore.stdout = TRUE, ignore.stderr = TRUE) != 0) {
        message("\n", separator)
        message("This visualization requires \"coffee\" and it seems that you don't have it installed.")
        message("See http://coffeescript.org/ for installation instructions")
        message("Press Enter after you install it or \"c\" to cancel: ", appendLF = FALSE)
        response <- readline()
        if (tolower(response) %in% c("c")) {
            capture.output(return())
        }
        message(separator)
    }

    opts$data <- data
    if (!is.null(opts$name_mappings)){
        opts$data <- map_data_names(opts)
    }

    validate_data_names(opts)

    source(opts$path$translator_file)
    generate_visualization(opts)

    if (browse) browseURL(opts$url)

    invisible(opts)
}


