audio2mp3
=======
audio2mp3 is a wrapper tool using `faad` and `lame` to convert audio files (MPEG-4, WAVE, OGGi, FLAC) to MPEG-3 audio.

Why?
====
When I imported my audio CDs into iTunes, I decided to use the MPEG-4 audio format. Good choice as long as I was listening to music on my iPod, but unfortunately, my car stereo only plays MP3 files. Therefore, I had to find a way to simply convert the M4A files to MP3s before burning them on a CD…

Installation
============
Simply copy the `audio2mp3.sh` file whereever you want -- preferably anywhere your `$PATH` points to. Make sure its executable bit(s) are set.

Dependencies
============
`audio2mp3` is acting as a wrapper for these tools:

* faad2: http://www.audiocoding.com/
* lame:  http://lame.sourceforge.net/

Usage
=====
You can use the `audio2mp3.sh` script either with a single M4A file or a list of files:

`audio2mp3.sh [audio file(s)…]`

Examples:

* `audio2mp3.sh Bohemian_Rhapsody.m4a`
* `audio2mp3.sh *.m4a`

Acknowledgements
================
The `audio2mp3` script is based on the `m4a2mp3` shell script I found at
http://wiki.linuxquestions.org/wiki/.m4a_to_.mp3

Unfortunately, that script does not provide any information about the initial author. If you happen to know them, please drop me a line so I can include their name here.
