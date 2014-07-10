#!/usr/bin/python3

""" 
Terminal program to convert Trello's json-exports to markdown.
"""

import sys
import argparse
import json

################################################################################
def unlines(line):
    """Remove all newlines from a string."""

    return line.translate(str.maketrans('\n', ' '))

################################################################################
def prepare_content(content):
    """Prepare nested markdown in content of a card."""

    # correct heading levels 
    result = []
    for line in content.splitlines():
        if line.startswith('##') and line.endswith('##'):
            result.append('##{0}##\n'.format(unlines(line)))
        elif line.startswith('#') and line.endswith('#'):
            result.append('##{0}##\n'.format(unlines(line)))
        else:
            result.append(line + '\n')
    
    return ''.join(result)

################################################################################
def print_card(card_id, data, print_labels, print_card_links):
    """Print name, content and attachments of a card."""

    # get card and pre-format content
    card = next(c for c in data['cards'] if c['id'] == card_id)
    content = prepare_content(card['desc']) + '\n'

    # format labels, if wanted
    labels = []
    if print_labels and card['labels']:
        labels.append('(')

        for n, label in enumerate(card['labels']):
            separator = ', ' * bool(n) # only for n > 0
            label_string = '{sep}_{lbl}_'.format(\
              lbl=(label['name'] or label['color']), \
              sep=separator)
            labels.append(label_string)

        labels.append(') ')
    labels_string = ''.join(labels)

    # format attachments
    links = ((unlines(attm['name']), attm['url']) for attm in card['attachments'])
    attachments = ('[{0}]({1})'.format(name, url) for name, url in links)
    attachments_string = '\n\n'.join(attachments) + '\n'

    # put it together
    return '## {name} {lbls}##\n{cntnt}\n{attms}\n'.format( \
                                          name=unlines(card['name']), \
                                          cntnt=content, \
                                          attms=attachments_string, \
                                          lbls=labels_string)

################################################################################
def print_checklists(card_id, data):
    """Print a checklist as subsection with itemize."""

    card = next(c for c in data['cards'] if c['id'] == card_id)

    result = []
    for cl_id in card['idChecklists']:
        checklist = next(cl for cl in data['checklists'] if cl['id'] == cl_id)
        items_string = '\n'.join('- ' + item['name'] for item in checklist['checkItems'])
        result.append('### Checklist: {name} ###\n{items}'.format(name=checklist['name'], \
                                                     items=items_string))

    result.append('\n\n')
    return '\n\n'.join(result)

################################################################################
def main():
    # HELP_MESSAGE = 'Usage: trello2md.py <inputfile> ' \
    #                '[--labels] [--card-links] [--archived]'

    # try:
    #     opts, args = getopt.getopt(sys.argv[1:], 'hl', \
    #                                ['help', 'labels', 'card-links', 'archived'])
    # except getopt.GetoptError as e:
    #     print(e)
    #     print(HELP_MESSAGE)
    #     sys.exit(2)

    # inputfile, outputfile = None, None
    # print_labels, print_card_links, print_archived = False, False, False

    # for opt, arg in opts:
    #     if opt == '-h' or opt == '--help':
    #         print(HELP_MESSAGE)
    #         sys.exit()
    #     elif opt == '--labels':
    #         print_labels = True
    #     elif opt == '--card-links':
    #         print_card_links = True
    #     elif opt == '--archived':
    #         print_archived = True
    #     else:
    #         inputfile = arg

    # if not (inputfile):
    #     sys.exit(HELP_MESSAGE)
    parser = argparse.ArgumentParser(description='Convert a JSON export from Trello to Markdown.')
    parser.add_argument('inputfile', help='Path to the input JSON file')
    parser.add_argument('-l', '--labels', help='Print card labels', action='store_true')
    parser.add_argument('-a', '--archived', help='Don\'t ignore archived lists', action='store_true')
    parser.add_argument('-c', '--card-links', help='(Currently not implemented)', action='store_true')

    args = parser.parse_args()

    # load infile to 'data'
    try:
        with open(args.inputfile, 'r') as inf:
            data = json.load(inf)
    except IOError as e:
        sys.exit("I/O error({0}): {1}".format(e.errno, e.strerror))

    # process all lists in 'data'
    markdown = []
    for lst in data['lists']:
        if lst['closed'] and not args.archived:
            continue
        else:
            # list header
            markdown.append('# {0} #\n\n'.format(unlines(lst['name'])))

            # process all cards in current list
            for card in data['cards']:
                if (not card['closed'] or args.archived) and (card['idList'] == lst['id']):
                    markdown.append(print_card(card['id'], \
                                               data, \
                                               args.labels, \
                                               args.card_links))
                    markdown.append(print_checklists(card['id'], data))

    # save result to file
    outputfile = args.inputfile.replace('.json', '.md')
    if outputfile == args.inputfile:
        outputfile += '.md'

    try:
        with open(outputfile, 'w') as of:
            of.write(''.join(markdown))

        print('Sucessfully translated!')

        if args.card_links:
            print('Option --card-links is currently unimplemented and ignored.')

    except IOError as e:
        sys.exit("I/O error({0}): {1}".format(e.errno, e.strerror))

################################################################################
if __name__ == '__main__':
    main()

