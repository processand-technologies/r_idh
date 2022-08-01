process_result <- function(data) {
    df = data.frame()
    tryCatch(
        expression = {
            if (length(data$rows) == 0) {
                df <- read.table(text = "",
                    colClasses = rep("character", length(data$columns)),
                    col.names = data$columns)
            } else {
                df <- data.frame(t(sapply(data$rows, c)))
                col_counter <- 1
                for (col in data$columns) {
                    names(df)[col_counter] <- col
                    col_counter <- col_counter + 1
                }
            }
            return(df)
        },
        error = function(cond) {
            print(cond)
        },
        finally = {
            return(df)
        }
    )
}

#' send web request to JAVA Server to start run sql statement
#'
#' @param query: Sql statement string (only one statement allowed at once e.g. in HANA database)
#' @param connection_id: connection id as saved in idh
#' @param token: your dh-token
#' @param host: idh server host
#' @param port: idh server port
#' @param limit: optional limit to a query to be set
#' @param connection_data: if no connection_id is provided - here you put a dictionary with the connection details
#' @return  query result as dataframe or None if execution without result set
#' @examples
#'   library("rIdh")
#'   user_token <- "..."
#'   execute("SELECT TOP 3* FROM dbo.BSEG", connection_id = ..., token = user_token)
execute <- function(
    query,
    connection_id = NULL,
    token = NULL,
    host = NULL,
    port = NULL,
    limit = NULL,
    connection_data = NULL) {

    library(httr)
    library("rjson")
    library(uuid)

    task_data <- list(
        taskId = UUIDgenerate(),
        command = "execute",
        returnDirectly = TRUE,
        params = list(
            query = query)
        )

    if (!is.null(connection_data)) task_data$connectionData <- connection_data
    if (is.null(port)) port <- 3011
    if (is.null(host)) host <- 'datahub'
    if (!is.null(limit)) task_data$params$limit <- limit
    
    headers <- list(authorization = token, "Content-type" = "application/json")
    url <- paste("http://", host, ":", port, "/api/external/run-sql-statement", sep="")
    response <- POST(url, body = list(taskData = task_data, connectionId = connection_id), add_headers(authorization = token, "Content-type" = "application/json"), encode = "json",verbose(), timeout(36000))
    result <- content(response)
    if ("error" %in% names(result)) stop(result$error)
    return(process_result(result$data))
}

#' send web request to JAVA Server to start run sql statement
#'
#' @param query: Sql statement string (only one statement allowed at once e.g. in HANA database)
#' @param params: 2d list of parameters 
#' @param connection_id: connection id as saved in idh
#' @param token: your dh-token
#' @param host: idh server host
#' @param port: idh server port
#' @param limit: optional limit to a query to be set
#' @param connection_data: if no connection id is provieded - here you put a dictionary with the connection details
#' @examples
#'   library("rIdh")
#'   user_token <- "..."
#'   # params may be list of unnamed lists or dataframe with right amount of columns
#'   params <- list(list(1, 'ahoi', 1.345), list(2, 'ahoi', 1.345))
#'   data <- execute_batch("INSERT INTO test_batch VALUES (?, ?, ?)", params, connection_id = ..., token = user_token)
execute_batch <- function(
    query,
    params,
    connection_id = NULL,
    token = NULL,
    host = NULL,
    port = NULL,
    limit = NULL,
    connection_data = NULL) {
    
    library(httr)
    library("rjson")
    library(uuid)

    if (is.data.frame(params)) {
        params <- do.call(function(...) Map(list, ...), params)
        rows <- list()
        row_counter <- 1
        for (row in params) {
            rows[[row_counter]] <- unname(row)
            row_counter <- row_counter + 1
        }
        params <- rows
    }

    task_data <- list(
        taskId = UUIDgenerate(),
        command = "executeBatch",
        returnDirectly = TRUE,
        params = list(
            query = query,
            params = params)
        )

    if (!is.null(connection_data)) task_data$connectionData <- connection_data
    if (is.null(port)) port <- 3011
    if (is.null(host)) host <- 'datahub'
    
    headers <- list(authorization = token, "Content-type" = "application/json")
    url <- paste("http://", host, ":", port, "/api/external/run-sql-statement", sep="")
    response <- POST(url, body = list(taskData = task_data, connectionId = connection_id), add_headers(authorization = token, "Content-type" = "application/json"), encode = "json",verbose(), timeout(36000))
    result <- content(response)
    if ("error" %in% names(result)) stop(result$error)
    return(result$data)
}

#' send web request to JDBC Server to run sections in script, if no section ids are given all checked sections are executed
#'
#' @param script_id: IDH sql script id
#' @param section_ids: list of section ids, if not given (or empty) all sections that are checked are executed
#' @param target_branch: git branch to execute from
#' @param connection_id: connection id as saved in idh
#' @param token: your dh-token
#' @param host: idh server host
#' @param port: idh server port
#' @param limit: optional limit to a query to be set
#' @param connection_data: if no connection_id is provided - here you put a dictionary with the connection details
#' @return a dataframe with the result of the last section that is executed
#' @examples
#'   library("rIdh")
#'   user_token <- "..."  
#'   execute_script(script_id = ..., section_ids = list(id1, id2), connection_id = ..., token = user_token)
execute_script <- function(
    script_id = NULL,
    section_ids = NULL,
    target_branch = 'master',
    connection_id = NULL,
    token = NULL,
    host = NULL,
    port = NULL,
    limit = NULL,
    connection_data = NULL) {

    library(httr)
    library("rjson")
    library(uuid)

    task_data <- list(
        taskId = UUIDgenerate(),
        command = "executeScript",
        returnDirectly = TRUE,
        params = list(
            scriptId = script_id,
            targetBranch = target_branch)
        )

    if (!is.null(connection_data)) task_data$connectionData <- connection_data
    if (is.null(port)) port <- 3011
    if (is.null(host)) host <- 'datahub'
    if (!is.null(limit)) task_data$params$limit <- limit
    if (!is.null(section_ids)) task_data$params$sectionIds <- section_ids
        
    headers <- list(authorization = token, "Content-type" = "application/json")
    url <- paste("http://", host, ":", port, "/api/external/run-sql-statement", sep="")
    response <- POST(url, body = list(taskData = task_data, connectionId = connection_id), add_headers(authorization = token, "Content-type" = "application/json"), encode = "json",verbose(), timeout(36000))
    result <- content(response)
    if ("error" %in% names(result)) stop(result$error)
    return(process_result((result$data)))
}
