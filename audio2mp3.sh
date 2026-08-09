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
# Copyright (C) 2011-2026 Jean Pierre Wenzel <jpwenzel@gmx.net>.
# -----------------------------------------------------------------------------

for DEPENDENCY in lame faad AtomicParsley; do
	hash "${DEPENDENCY}" 2>&- || {
		echo >&2 "${DEPENDENCY} is required but not installed. Aborting.";
		exit 1;
	}
done

FIX_FILENAME=0
QUALITY="high"
while [[ $# -gt 0 ]]; do
	case "$1" in
		--fix-filename)
			FIX_FILENAME=1
			shift
			;;
		--quality)
			if [[ -z "$2" ]]; then
				echo >&2 "--quality requires an argument (high, medium, podcast)"
				exit 1
			fi
			QUALITY="$2"
			shift 2
			;;
		--)
			shift
			break
			;;
		-*)
			echo >&2 "Unknown option: $1"
			exit 1
			;;
		*)
			break
			;;
	esac
done

case "$QUALITY" in
	high)
		LAME_QUALITY_ARGS=(--vbr-new -V 0)
		;;
	medium)
		LAME_QUALITY_ARGS=(--vbr-new -V 5)
		;;
	podcast)
		LAME_QUALITY_ARGS=(-a --vbr-new -V 7)
		;;
	*)
		echo >&2 "Unknown quality preset: ${QUALITY} (expected: high, medium, podcast)"
		exit 1
		;;
esac

if [[ -z "$1" ]]; then
	echo >&2 "Usage: $(basename "$0") [--fix-filename] [--quality high|medium|podcast] <input file>"
	exit 1
fi
INPUT_FILENAME="$1"
# Prevent leading-dash filenames from being parsed as options by file/faad/lame
[[ "$INPUT_FILENAME" == -* ]] && INPUT_FILENAME="./${INPUT_FILENAME}"

# Currently, only conversion from MPEG-4 audio to MP3 is supported
INPUT_FILE_TYPE=$(file --mime-type -b "$INPUT_FILENAME")
if [[ "audio/x-m4a" != "$INPUT_FILE_TYPE" ]] ; then
	echo "Sorry, only MPEG-4 audio is currently supported as input file."
	echo "Input file is of type: $INPUT_FILE_TYPE"
	exit 1;
fi

BASE_FILENAME="${INPUT_FILENAME%.*}"
[[ "1" == "$FIX_FILENAME" ]] &&	BASE_FILENAME="${BASE_FILENAME//[^\ \(\)\[\]A-Za-z0-9._\',!\&-]/_}"

OUTPUT_FILENAME="${BASE_FILENAME}.mp3"
TMP_WAVE_FILE=$(mktemp "${TMPDIR:-/tmp}/audio2mp3.XXXXXXXXX")
trap 'rm -f "${TMP_WAVE_FILE}"' EXIT

# Gather audio file meta information
PREV_LC_ALL=$LC_ALL
export LC_ALL=C
ATOMIC_PARSLEY_TAGS=$(AtomicParsley "${INPUT_FILENAME}" -t)
# Strip the UTF-8 BOM AtomicParsley prepends to its output, which otherwise
# breaks the anchored "^Atom ..." match on the first tag line
ATOMIC_PARSLEY_TAGS="${ATOMIC_PARSLEY_TAGS#$'\xef\xbb\xbf'}"
MP3_TAG_TITLE=$(grep '©nam' <<< "$ATOMIC_PARSLEY_TAGS" | sed -e 's/^Atom "©nam" contains: //g')
MP3_TAG_ARTIST=$(grep '©ART' <<< "$ATOMIC_PARSLEY_TAGS" | sed -e 's/^Atom "©ART" contains: //g')
MP3_TAG_ALBUM=$(grep '©alb' <<< "$ATOMIC_PARSLEY_TAGS" | sed -e 's/^Atom "©alb" contains: //g')
MP3_TAG_TRACK=$(grep 'trkn' <<< "$ATOMIC_PARSLEY_TAGS" | sed -e 's/^Atom "trkn" contains: //g' | grep -E -o '^\d*')
MP3_TAG_DATE=$(grep '©day' <<< "$ATOMIC_PARSLEY_TAGS" | sed -e 's/^Atom "©day" contains: //g')
export LC_ALL=$PREV_LC_ALL

LAME_ARGS=(\
--tt "$MP3_TAG_TITLE" \
--ta "$MP3_TAG_ARTIST" \
--tl "$MP3_TAG_ALBUM" \
--tn "$MP3_TAG_TRACK" \
--ty "$MP3_TAG_DATE" \
)

# Convert from source to wave format
if ! faad "${INPUT_FILENAME}" -o "${TMP_WAVE_FILE}"; then
	echo >&2 "faad failed to decode ${INPUT_FILENAME}. Aborting."
	exit 1
fi

# Compress using lame
if ! lame -v "${LAME_QUALITY_ARGS[@]}" "${TMP_WAVE_FILE}" "${OUTPUT_FILENAME}" "${LAME_ARGS[@]}"; then
	echo >&2 "lame failed to encode ${OUTPUT_FILENAME}. Aborting."
	exit 1
fi
