# [Homebrew Tap for Mutt patches](https://el-tramo.be/homebrew-mutt)

## About

This repository is a tap for Homebrew for providing Mutt with my own 
selection of patches, adapted to compile against the latest version of Mutt.

These patches currently are:
- `gmail-custom-search`: Support for server-side GMail search (Phil Pennock)
- `gmail-labels`: Support for displaying GMail labels in the index (Serge Gerhardt)
- `mutt-trashfolder`: Support for a trash folder (Cedric Duval)

## Installation

To add this tap, run

    brew tap remko/homebrew-mutt

To install Mutt, run

    brew install remko/mutt/mutt --with-trash-patch --with-gmail-custom-search-patch --with-gmail-labels-patch

