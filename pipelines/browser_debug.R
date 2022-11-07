library(targets)
library(tarchetypes)

options(clustermq.scheduler = "multiprocess")
future::plan(future::multisession)

tar_option_set(
  packages = c("broom", "broom.mixed", "dplyr", "nlme", "tibble", "tidyr"),
  debug = "analysis_58_b59aa384", # Interactively debug one or more targets.
  cue = tar_cue(mode = "never") # Force skip non-debugging outdated targets.
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

simulate_and_analyze_one_dataset <- function(units) {
  data <- simulate_data(units)
  analyze_data(data)
}

list(
  tar_map_rep(
    name = analysis,
    command = simulate_and_analyze_one_dataset(units),
    values = data.frame(units = 58),
    names = all_of("units"),
    batches = 100,
    reps = 1
  )
)
