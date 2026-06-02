.JSFResultState <- S7::new_S3_class("data.frame")

#' JSF simulation result class
#'
#' `JSFResult` stores the output of a JSF simulation in a structured S7 object.
#' It keeps the time vector, state trajectories, species names, simulation method,
#' and configuration used to run the simulation.
#'
#' @export
JSFResult <- S7::new_class(
  "JSFResult",
  properties = list(
    time = S7::class_numeric,
    state = .JSFResultState,
    species_names = S7::class_character,
    method = S7::class_character,
    config = S7::class_list
  ),
  validator = function(self) {
    errors <- character()

    if (length(self@time) != nrow(self@state)) {
      errors <- c(
        errors,
        "`@time` must have the same length as the number of rows in `@state`."
      )
    }

    if (!identical(self@species_names, names(self@state))) {
      errors <- c(
        errors,
        "`@species_names` must exactly match the column names of `@state`."
      )
    }

    if (length(self@method) != 1) {
      errors <- c(
        errors,
        "`@method` must be a single character value."
      )
    }

    if (length(errors) > 0) {
      errors
    } else {
      NULL
    }
  }
)

#' Create a JSFResult object
#'
#' @param time Numeric vector of simulation times.
#' @param state Data frame of state trajectories.
#' @param species_names Character vector of species names. Defaults to the
#'   column names of `state`.
#' @param method JSF simulation method used.
#' @param config List of simulation configuration values.
#'
#' @return A `JSFResult` object.
#' @export
new_jsf_result <- function(
    time,
    state,
    species_names = names(state),
    method = "operator-splitting",
    config = list()
) {
  if (!is.numeric(time)) {
    stop("`time` must be numeric.", call. = FALSE)
  }

  if (!is.data.frame(state)) {
    stop("`state` must be a data frame.", call. = FALSE)
  }

  if (is.null(species_names)) {
    stop("`species_names` must be supplied.", call. = FALSE)
  }

  if (!is.character(species_names)) {
    stop("`species_names` must be a character vector.", call. = FALSE)
  }

  if (!is.character(method) || length(method) != 1) {
    stop("`method` must be a single character value.", call. = FALSE)
  }

  if (!is.list(config)) {
    stop("`config` must be a list.", call. = FALSE)
  }

  JSFResult(
    time = time,
    state = state,
    species_names = species_names,
    method = method,
    config = config
  )
}

#' Convert a JSF output data frame to a JSFResult object
#'
#' @param x Data frame returned by `jsf_simulate()` or a model-specific wrapper.
#'   It must contain a `time` column.
#' @param method JSF simulation method used.
#' @param config List of simulation configuration values.
#' @param species_names Optional character vector of species columns to include.
#'
#' @return A `JSFResult` object.
#' @export
as_jsf_result <- function(
    x,
    method = "operator-splitting",
    config = list(),
    species_names = NULL
) {
  if (!is.data.frame(x)) {
    stop("`x` must be a data frame.", call. = FALSE)
  }

  if (!"time" %in% names(x)) {
    stop("`x` must contain a `time` column.", call. = FALSE)
  }

  if (is.null(species_names)) {
    species_names <- setdiff(names(x), "time")
  }

  if (!all(species_names %in% names(x))) {
    stop("All `species_names` must be columns in `x`.", call. = FALSE)
  }

  state <- x[, species_names, drop = FALSE]

  new_jsf_result(
    time = x$time,
    state = state,
    species_names = species_names,
    method = method,
    config = config
  )
}
