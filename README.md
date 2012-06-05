midihid-rockband
================

A MidiHID script for Rock Band 2 drums

[MidiHID](http://code.google.com/p/midihid/) is a program for Mac OS X which
allows you to map inputs from a USB HID device to any software that can use
MIDI inputs.

This script is written for MidiHID for a Rock Band 2 drum set with the cymbal
attachments and a second foot pedal (mapped to the high-hat). Due to the
complex output of a Rock Band 2 drum set, most standalone MIDI mapping programs
are too naive to use the features such as cymbal attachments or the second foot
pedal. 

For instance, the green drum pad and the green cymbal each individually
generates three HID outputs, two of which are the same but the third is
specific to each. This script correctly differentiates between the two and
outputs a different MIDI note for the two events.

TODO
----
* Fix bug regarding incorrect notes when HID events are interleaved
* Cleanly separate the output MIDI notes for cleaner customization
* Create a MIDI note event for pressing/releasing high-hat pedal by itself
* Add a mode for double bass with the hi hat
