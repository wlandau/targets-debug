# Debugging {targets} pipelines

The [`targets`](https://docs.ropensci.org/targets/) package is a [Make](https://www.gnu.org/software/make/)-like pipeline tool for statistics and data science in R. With [`targets`](https://docs.ropensci.org/targets/), you can maintain a reproducible workflow without repeating yourself. [`targets`](https://docs.ropensci.org/targets/) skips costly runtime for tasks that are already up to date, orchestrates the necessary computation with implicit parallel computing, and abstracts files as R objects. An up-to-date [`targets`](https://docs.ropensci.org/targets/) pipeline is tangible evidence that the output aligns with the code and data, which substantiates trust in the results. Unfortunately, however, the automation that enhances scale and reproducibility also makes troubleshooting more difficult than in the interactive R console. This presentation demonstrates several techniques to discover and solve issues in [`targets`](https://docs.ropensci.org/targets/) pipelines.

# Practice

The following R scripts walk through the debugging techniques discussed at <https://books.ropensci.org/targets/debugging.html>. To practice, step through the code files in the following order.

1. `demo_small.R`
1. `demo_browser.R`
1. `demo_workspace.R`
