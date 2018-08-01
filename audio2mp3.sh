#!/bin/bash
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
#   * lame:          http://lame.sourceforge.net/
#   * faad2:         http://www.audiocoding.com/
#   * AtomicParsley: http://atomicparsley.sourceforge.net/
#
# -----------------------------------------------------------------------------
# Copyright (C) 2011-2018 Jean Pierre Wenzel <jpwenzel@gmx.net>.
# -----------------------------------------------------------------------------
SANITZE_FILENAME=1

for DEPENDENCY in lame faad AtomicParsley; do
	hash "${DEPENDENCY}" 2>&- || {
		echo >&2 "${DEPENDENCY} is required but not installed. Aborting.";
		exit 1;
	}
done

INPUT_FILENAME="$1"

# Currently, conversion from MPEG-4 audio to MP3 is supported only
INPUT_FILE_TYPE=$(file --mime-type -b "$INPUT_FILENAME")
if [[ "audio/x-m4a" != "$INPUT_FILE_TYPE" ]] ; then
	echo "Sorry, only MPEG-4 audio is currently supported as input file."
	echo "Input file is of type: $INPUT_FILE_TYPE"
	exit 1;
fi

BASE_FILENAME="${INPUT_FILENAME%.*}"
[[ "1" == "$SANITZE_FILENAME" ]] &&	BASE_FILENAME="${BASE_FILENAME//[^\ \(\)\[\]A-Za-z0-9._-]/_}"

[ -z "${BASE_FILENAME}" ] && continue

OUTPUT_FILENAME="${BASE_FILENAME}.mp3"
TMP_WAVE_FILE=$(mktemp "${TMPDIR:-/tmp}/audio2mp3.XXXXXXXXX")

# Gather audio file meta information
PREV_LC_ALL=$LC_ALL
export LC_ALL=C
MP3_TAG_TITLE=$(AtomicParsley "${INPUT_FILENAME}" -t | grep '©nam' | sed -e 's/^Atom "©nam" contains: //g')
MP3_TAG_ARTIST=$(AtomicParsley "${INPUT_FILENAME}" -t | grep '©ART' | sed -e 's/^Atom "©ART" contains: //g')
MP3_TAG_ALBUM=$(AtomicParsley "${INPUT_FILENAME}" -t | grep '©alb' | sed -e 's/^Atom "©alb" contains: //g')
MP3_TAG_TRACK=$(AtomicParsley "${INPUT_FILENAME}" -t | grep 'trkn' | sed -e 's/^Atom "trkn" contains: //g' | egrep -o '^\d*')
MP3_TAG_DATE=$(AtomicParsley "${INPUT_FILENAME}" -t | grep '©day' | sed -e 's/^Atom "©day" contains: //g')
export LC_ALL=$PREV_LC_ALL

LAME_ARGS=(\
--tt "$MP3_TAG_TITLE//&/\&" \
--ta "$MP3_TAG_ARTIST//&/\&" \
--tl "$MP3_TAG_ALBUM//&/\&" \
--tn "$MP3_TAG_TRACK" \
--ty "$MP3_TAG_DATE" \
)

# Convert from source to wave format
faad "${INPUT_FILENAME}" -o "${TMP_WAVE_FILE}"

# Compress using lame
lame -v -V 2 -b 128 "${TMP_WAVE_FILE}" "${OUTPUT_FILENAME}" "${LAME_ARGS[@]}"

rm "${TMP_WAVE_FILE}"
