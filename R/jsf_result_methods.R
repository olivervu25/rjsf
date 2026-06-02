S7::method(print, JSFResult) <- function(x, ...) {
  cat("<JSFResult>\n")
  cat("Method: ", x@method, "\n", sep = "")
  cat("Time range: ", min(x@time), " to ", max(x@time), "\n", sep = "")
  cat("Time points: ", length(x@time), "\n", sep = "")
  cat("Species: ", paste(x@species_names, collapse = ", "), "\n", sep = "")

  invisible(x)
}

S7::method(summary, JSFResult) <- function(object, ...) {
  state <- object@state

  out <- data.frame(
    species = object@species_names,
    initial = vapply(state, function(x) x[1], numeric(1)),
    final = vapply(state, function(x) x[length(x)], numeric(1)),
    min = vapply(state, min, numeric(1)),
    max = vapply(state, max, numeric(1)),
    mean = vapply(state, mean, numeric(1))
  )

  row.names(out) <- NULL
  out
}

S7::method(plot, JSFResult) <- function(
    x,
    y = NULL,
    ...,
    main = "JSF simulation result",
    xlab = "Time",
    ylab = "Population"
) {
  graphics::matplot(
    x = x@time,
    y = x@state,
    type = "l",
    lty = 1,
    xlab = xlab,
    ylab = ylab,
    main = main,
    ...
  )

  graphics::legend(
    "topright",
    legend = x@species_names,
    lty = 1,
    col = seq_along(x@species_names),
    bty = "n"
  )

  invisible(x)
}
