SOURCE = export.json
TARGET = $(subst .json,,$(SOURCE))
TRELLO2MD = ./src/trello2md.py
PYPARAMS = 
MDPROC = pandoc
PANDOCTEMPLATE_TEX = tex/trello.latex
MDPARAMS_PDF = $(TARGET).md -o $(TARGET).pdf --template=`pwd`/$(PANDOCTEMPLATE_TEX)
MDPARAMS_HTML = $(TARGET).md -o $(TARGET).html

all: markdown

markdown: $(TARGET).md

pdf: markdown
	$(MDPROC) $(MDPARAMS_PDF)

html: markdown
	$(MDPROC) $(MDPARAMS_HTML)

latex: markdown
	$(MDPROC) $(MDPARAMS_TEX)

$(TARGET).md: $(SOURCE)
	python3 $(TRELLO2MD) $(SOURCE) $(PYPARAMS)
