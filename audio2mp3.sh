#!/bin/sh
#
# -----------------------------------------------------------------------------
# A simple MPEG-4 to MPEG-3 (audio) conversion wrapper using faad and lame.
# -----------------------------------------------------------------------------
#
# Inspired by the m4a2mp3 and FLAC conversion shell scripts from
# http://wiki.linuxquestions.org/wiki/.m4a_to_.mp3 and 
# https://wiki.archlinux.org/index.php/Convert_Flac_to_Mp3
#
# Dependencies:
#   * lame:  http://lame.sourceforge.net/
#   * faad2: http://www.audiocoding.com/ (optional)
#   * flac:  http://flac.sourceforge.net/ (optional)
#
# -----------------------------------------------------------------------------
# Copyright (C) 2011 by Jean Pierre Wenzel <jpwenzel@gmx.net>.
# -----------------------------------------------------------------------------

for DEPENDENCY in lame; do
	hash "${DEPENDENCY}" 2>&- || {
		echo >&2 "${DEPENDENCY} is required but not installed. Aborting."; 
		exit 1;
	}
done

for INPUT_FILENAME in "$@"; do
	BASE_FILENAME=${INPUT_FILENAME%.*}
	[ -z "${BASE_FILENAME}" ] && continue

	OUTPUT_FILENAME="${BASE_FILENAME}.mp3"
	TMP_INFO=$(mktemp "${BASE_FILENAME}-info")
 	TMP_OPTIONS=$(mktemp "${BASE_FILENAME}-options")
 	TMP_WAVE=$(mktemp "${BASE_FILENAME}-wave")
		
	# Extract info (artist, title, etc.) from source file.
	faad -i "${INPUT_FILENAME}" 2> "${TMP_INFO}"
	
	cat "${TMP_INFO}" | sed -n '
		s/[\"$]//g
		s/[\`$]//g
		s/^title: \(.*\)$/--tt "\1"/p
		s/^artist: \(.*\)$/--ta "\1"/p
		s/^album: \(.*\)$/--tl "\1"/p
		s/^track: \(.*\)$/--tn "\1"/p
		s/^date: \([12][0-9][0-9][0-9]\)$/--ty "\1"/p
		' > "${TMP_OPTIONS}"
	
	# Convert from source to wave format
	faad "${INPUT_FILENAME}" -o "${TMP_WAVE}"
	
	# Compress using lame
	xargs lame -V2 --vbr-new "${TMP_WAVE}" "${OUTPUT_FILENAME}" < "${TMP_OPTIONS}"
	
	rm -f "${TMP_INFO}" "${TMP_OPTIONS}" "${TMP_WAVE}"
done