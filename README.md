iPhone Game Demo
================

This repository contains a git-based walkthrough teaching iPhone video game
creation using box2d and cocos2d. It teaches the paradigms these libraries use
for handling sprite animation, rigid body physics, collision handling, and
more. The iPhoneGameDemo subdirectory contains the project files. The
iOS-Slides directory contains a supplemental presentation on Objective-C
programming and game development.

Step-by-step
============

How to get up and running with this project
Download/update XCode 4 from the mac app store

Download and install Git from http://git-scm.com/download/mac

Download and install Zwoptex from http://www.zwopple.com/zwoptex/

Open Terminal and type

    mkdir git
    cd git
    git clone https://github.com/emmett9001/iPhoneGameDemo.git

Open Finder, navigate to <yourname>/git/iPhoneGameDemo

Open iPhoneGameDemo.git with XCode

In the top left menu, select iPhone 6.0 simulator

Apple+R (or play button) to test

Directory Structure
===================

This repository consists of two main parts:

* The `iOS-Slides` directory contains a ReST slide presentation presenting the basics of iOS game dev
* The `iPhoneGameDemo` directory contains the source code for the demo project

Working with Git
================

Cloning
-------
The first thing you'll need to do is copy this repository to your computer.
Using Mac Terminal (Applications/Utilities/Terminal), `cd` into a directory
where you'll keep your XCode projects, like

    mkdir git
    cd git

Then, `clone` the repository to copy it onto your system.

    git clone https://github.com/emmett9001/iPhoneGameDemo.git

Once you've cloned, you can open `iPhoneGameDemo.xcodeproj` in XCode and run
the project.

Checking out commits
--------------------
This project is set up so you can skip forward and back in the
change history to see different stages of development. This is especially
helpful in a group setting where you don't want to fall behind. Git provides
a command `checkout` to allow users to jump to any commit. Normally you would
use a commit hash to do this, like

    git checkout a42250e69add9e696a2de06f6e644731f66944ce

That would take you back in time to the moment immediately after you committed
those changes. Obviously this is a little cumbersome. It would be nicer to be
able to reference the commit based on its semantic content, with a name.
That's how this project is set up.

Using `git tag` will show you a list of tags I've created. Each one references
an important stage of our app's development. To use one, you would type

    git checkout 2_walls

to jump to the point in the code where walls have just been added to the empty
project landscape.

If you're following along and making your own version, you might run into
trouble when you try to checkout a tagged commit. To avoid this, you can
always use

    git stash  # remove and save my changes
    git checkout <tagname>  # go to a commit
    git stash pop  # replay my changes on top of the commit

This will save your custom changes and apply them to the checked out commit.

To return to the current (latest) state of the repository, just use

    git stash
    git checkout master
