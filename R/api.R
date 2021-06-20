library(httr)
library("rjson")
library("here")
library(uuid)

#' send web request to JAVA Server to start run sql statement
#'
#' @param query: Sql statement string (only one statement allowed at once e.g. in HANA database)
#' @param connection_id: connection id as saved in idh
#' @param token: your dh-token
#' @param host: idh server host
#' @param port: idh server port
#' @param limit: optional limit to a query to be set
#' @param jdbc_token: jdbc server token to send task directly to jdbc server instead of idh server
#' @param connection_data: if jdbc_token is provided - here you put a dictionary with the connection details
#' @return  query result as dataframe or None if execution without result set
#' @examples
#'   from py_idh.database import PythonJdbc
#'   user_token = "..."
#'   PythonJdbc.execute("SELECT TOP 3* FROM dbo.BSEG", connection_id = ..., token = user_token)
execute <- function(
    query,
    connection_id = NULL,
    token = NULL,
    host = NULL,
    port = NULL,
    limit = NULL,
    connection_data = NULL) {

    rjson::read_yaml()
    here::here()
    
    config <- read_yaml(file.path(here(), "config.yaml"))

    task_data <- list(
        taskId = UUIDgenerate(),
        command = "execute",
        returnDirectly = TRUE,
        params = list(
            query = query)
        )

    if (!is.null(connection_data)) task_data$connectionData <- connection_data
    if (is.null(port)) port <- config$nodePort
    if (is.null(host)) host <- config$host 
    if (!is.null(limit)) task_data$params$limit <- limit
    
    headers <- list(authorization = token, "Content-type" = "application/json")
    url <- paste("http://", host, ":", port, "/api/external/run-sql-statement", sep="")
    response <- POST(url, body = list(taskData = task_data, connectionId = connection_id), add_headers(authorization = token, "Content-type" = "application/json"), encode = "json",verbose(), timeout(36000))
    return(content(response)$data)
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
#' @param jdbc_token: jdbc server token to send task directly to jdbc server instead of idh server
#' @param connection_data: if jdbc_token is provided - here you put a dictionary with the connection details
#' @examples
#'   from py_idh.database import PythonJdbc
#'   user_token = "..."
#'   PythonJdbc.execute("SELECT TOP 3* FROM dbo.BSEG", connection_id = ..., token = user_token)
execute_batch <- function(
    query,
    params,
    connection_id = NULL,
    token = NULL,
    host = NULL,
    port = NULL,
    limit = NULL,
    connection_data = NULL) {
    config <- read_yaml(file.path(here(), "config.yaml"))

    task_data <- list(
        taskId = UUIDgenerate(),
        command = "executeBatch",
        returnDirectly = TRUE,
        params = list(
            query = query,
            params = params)
        )

    if (!is.null(connection_data)) task_data$connectionData <- connection_data
    if (is.null(port)) port <- config$nodePort
    if (is.null(host)) host <- config$host 
    
    headers <- list(authorization = token, "Content-type" = "application/json")
    url <- paste("http://", host, ":", port, "/api/external/run-sql-statement", sep="")
    response <- POST(url, body = list(taskData = task_data, connectionId = connection_id), add_headers(authorization = token, "Content-type" = "application/json"), encode = "json",verbose(), timeout(36000))
    return(content(response)$data)
    }
