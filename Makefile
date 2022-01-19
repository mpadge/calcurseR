.PHONY: all build check document test

all: document build check

build: doc
	R CMD build .

#check: build
#	R CMD check calcurseR*tar.gz

clean:
	-rm -f calcurseR*tar.gz
	-rm -fr calcurseR.Rcheck

doc: clean
	Rscript -e 'devtools::document()'
	Rscript -e 'rmarkdown::render("README.Rmd")'

test:
	Rscript -e 'testthat::test_local()'

check:
	Rscript -e 'library(pkgcheck); checks <- pkgcheck(); print(checks); summary (checks)'

install: clean
	R CMD INSTALL .
