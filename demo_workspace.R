rstudioapi::restartSession()
library(targets)
tar_destroy()

# Write the target script.
file.copy("pipelines/workspace.R", "_targets.R", overwrite = TRUE)

# Look at the target script and note the workspace_on_error option.
tar_edit()

# Inspect the pipeline.
tar_visnetwork()

# Try to run the pipeline.
tar_make()

# List available workspaces.
tar_workspaces() # "analysis_02de2921"
file.size("_targets/workspaces/analysis_02de2921") # size in bytes (small file)

# Get the traceback from the workspace.
tar_traceback(analysis_02de2921)

# Before loading the workspace:
print(search()) # load packages
print(ls()) # list of objects in the environment
print(digest::digest(.Random.seed)) # state of the random number generator

# Load the workspace
tar_workspace(analysis_02de2921)

# After loading the workspace:
print(search()) # More packages loaded.
print(ls()) # Functions and data are in the environment.
print(digest::digest(.Random.seed)) # The target's seed is set.

# Reproduce the error in the local interactive R session
# outside the pipeline.
analyze_data(data)

# Diagnose the bug.
anyNA(data$outcome)

# Confirm the solution.
keep_units <- unique(data$unit[!is.na(data$outcome)])
filtered_data <- filter(data, unit %in% keep_units)
analyze_data(filtered_data)
