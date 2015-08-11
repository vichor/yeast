#!/bin/bash
#
# ybuild.sh
#
# Builds Yeast product getting the yocto framework from the specified directory.
#
# Parameters
#       -d <name>   mandatory   Use directory <name> as yocto framework
#       -h          optional    Get help
#
# Author: Victor Garcia
# Licensing: See Yeast license file
#
# TODO:
#   1. Set an appropriate target. Right now, basic rpi.
#

THIS=$(basename $0)

# This is the target which will be built. To be updated later on
TARGET=rpi-hwup-image

help () {
    # Prints the help
    echo
    echo "$THIS [-d <directory>] [ [-k] ] | [-h]"
    echo "Builds Yeast from the specified yocto framework directory."
    echo "Parameters:"
    echo "    -d  Yocto framework directory."
    echo "    -h  When supplied, the script will show this message and exit."
    echo
}
    
# Read script parameters. Abort when unknown.
OPT_HELP=false
OPT_YDIR=''
while getopts "hd:" opt
do
    case "$opt" in
        h)
            OPT_HELP=true
            ;;
        d)
            # read opt argument from command line
            OPT_YDIR=${OPTARG}
            OPT_BDIR=$OPT_YDIR/build
            ;;
        *)
            # Unknown parameter. Call to getopts already prints message
            help
            exit 1
    esac
done
shift $(expr $OPTIND - 1)

# When help, print and exit
if "$OPT_HELP" ; then
    help
    exit 0
fi

# Check parameter consistency
if [ -z "$OPT_YDIR" ] ; then
    echo "You need to supply a directory name (use -d option)."
    exit 1
fi

# Check framework
if [ ! -d $OPT_YDIR ] ; then
    echo "Supplied directory does not exist. Did you run gettoolchain.sh?"
    exit 1
fi
if    [ ! -d ${OPT_BDIR}/conf ] \
   || [ ! -f ${OPT_BDIR}/conf/bblayers.conf ] \
   || [ ! -f ${OPT_BDIR}/conf/local.conf ] \
   || [ ! -f ${OPT_BDIR}/conf/templateconf.cfg ] ; then
    echo "Build directory does not seem to be correct. Rerun setupdir.sh."
    exit 1
fi
    
# Run yocto
PATHBACKUP=$PATH
source fixpath.sh
pushd ${OPT_YDIR}
source oe-init-build-env build
bitbake $TARGET
popd
PATH=$PATHBACKUP
