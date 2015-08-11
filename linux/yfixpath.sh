#!/bin/bash
#
# Removes . from PATH so that bitbake does not complain
# This files needs to be sourced to work:
#   $ source fixpath.sh
#
# Author: Victor Garcia
# License: see Yeast license file.
#

export PATH=`echo $PATH | sed "s/:\.:/:/g"`
export PATH=`echo $PATH | sed "s/^\.://g"`
