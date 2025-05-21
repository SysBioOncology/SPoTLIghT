#!/usr/bin/env Rscript
options(repos = "https://CRAN.R-project.org")

# 1). Install 'pak' (fast package installer)
message("Installing 'pak'...")
install.packages("pak")

# 2) Install remaning packages
pak::pkg_install(c("GaitiLab/GaitiLabUtils", "cran/matrixStats@1.1.0"))
