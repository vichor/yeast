#!/bin/sh
#
# yprepare.sh
#
# Gets, using git, the poky framework to have a complete toolchain to build
# the linux distribution for Yeast.
#
# Parameters
#       -d <name>   mandatory   Use directory <name> as output
#       -h          optional    Get help
#       -k          optional    Keep the log file when finished successfully
#
# Author: Victor Garcia
# Licensing: See Yeast license file
#
# TODO: 
#   1. DONE--Copy yoctocfg files into the yocto destination directory. Edit the
#            bblayers.conf file to set the proper absolute path there.
#   2. Copy the rtl8188eu metalayer in the output directory.
#   3. Automatically patch downloaded layers as needed.
#      Or may it be better to have readied a yocto layer just to patch it?
#   4. Create ybuild.sh script which bitbakes the yeast project.

THIS=$(basename $0)

help () {
    # Prints the help
    echo
    echo "$THIS [-d <directory>] [ [-k] ] | [-h]"
    echo "Gets the toolchain needed to build the Yeast Linux Distribution."
    echo "Parameters:"
    echo "    -d  Output directory."
    echo "    -h  When supplied, the script will show this message and exit."
    echo "    -k  Keep the log file even when the script finishes successfully."
    echo
}
    
LOGFILE=$(echo ${THIS} | cut -d. -f1)".log"

# Read script parameters. Abort when unknown.
OPT_HELP=false
OPT_KEEPLOG=false
OPT_OUTDIR=''
while getopts "hkd:" opt
do
    case "$opt" in
        h)
            OPT_HELP=true
            ;;
        k)
            OPT_KEEPLOG=true
            ;;
        d)
            # read opt argument from command line
            OPT_OUTDIR=${OPTARG}
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
if [ -z "$OPT_OUTDIR" ] ; then
    echo "You need to supply a directory name (use -d option)."
    exit 1
fi
    
# Initialize log file
rm -f $LOGFILE
touch $LOGFILE

# Create work directories
echo -n "Creating work directory ${OPT_OUTDIR}... "
mkdir ${OPT_OUTDIR} 2>> $LOGFILE 2>&1
if [ $? -ne 0 ] ; then 
    echo "error, see $LOGFILE file."
    exit 1
fi
echo "done"

# Use git to get the needed toolchain objects. Exit when error detected
# Use a shallowed clone to save bandwidth and storage (only HEAD will be
# retrieved using --depth 1).
echo -n "Getting poky... "
git clone --depth 1 git://git.yoctoproject.org/poky.git $OPT_OUTDIR >> $LOGFILE 2>&1
if [ $? -ne 0 ] ; then
    echo "error, see $LOGFILE file."
    exit 1
fi
echo "done"

echo -n "Creating build directory... "
BUILD_DIR=${OPT_OUTDIR}/build 
mkdir ${BUILD_DIR} 2>> $LOGFILE 2>&1
if [ $? -ne 0 ] ; then 
    echo "error, see $LOGFILE file."
    exit 1
fi
echo "done"

echo -n "Getting raspberry layer... "
git clone --depth 1 git://git.yoctoproject.org/meta-raspberrypi $OPT_OUTDIR/meta-raspberrypi >> $LOGFILE 2>&1
if [ $? -ne 0 ] ; then
    echo "error, see log file"
    exit 1
fi
echo "done"

echo -n "Getting yeast layers... "
echo "TODO"

# Setting up build directory
echo -n "Setting up build directory... "
base/ysetupdir.sh -b ${BUILD_DIR} -y $OPT_OUTDIR >> $LOGFILE 2>&1
if [ $? -ne 0 ] ; then
    echo "error, see log file"
    exit 1
fi
echo "done"

# Remove log file by default
if "$OPT_KEEPLOG" ; then echo "Log file: $LOGFILE" 
else echo "Removing log file: $LOGFILE" && rm -r $LOGFILE
fi

echo "Ready to build Yeast Linux distribution."

