.PHONY: all check doc test

all: doc rcmd

doc:
	Rscript -e 'devtools::document()'
	Rscript -e 'rmarkdown::render("README.Rmd")'

test:
	Rscript -e 'testthat::test_local()'

check:
	Rscript -e 'summary(pkgcheck::pkgcheck())'
	#Rscript -e 'library(pkgcheck); checks <- pkgcheck(); print(checks); summary (checks)'

rcmd:
	Rscript -e 'rcmdcheck::rcmdcheck()'
