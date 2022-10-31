# Debugging {targets} pipelines

R code is easiest to debug when it is interactive. In the R console or [RStudio IDE](https://www.rstudio.com/products/rstudio/), users have full control over the code and objects in the environment, and they are free to dissect, tinker, and test in order to find and fix issues. However, a `targets` pipeline is the opposite of interactive. In `targets`, there are several layers of encapsulation and automation to support reproducibility and scalability. This presentation demonstrates how to cut through these layers to diagnose and repair pipelines.
