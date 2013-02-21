# basic-ios-slides

This is a set of slides giving an overview of iOS programming for existing programmers.

The Objective-C slides were prepared for the 2013 Parse.ly retreat, and the games slides were prepared for a presentation I gave at Pace University in spring 2013.

## View the slides online

Slides can be viewed in compiled form at:

http://emmettbutler.com/basic-ios-slides/

and

http://emmettbutler.com/basic-ios-slides/games.html

Note that the slides can be controlled as follows:

 * Advance forward / back with the forward and back keys, or left click / right click of the mouse
 * Press `c` to get the "controls", which also allows you to skip slides and switch to outline mode
 * Outline mode includes some notes not included in the slidedeck, and also allows you to easily copy/paste examples into your own interpreter

## How this was built

I wrote the slides using [reST](http://docutils.sourceforge.net/rst.html), and specifically Docutils [support for S5 export](http://docutils.sourceforge.net/docs/user/slide-shows.html). Scripts are included to compile the presentation from the index.rst file and also to allow development of new slides with live recompilation using pyinotify (Linux systems only). See `build.sh` and `monitor.sh` for more information.
