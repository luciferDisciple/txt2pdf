#/bin/bash

prog_name=${0##*/}
font_name=TeXGyreCursor-Regular9
input_fname=
output_fname=
date_string=
date_arg=
_25mm=70.866

usage () {
	echo "usage: $prog_name [OPTION]... TEXTFILE"
	echo "Produce pdf with the body text read from TEXTFILE."
	echo
	echo "-h, --help          display this help and exit"
	echo "-d, --date=DATE     use DATE in the running header instead of"
	echo "                    today's date"
	echo "-o, --output=FILE   write output to FILE instead of TEXTFILE.pdf"
	echo "-t, --title=TITLE   use TITLE as the title in the running"
	echo "                    header instead of the TEXTFILE"
	echo
	echo "Output is typeset with monospaced font."
	echo "TEXTFILE must be encoded in UTF-8 and contain only characters"
	echo "available in LATIN-2 charset."
	echo
	echo "Format of the date in the running header is chosen by checking"
	echo "the value of LC_TIME environment variable. If the locale isn't"
	echo "recognized, then %Y-%m-%D is used."
	echo "Format of the page mark in the running footer is chosen by"
	echo "checking the value of LANG environment variable. If the value"
	echo "isn't recognized, then the default is used, which is"
	echo "PAGE_NUMBER / TOTAL_PAGES ."
}

err_msg () {
	local message=$1
	echo "[$prog_name] $message" >&2
}

while :; do
	case $1 in
		-h|-\?|-help|--help)
			usage
			exit
			;;
		-d|--date)
			date_arg=$2
			date_string=$date_arg
			shift
			;;
		--date=?*)
			date_arg=${1#*=}  # remove everything up to first '='
			date_string=$date_arg
			;;
		-o|--output)
			output_arg=$2
			[[ -z "output_arg" ]] &&
				err_msg "Output file name must follow $1 option." &&
				exit 1
			output_fname=$output_arg
			shift
			;;
		--output=?*)
			output_arg=${1#*=} # remove everything up to first '='
			[[ -z "output_arg" ]] &&
				err_msg "Output file name must follow $1 option." &&
				exit 1
			output_fname=$output_arg
			;;
		--title=?*)
			title_arg=${1#*=}
			document_title=$title_arg
			;;
		-t|--title)
			title_arg=$2
			document_title=$title_arg
			shift
			;;
		*)
			break
	esac
	shift
done

input_fname="$1"

output_fname=${output_fname:-$intput_fname.pdf}

document_title=${document_title:-$input_fname}
document_title=$(echo $document_title | iconv --to-code LATIN2)

if [[ $document_title =~ \| ]]; then
	err_msg "Document title must not contain '|' character"
	exit 1
fi

[[ -z "$input_fname" ]] && err_msg "Input file not specified." && usage && exit
[[ ! -f "$input_fname" ]] && err_msg "File '$input_fname' doesn't exist." &&
	exit

[[ -z "$date_string" ]] &&
case "$LC_TIME" in
	pl_PL?*)
		date_string=$(date '+%-d %B %Y')
		;;
	en_US?*)
		date_string=$(date '+%B %-d, %Y')
		;;
	*)
		date_string=$(date +%F)
esac

case "$LANG" in
	en?*)
		page_mark_format='||Page $% of $='
		;;
	pl_PL?*)
		page_mark_format='||Strona $% z $='
		;;
	*)
		page_mark_format='||$%/$='
esac

date_string=$(echo "$date_string" | iconv --to-code LATIN2)
page_mark_format=$(echo "$page_mark_format" | iconv --to-code LATIN2)

iconv \
	--from-code UTF-8 \
	--to-code   LATIN2 \
	"$input_fname" \
	|
enscript \
	--font "$font_name" \
	--header-font "$font_name" \
	--fancy-header=txt2pdf \
	--header "$document_title||$date_string" \
	--margins $_25mm:$_25mm:$_25mm:$_25mm \
	--footer "$page_mark_format" \
	--word-wrap \
	--encoding latin2 \
	--output - \
	|
ps2pdf - "$output_fname"

# "--output -" for the enscript command is necessary to write to stdout
# "--fancy-header=simple2" option name and argument must be joined with
# '='. Won't work if separated with space. Bug in enscript?
