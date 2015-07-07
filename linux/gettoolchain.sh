#!/bin/sh
#
# gettoolchain.sh
#
# Gets, using git, the poky framework to have a complete toolchain to build
# the linux distribution for Yeast.
#
# Parameters
#       -h  optional    Get help
#       -k  optional    Keep the log file when finished successfully
#
# Author: Victor Garcia
# Licensing: See Yeast license file
#
# TODO: 
#   1. Copiar la metalayer rtl8188eu en ese directorio.
#   2. Editar las layers para trabajar para la rasp 2.

THIS=$(basename $0)

help () {
    # Prints the help
    echo "$THIS [-d <directory>] [ [-k] ] | [-h]"
    echo "Gets the toolchain needed to build the Yeast Linux Distribution."
    echo "Parameters:"
    echo "\t-d\tOutput directory."
    echo "\t-h\tWhen supplied, the script will show this message and exit."
    echo "\t-k\tKeep the log file even when the script finishes successfully."
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
            echo "Unknown parameter " $opt
            help
            exit 1
    esac
done
shift $(expr $OPTIND - 1)

# Check parameter consistency
if [ -z "$OPT_OUTDIR" ] ; then
    echo "You need to supply a directory name."
    exit 1
fi
    
# When help, print and exit
if "$OPT_HELP" ; then
    help
    exit 0
fi

# Initialize log file
rm $LOGFILE
touch $LOGFILE

# Create work directories
echo -n "Creating work directory ${OPT_OUTDIR}... "
mkdir ${OPT_OUTDIR} 2>> $LOGFILE
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
mkdir ${OPT_OUTDIR}/build 2>> $LOGFILE
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

# Remove log file by default
if "$OPT_KEEPLOG" ; then echo "Log file: $LOGFILE" 
fi

echo "Ready to build Yeast Linux distribution. You may run now linbuild.sh"

