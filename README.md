# Trello2md #

This script converts JSON exports from [Trello](http://trello.com) to
[Markdown](http://daringfireball.net/projects/markdown/basics). The resulting file can then be
translated further to other formats such as PDF or HTML using a Markdown editor (like
[this](https://stackedit.io/#) or converter (like [Pandoc](http://johnmacfarlane.net/pandoc/)).

To use the script, you need to have installed [Python 3](https://www.python.org/download). Then,
from a terminal, you can type the following:

    python3 ./src/trello2md.py inputfile.json
    
This will generate a file `inputfile.md`, containing a section for each list, and subsections for
each cards. 

Markdown used inside cards is preserved, except that section headings on cards are converted down to
lower subsections to keep the logical structure (although, this is currently only done for
[Atx-style headers](http://johnmacfarlane.net/pandoc/README.html#atx-style-headers)). Attachments on
cards are converted to links to the original documents on Trello's servers. Checklists are converted
to bullet lists and prepended the phrase "Checklist:", to distinguish them from subsections
containing ordinary lists. Archived lists and cards are filtered out by default.

There are currently two additional arguments:

- `--labels` adds a card's labels to its heading
- `--archived` also includes archived lists and cards.
- `--header` prepends a header page with general information about the board.

More options are planned.

## Using the makefile ##

There is a prepared workflow in form of a makefile, set up for using the script in combination with
Pandoc. The following `make` targets are provided:

- `markdown`
- `pdf`
- `html`
- `latex`

The `all` target is `markdown`. By default, the custom LaTeX template located in `tex/trello.latex`
is provided to Pandoc, which currently only inserts page breaks between lists/sections.

To customize the workflow, you can change the `PYPARAMS` macro to give `trello2md` additional
arguments, or mess around with the `MDPARAMS` to change Pandoc's (or you Markdown converter's)
behaviour.

The path to the file you want to convert can be set by the `SOURCE` macro. So, a typical call of the
makefile will look somehow like this:

    make pdf SOURCE=path/to/file.json

## Todo ##

- Option to include comments
- Option to quote out all LaTeX commands in the input
- Recognize heading syntax with underlines ("setext")

## Licence ##

All code is [unlicensed](http://unlicense.org/), except for the template in `tex/trello.latex`,
which is [included](https://github.com/jgm/pandoc/blob/master/COPYRIGHT) in Pandoc and thus subject
to the GPL.
