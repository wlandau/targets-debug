rstudioapi::restartSession()
library(targets)
tar_destroy()

# Write the target script.
file.copy("pipelines/browser_starter.R", "_targets.R", overwrite = TRUE)

# Look at the target script.
tar_edit()

# Inspect the pipeline.
tar_visnetwork()

# This pipeline has an error.
tar_make()

# Finish anyway! Set `error = "null"` in tar_option_set().
file.copy("pipelines/browser_null.R", "_targets.R", overwrite = TRUE)
tar_edit()
tar_make()
tar_read(analysis) # Just get the results that completed.
tar_visnetwork() # The pipeline still has errors and is not up to date.

# Make debugging easier:
#   (1) Set 1 rep per batch.
#   (2) Just run the `units = 58` scenario.
file.copy("pipelines/browser_rebatch.R", "_targets.R", overwrite = TRUE)
tar_edit()
tar_visnetwork()

# After re-batching, make note of the first target that errors.
tar_make()
tar_errored() # note "analysis_58_8edfc70f9a7feaf4"

# Set `debug = "analysis_58_8edfc70f9a7feaf4"`
# and `cue = tar_cue(mode = "never")`
# in tar_option_set().
file.copy("pipelines/browser_debug.R", "_targets.R", overwrite = TRUE)
tar_edit()

# Run the pipeline in the interactive session (disable the callr process).
rstudioapi::restartSession() # Remove detritus from the session.
library(targets)
# Drop into an interactive debugger.
tar_make(
  callr_function = NULL, # Do not run the pipline behind a callr::r() process.
  use_crew = FALSE, # Disable parallel computing with crew (optional)
  as_job = FALSE # Do not run the pipeline in a Posit Workbench / RStudio background job.
)

# In the interactive debugger, go to where the error happened
# and reproduce it.
debug(analyze_data)
c
gls(
  model = outcome ~ factor,
  data = data,
  correlation = corSymm(form = ~ measurement | unit),
  weights = varIdent(form = ~ 1 | measurement)
)

# Figure out why the error happened.
anyNA(data$outcome)

# Confirm the solution works.
keep_units <- unique(data$unit[!is.na(data$outcome)])
filtered_data <- filter(data, unit %in% keep_units)
gls(
  model = outcome ~ factor,
  data = filtered_data,
  correlation = corSymm(form = ~ measurement | unit),
  weights = varIdent(form = ~ 1 | measurement)
) %>%
  tidy(conf.int = TRUE, conf.level = 0.95)
