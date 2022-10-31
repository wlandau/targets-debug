rstudioapi::restartSession()
library(targets)
tar_destroy()

# Write the target script.
file.copy("pipelines/simple.R", "_targets.R", overwrite = TRUE)

# Look at the target script.
tar_edit()

# Inspect the pipeline.
tar_visnetwork()

# Run the pipeline.
tar_make_clustermq(workers = 1) # error

# Find the error.
tar_visnetwork()
tar_progress()
tar_errored()

# Check the error messages.
tar_meta(fields = error, complete_only = TRUE)

# Check the warning messages.
tar_meta(fields = warnings, complete_only = TRUE)

# random number generator seeds
tar_meta(name = dataset1, field = seed)
tar_meta(name = model, field = seed)

# Peel back layers to find more clues!
# Try to reproduce it without {targets}.
# Much easier to solve that way.

# Can I reproduce the error without {clustermq}?
tar_make() # same error

# What about without {callr}?
rstudioapi::restartSession() # remove detritus from the environment
library(targets)
tar_make(callr_function = NULL) # same error

# What about just {callr} without {targets}?
callr::r( # same error
  func = function() {
    set.seed(-1012558151) # from tar_meta(name = dataset1, field = seed)
    library(targets)
    suppressMessages(tar_load_globals())
    data <- simulate_data(units = 100)
    analyze_data(data)
  },
  show = TRUE
)

# What about {clustermq} without {targets}?
# (if you used tar_make_clustermq())
options(clustermq.scheduler = "multiprocess")
clustermq::Q( # same error
  fun = function(index) {
    set.seed(-1012558151)
    library(targets)
    suppressMessages(tar_load_globals())
    data <- simulate_data(units = 100)
    analyze_data(data)
  },
  index = 1,
  n_jobs = 1
)

# What about {future} without {targets}?
# (if you used tar_make_future())
future::plan(future::multisession)
f <- future::future( # same error
  expr = {
    set.seed(-1012558151)
    library(targets)
    suppressMessages(tar_load_globals())
    data <- simulate_data(units = 100)
    analyze_data(data)
  },
  seed = TRUE
)
future::value(f)

# With these findings, you can debug the {targets} pipeline
# Without working with {targets} at all.
# What if we remove {targets}, {callr}, {clustermq}, and {future}
# and just work with the custom R code?

# Load functions, other globals, and packages.
rm(list = ls())
rstudioapi::restartSession()
library(targets)
print(ls())
suppressMessages(tar_load_globals())
print(ls())

# Reproduce the error using the function and the upstream data.
tar_load(dataset1) # upstream data target
analyze_data(dataset1) # same error

# Careful: the error disappears for some random datasets.
set.seed(0)
random_data <- simulate_data(100)
analyze_data(random_data)

# But missing values in an object? Could it be a problem with dataset1?
anyNA(dataset1$outcome)

# Try again.
keep_units <- unique(dataset1$unit[!is.na(dataset1$outcome)])
filtered_data <- filter(dataset1, unit %in% keep_units)
analyze_data(filtered_data) # Solved!
