audio2mp3
=========
audio2mp3 is a wrapper tool using various applications such as `faad`, `flac`, and `lame` to convert audio files from different formats (WAV, FLAC, MPEG-4) to MPEG-3 audio.

Why?
====
When I imported my audio CDs into iTunes, I decided to use the MPEG-4 audio format. Good choice as long as I was listening to music on my iPod, but unfortunately, my car stereo only plays MP3 files. Therefore, I had to find a way to simply convert the M4A files to MP3s before burning them on a CD…

After a short while I thought — why not use the same mechanism to convert my FLAC files? So I renamed the project (it used to be called *m4a2mp3* before).

Installation
============
Simply copy the `audio2mp3.sh` file whereever you want -- preferably anywhere your `$PATH` points to. Make sure its executable bit(s) are set.

Dependencies
============
`audio2mp3` is acting as a wrapper for these tools:

* faad2: http://www.audiocoding.com/
* flac: http://flac.sourceforge.net/
* lame:  http://lame.sourceforge.net/

Usage
=====
You can use the `audio2mp3.sh` script either with a single audio input file or a list of files:

`audio2mp3.sh [audio file(s)…]`

Examples:

* `audio2mp3.sh Bohemian_Rhapsody.m4a`
* `audio2mp3.sh *.m4a`
* `audio2mp3.sh Aida_Marcha_Triunfal.wav Ride_of_the_Valkyries.flac`

Acknowledgements
================
The `audio2mp3` script is based on the `m4a2mp3` shell script I found at
http://wiki.linuxquestions.org/wiki/.m4a_to_.mp3

The FLAC work was inspired by the script that can be found at
https://wiki.archlinux.org/index.php/Convert_Flac_to_Mp3

Unfortunately, those websites do not provide any information about the initial authors. If you happen to know them, please drop me a line so I can include their names here.
