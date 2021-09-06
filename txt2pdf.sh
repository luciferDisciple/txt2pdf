#/bin/bash

prog_name=${0##*/}
font_name=TeXGyreCursor-Regular9
input_fname=
_25mm=70.866

usage () {
	echo "usage: $prog_name TEXTFILE"
	echo "Produce pdf with the body text read from TEXTFILE."
	echo
	echo "Output is typeset with monospaced font."
	echo "TEXTFILE must be encoded in UTF-8 and contain only characters"
	echo "available in LATIN-2 charset."
}

err_msg () {
	local message=$1
	echo "[$prog_name] $message" >&2
}

input_fname="$1"

[[ -z "$input_fname" ]] && err_msg "Input file not specified." && usage && exit
[[ ! -f "$input_fname" ]] && err_msg "File '$input_fname' doesn't exist." &&
	exit

pl_months=(
	bad_index stycznia lutego marca kwietnia maja czerwca lipca sierpnia
	września października listopada grudnia
)
pl_current_month=${pl_months[$(date '+%-m')]}
date_string="$(date '+%-d') $pl_current_month $(date +%Y)"
date_string=$(echo "$date_string" | iconv --from-code UTF-8 --to-code LATIN2)

iconv \
	--from-code UTF-8 \
	--to-code   LATIN2 \
	"$input_fname" \
	|
enscript \
	--font "$font_name" \
	--header-font "$font_name" \
	--fancy-header=txt2pdf \
	--header "$input_fname||$date_string" \
	--margins $_25mm:$_25mm:$_25mm:$_25mm \
	--footer '||Strona $% z $=' \
	--word-wrap \
	--encoding latin2 \
	--output - \
	|
ps2pdf - "$input_fname".pdf

# "--output -" for the enscript command is necessary to write to stdout
# "--fancy-header=simple2" option name and argument must be joined with
# '='. Won't work if separated with space. Bug in enscript?
