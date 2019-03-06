# RegionEditor

A macOS application for editing EPUB image metadata.

## Overview

The [EPUB Actions](https://github.com/rmenke/EPUB-Actions) Automator suite is designed to add region-based navigation to the generated EPUB comic book. The *Prepare Images for EPUB* action adds the extended attribute `com.the-wabe.regions` to each image processed to describe the panels of each comic page (“panel group”). For highly stylized graphics, the action will fail to detect all the panels or will display them out-of-order. This application may be used to correct those problems.

## Usage

Open an image processed by the *Prepare Images for EPUB* action. The regions detected will be displayed as an overlay on the image, and each region will be tagged by its reading order. Regions may be resized by dragging their edges and corners; they may also be reordered using the “Raise” and “Lower” menu items. New regions may be created by drawing a rectangle corner-to-corner over an *uncovered* portion of the image.

## Building

```lang=bash
xcodebuild DSTROOT=$HOME install
```

## Acknowledgements

The artwork for the icon was stolen shamelessly from [XKCD](https://xkcd.com) because I can’t even draw stick figures.
