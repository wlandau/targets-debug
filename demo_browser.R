library(targets)
tar_destroy()

# Write the target script.
file.copy("pipelines/browser_starter.R", "_targets.R", overwrite = TRUE)

# Look at the target script.
tar_edit()

# Inspect the pipeline.
tar_visnetwork()

# This pipeline has an error.
tar_make_clustermq(workers = 2)

# Finish anyway! Set `error = "null"` in tar_option_set().
file.copy("pipelines/browser_null.R", "_targets.R", overwrite = TRUE)
tar_edit()
tar_make_clustermq(workers = 2)
tar_read(analysis) # Just get the results that completed.
tar_visnetwork() # The pipeline still has errors and is not up to date.

# Make debugging easier:
#   (1) Set 1 rep per batch.
#   (2) Just run the `units = 58` scenario.
# Finish anyway! Set `error = "null"` in tar_option_set().
file.copy("pipelines/browser_rebatch.R", "_targets.R", overwrite = TRUE)
tar_edit()
tar_visnetwork()

# After re-batching, make note of the first target that errors.
tar_make()
tar_errored() # "analysis_58_b59aa384"

# Set `debug = "analysis_58_b59aa384"` in tar_option_set().
file.copy("pipelines/browser_debug.R", "_targets.R", overwrite = TRUE)
tar_edit()

# Run the pipeline in the interactive session (disable the callr process).
rstudioapi::restartSession() # Remove detritus from the session.
library(targets)
tar_make(callr_function = NULL) # Drop into an interactive debugger.

# In the interactive debugger, figure out why the target fails.
debug(analyze_data)
c
gls(
  model = outcome ~ factor,
  data = data,
  correlation = corSymm(form = ~ measurement | unit),
  weights = varIdent(form = ~ 1 | measurement)
)
anyNA(data$outcome)
data_filtered <- filter(data, !is.na(outcome))
gls(
  model = outcome ~ factor,
  data = data_filtered,
  correlation = corSymm(form = ~ measurement | unit),
  weights = varIdent(form = ~ 1 | measurement)
) %>%
  tidy(conf.int = TRUE, conf.level = 0.95)
