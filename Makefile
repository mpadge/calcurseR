.PHONY: all check document test

all: document check

document:
	Rscript -e 'devtools::document()'
	Rscript -e 'rmarkdown::render("README.Rmd")'

test:
	Rscript -e 'testthat::test_local()'

check:
	Rscript -e 'summary(pkgcheck::pkgcheck())'
	#Rscript -e 'library(pkgcheck); checks <- pkgcheck(); print(checks); summary (checks)'
