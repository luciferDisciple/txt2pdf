#!/bin/bash

data_dir="$HOME/.local/share/txt2pdf"
enscript_profile="$HOME/.enscriptrc"

dependencies=(
	iconv
	enscript
	ps2pdf
)

for dep in "${dependencies[@]}"; do
	type $dep &>/dev/null || {
		echo "Dependency not satisfied: $dep. Aborting.";
		exit 1
	}
done

IFS=: paths=($PATH)

echo "Where do you want to place the script?"
select chosen_dir in "${paths[@]}" quit; do
	[[ "$chosen_dir" == quit ]] && exit 1
	[[ -z "$chosen_dir" ]] && continue
	read -p "Do you want to put txt2pdf script '$chosen_dir'? [Y/n] " \
		confirm_choice
	[[ "$confirm_choice" != Y ]] &&
		[[ "$confirm_choice" != y ]] &&
		continue
	if [[ -e "$chosen_dir"/txt2pdf ]]; then
		echo "File '$chosen_dir/txt2pdf' exists."
		read -p "Do you want to overwrite it? [Y/n] " overwrite
		[[ "$overwrite" != Y ]] && [[ "$overwrite" != y ]] && continue
		rm "$chosen_dir"/txt2pdf || continue
	fi
	cp 'txt2pdf.sh' "$chosen_dir"/txt2pdf
	break
done

if [[ ! -e "$data_dir" ]]; then
	mkdir "$data_dir"
fi

echo "Installing fonts to '$data_dir'"
cp -r resources/fonts "$data_dir"

echo "Creating font map for enscript"
(cd "$data_dir/fonts"; mkafmmap *.afm &>/dev/null ||
	echo 'An error occured while creating enscript font map. Aborting.'
) || exit 1

echo "Copying enscript library"
enscript_lib="$data_dir"/enscript_library
[[ -e "$enscript_lib" ]] && { rm -r "$enscript_lib" || exit 1; }
cp -r resources/enscript_lib "$enscript_lib"

if [[ -e "$HOME/.enscriptrc" ]]; then
	echo "Found existing enscript configuration file."
	enscriptrc_bak="$enscript_profile".`date +%Y%m%d%H%M%S`.bak
	echo "Moving '$enscript_profile' to '$enscriptrc_bak'"
	mv "$enscript_profile" "$enscriptrc_bak"
fi

echo "Creating '$enscript_profile'"

echo "Clean7Bit: 0" >>"$enscript_profile"
echo "AFMPath: $data_dir/fonts:/usr/local/share/enscript" >>"$enscript_profile"
echo "LibraryPath: $enscript_lib:/usr/share/enscript:$HOME/.enscript" >> "$enscript_profile"

echo 'Installation complete'
