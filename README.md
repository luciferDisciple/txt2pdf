# txt2pdf

## Description

A command line utility for converting txt files to pdf with the formatting
I like.

```
$ txt2pdf --help
usage: txt2pdf.sh [OPTION]... TEXTFILE
Produce pdf with the body text read from TEXTFILE.

-h, --help          display this help and exit
-d, --date=TEXT     use TEXT in the running header instead of
                    today's date

Output is typeset with monospaced font.
TEXTFILE must be encoded in UTF-8 and contain only characters
available in LATIN-2 charset.

Format of the date in the running header is chosen by checking
the value of LC_TIME environment variable. If the locale isn't
recognized, then %Y-%m-%D is used.
Format of the page mark in the running footer is chosen by
checking the value of LANG environment variable. If the value
isn't recognized, then the default is used, which is
PAGE_NUMBER / TOTAL_PAGES .
$
```

## Installation

Run `install.sh` script. It will place the script in one of the directories in
your `PATH` environment variable and copy other files, that the script depends
on.
