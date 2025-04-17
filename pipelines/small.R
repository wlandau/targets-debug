library(targets)

tar_option_set(
  packages = c("broom", "broom.mixed", "dplyr", "nlme", "tibble", "tidyr")
)

simulate_data <- function(units) {
  tibble(unit = seq_len(units), factor = rnorm(n = units, mean = 3)) %>%
    expand_grid(measurement = seq_len(4)) %>%
    mutate(outcome = sqrt(factor) + rnorm(n()))
}

analyze_data <- function(data) {
  gls(
    model = outcome ~ factor,
    data = data,
    correlation = corSymm(form = ~ measurement | unit),
    weights = varIdent(form = ~ 1 | measurement)
  ) %>%
    tidy(conf.int = TRUE, conf.level = 0.95)
}

list(
  tar_target(name = data, command = simulate_data(100)),
  tar_target(name = model, command = analyze_data(data))
)
