# _targets.R
library(targets)

tar_option_set(
  packages = c("broom", "broom.mixed", "dplyr", "nlme", "tibble", "tidyr"),
  workspace_on_error = TRUE # Save a workspace file for a target that errors out.
)

simulate_data <- function(units) {
  tibble(unit = seq_len(units), factor = rnorm(units, mean = 3)) %>%
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
  tar_target(rep, seq_len(100)),
  tar_target(data, simulate_data(100), pattern = map(rep)),
  tar_target(analysis, analyze_data(data), pattern = map(data))
)
