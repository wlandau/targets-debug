rstudioapi::restartSession()
library(targets)
tar_destroy()

# Write the target script.
file.copy("pipelines/small.R", "_targets.R", overwrite = TRUE)

# Look at the target script.
tar_edit()

# Inspect the pipeline.
tar_visnetwork()

# Run the pipeline.
tar_make() # error

# Find the error.
tar_visnetwork()
tar_progress()
tar_errored()

# Check the error messages.
tar_meta(fields = error, complete_only = TRUE)

# Check the warning messages.
tar_meta(fields = warnings, complete_only = TRUE)

# random number generator seeds
tar_meta(name = data, field = seed)
tar_meta(name = model, field = seed)

# Peel back layers to find more clues!
# Can I reproduce the error without {callr}?
rstudioapi::restartSession() # remove detritus from the environment
library(targets)
tar_make(callr_function = NULL) # same error

# What about just {callr} without {targets}?
callr::r( # same error
  func = function() {
    library(targets)
    set.seed(tar_meta(name = data, field = seed)$seed)
    suppressMessages(tar_load_globals())
    data <- simulate_data(units = 100)
    analyze_data(data)
  },
  show = TRUE
)

# What about in a simple interactive session?
# Load functions, other globals, and packages.
rm(list = ls())
rstudioapi::restartSession()
library(targets)
print(ls())
suppressMessages(tar_load_globals())
print(ls())

# Reproduce the error using the function and the upstream data.
tar_load(data) # upstream data target
analyze_data(data) # same error

# Start with the data this time, but use the same seed.
set.seed(tar_meta(name = data, field = seed)$seed)
random_data <- simulate_data(100)
analyze_data(random_data)

# But missing values in an object? Could it be a problem with dataset1?
anyNA(data$outcome)

# Try again.
keep_units <- unique(data$unit[!is.na(data$outcome)])
filtered_data <- filter(data, unit %in% keep_units)
analyze_data(filtered_data) # Solved!
