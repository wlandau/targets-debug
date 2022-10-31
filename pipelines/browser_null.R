library(targets)
library(tarchetypes)

options(clustermq.scheduler = "multiprocess")
future::plan(future::multisession)

tar_option_set(
  packages = c("broom", "broom.mixed", "dplyr", "nlme", "tibble", "tidyr"),
  error = "null" # Every errored target returns NULL.
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
  tar_map_rep( # from the {tarchetypes} package
    name = analysis,
    command = simulate_and_analyze_one_dataset(units), # 100 rows per dataset
    values = data.frame(units = c(58, 70)), # 2 data size scenarios.
    names = all_of("units"), # The columns of values to name the targets.
    batches = 20, # Number of batches (dynamic branch targets) per scenario in values.
    reps = 5 # Number of replications per batch.
  )
)
