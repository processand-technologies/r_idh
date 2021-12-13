# r_idh package

© 2021 Lyntics GmbH

Lyntics R package. This package allows you to use your connections from within your R code. If you use this package outside of Lyntics, you need to add host and port accordingly.

## Installation

You can install this package from github via
```R
devtools::install_github("https://github.com/processand-technologies/r_idh")
```

## Usage
```R
library("rIdh")
user_token <- "..." 
execute("SELECT TOP 100* FROM BSEG", "my connection's id", user_token)
```
