# r_idh

You can install this package from github via
```
devtools::install_github("https://github.com/processand-technologies/r_idh")
```

Usage
```
library("rIdh")
user_token <- "..." 
execute("SELECT TOP 100* FROM BSEG", "my connection's id", user_token)
```
