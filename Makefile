SOURCES = $(wildcard *.json)
BUILD_DIR=build
MD_TARGETS = $(addprefix $(BUILD_DIR)/,$(SOURCES:.json=.md))
PDF_TARGETS = $(addprefix $(BUILD_DIR)/,$(SOURCES:.json=.pdf))
HTML_TARGETS = $(addprefix $(BUILD_DIR)/,$(SOURCES:.json=.html))
TEX_TARGETS = $(addprefix $(BUILD_DIR)/,$(SOURCES:.json=.tex))

TRELLO2MD = ./src/trello2md.py
PYPARAMS = --comments --header

#helper not to build all files each time
BUILD_DIR_TARGET=$(BUILD_DIR)/.touch


#$< is the first "source"
#$@ is the "target to generate"

PANDOCTEMPLATE_TEX = tex/trello.latex

ifndef USE_DOCKER
MDPROC = pandoc
MDPARAMS_PDF = $< -o $@ --template=`pwd`/$(PANDOCTEMPLATE_TEX) "--variable=title:$(basename $(notdir $@))" $(MDPARAMS_PDF_ADDITIONAL)
MDPARAMS_HTML = $< -o $@
MDPARAMS_TEX = $< -o $@
ifeq ($(shell which $(MDPROC)),)
$(error Please install $(MDPROC) e.g. sudo apt install pandoc)
endif

else
MDPROC = docker run --env "UNAME=$(shell id -u):$(shell id -g)" --volume $(shell pwd):/data marcelhuberfoo/pandoc-gitit pandoc
MDPARAMS_PDF = -f markdown -t latex $(BUILD_DIR)/$(notdir $<) -o $@ --template=$(PANDOCTEMPLATE_TEX) --latex-engine=xelatex "--variable=title:$(basename $(notdir $@))" $(MDPARAMS_PDF_ADDITIONAL)
MDPARAMS_HTML = -f markdown -t html5 $(BUILD_DIR)/$(notdir $<) -o $@
MDPARAMS_TEX = -f markdown -t latex $(BUILD_DIR)/$(notdir $<) -o $@
ifeq ($(shell which docker),)
$(error Please install docker e.g. sudo apt install docker)
endif
endif

ifdef TOC
MDPARAMS_PDF_ADDITIONAL:= --variable=toc:1
endif

ifdef SMALL_MARGIN
MDPARAMS_PDF_ADDITIONAL:= $(MDPARAMS_PDF_ADDITIONAL) --variable=margin-left:2cm --variable=margin-right:2cm --variable=margin-top:2cm --variable=margin-bottom:2cm
endif


ifeq ($(SOURCES),)
$(error Please save a ".json" file from Trello in this directory or set the SOURCES variable to point to a .json file from trello)
endif

all: markdown
markdown: $(BUILD_DIR_TARGET) $(MD_TARGETS)
pdf: $(BUILD_DIR_TARGET) pdf_hint $(PDF_TARGETS)
html: $(BUILD_DIR_TARGET) $(HTML_TARGETS)
latex: $(BUILD_DIR_TARGET) $(TEX_TARGETS)

$(BUILD_DIR_TARGET):
	mkdir -p $(BUILD_DIR)
	touch $@

ifndef USE_DOCKER
#nothing to do without docker
pdf_hint:
	$(info For PDF generation: Be sure to have the Font ecrm1000.tfm installed.\
 For ubuntu this can be done with 'sudo apt install texlive-fonts-recommended')
else
pdf_hint:
endif

ALL_MDS=$(wildcard *.md)
ALL_BUT_README=$(filter-out README.md,$(ALL_MDS))
clean:
	rm -rf *.pdf $(ALL_BUT_README) *.html *.tex $(BUILD_DIR)

%.pdf: %.md
	$(MDPROC) $(MDPARAMS_PDF)

%.html: %.md
	$(MDPROC) $(MDPARAMS_HTML)

#does not work yet
%.tex: %.md
	$(MDPROC) $(MDPARAMS_TEX)

$(BUILD_DIR)/%.md: %.json $(TRELLO2MD) Makefile
	python3 $(TRELLO2MD) --output $@ $< $(PYPARAMS)

.PHONY: pdf_hint all pdf html
