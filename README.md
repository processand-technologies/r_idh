# r_idh package

© 2021 Lyntics GmbH

Official Lyntics R package. This package allows you to access Lyntics functions via R. If you use this package outside of Lyntics, you need to add host and port specifications accordingly.

--
## Installation


You can install the package from our official repository:
```R
devtools::install_github("https://github.com/processand-technologies/r_idh")
```

--
## Usage

```R
library("rIdh")

user_token <- "..." 
connection_id <- "..." 

execute(
    "SELECT TOP 100* FROM BSEG", 
    connection_id, 
    user_token
)
```


