SOURCES = $(wildcard *.json)
MD_TARGETS = $(SOURCES:.json=.md)
PDF_TARGETS = $(SOURCES:.json=.pdf)
HTML_TARGETS = $(SOURCES:.json=.html)
TEX_TARGETS = $(SOURCES:.json=.tex)

TRELLO2MD = ./src/trello2md.py
PYPARAMS = 
MDPROC = pandoc
PANDOCTEMPLATE_TEX = tex/trello.latex
#$< is the first "source"
#$@ is the "target to generate"
MDPARAMS_PDF = $< -o $@ --template=`pwd`/$(PANDOCTEMPLATE_TEX)
MDPARAMS_HTML = $< -o $@
MDPARAMS_TEX = $< -o $@

ifeq ($(shell which $(MDPROC)),)
$(error Please install $(MDPROC) e.g. sudo apt install pandoc)
endif

ifeq ($(SOURCES),)
$(error Please save a ".json" file from Trello in this directory or set the SOURCES variable to point to a .json file from trello)
endif

all: $(MD_TARGETS)
pdf: pdf_hint $(PDF_TARGETS)
html: $(HTML_TARGETS)
latex: $(TEX_TARGETS)

pdf_hint:
	$(info For PDF generation: Be sure to have the Font ecrm1000.tfm installed.\
 for ubuntu this can be done with)
	$(info sudo apt install texlive-fonts-recommended)

ALL_MDS=$(wildcard *.md)
ALL_BUT_README=$(filter-out README.md,$(ALL_MDS))
clean:
	rm -f *.pdf $(ALL_BUT_README) *.html *.tex

%.pdf: %.md
	$(MDPROC) $(MDPARAMS_PDF)

%.html: %.md
	$(MDPROC) $(MDPARAMS_HTML)

#does not work yet
%.tex: %.md
	$(MDPROC) $(MDPARAMS_TEX)

%.md: %.json $(TRELLO2MD) Makefile
	python3 $(TRELLO2MD) $< $(PYPARAMS)

.PHONY: pdf_hint all pdf html
