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

# Before loading the workspace:
print(search()) # loadd packages
print(ls()) # list of objects in the environment
print(digest::digest(.Random.seed)) # state of the random number generator

# Load the workspace
tar_workspace(analysis_02de2921)

# After loading the workspace:
print(search())
print(ls())
print(digest::digest(.Random.seed))

# Reproduce that error.
analyze_data(data)

# Diagnose the bug.
anyNA(data$outcome)

# Confirm the solution.
keep_units <- unique(data$unit[!is.na(data$outcome)])
filtered_data <- filter(data, unit %in% keep_units)
analyze_data(filtered_data)
