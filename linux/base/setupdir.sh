#!/bin/bash
#
# Updates any absolute path reference found in the different yocto configuration
# files.

THIS=$(basename $0)

help () {
    # Prints the help
    echo
    echo "$THIS -b <directory> -y <directory> [-f] | [-h]"
    echo "This creates a base yocto build directory. It uses a template base"
    echo "directory and copies the files in there into the supplied destination."
    echo "The template files contain the string <PATH> that will be replaced by"
    echo "the absolute path of the destination directory."
    echo
    echo "Parameters:"
    echo "    -b  Specifiy a build output directory."
    echo "    -f  Forces overwritting. Removes build directory if it exists."
    echo "    -h  When supplied, the script will show this message and exit."
    echo "    -y  Specifiy yocto framework working directory."
    echo
}

# Get parameters
OPT_HELP=false
OPT_DIR=''
OPT_WORK=''
OPT_FORCE=false
while getopts "hfb:y:" opt
do
    case "$opt" in
        h)
            OPT_HELP=true
            ;;
        b)
            OPT_DIR=${OPTARG}
            ;;
        y)
            OPT_WORK=${OPTARG}
            ;;
        f)
            OPT_FORCE=true
            ;;
        *)
            echo "Wrong command. See help below."
            help
            exit 1
    esac
done
shift $(expr $OPTIND - 1)

# Help and exit if requested
if "$OPT_HELP"; then
    help
    exit 0
fi

# Check mandatory opts
if [ -z "$OPT_DIR" ] ; then
    echo "You need to supply a build output directory name (use -b option)."
    exit 1
fi
if [ -z "$OPT_WORK" ] ; then
    echo "You need to supply a yocto framework directory name (use -y option)."
    exit 1
fi

# Calculate input and output directories in absoluta path format
INDIR=$(dirname $(readlink -f $0))/conf
OUTDIR=$(readlink -f ${OPT_DIR})/conf
WORKDIR=$(readlink -f ${OPT_WORK})

# Check needed directories and files before going on
if [ ! -d ${INDIR} ]; then
    echo "Base configuration directory not found. Fetch again from github."
    exit 1
fi
if    [ ! -f ${INDIR}/bblayers.conf ] || [ ! -f ${INDIR}/local.conf ] \
   || [ ! -f ${INDIR}/templateconf.cfg ] ; then
    echo "Missing files in base configuration directory."
    echo "Fetch again from github to recover."
    exit 1
fi
if [ ! -d ${WORKDIR} ]; then
    echo "The working directory does not exist. Aborting."
    exit 1
fi

# Setup destination directory
if $OPT_FORCE; then
    rm -rf ${OUTDIR}
fi
if [ -d ${OUTDIR} ]; then
    echo "Build directory already exists. Use -f option to remove it first."
    exit 1
fi
mkdir -p ${OUTDIR}
if [ $? != 0 ]; then
    echo Error creating output directory. Aborting.
    exit 1
fi

# Replace keyword <PATH> with the output directory in bblayers.conf
NEWPATH=$(echo ${WORKDIR} | sed 's/\//\\\//g')
cat ${INDIR}/bblayers.conf | sed "s/<PATH>/$NEWPATH/g" > bblayers.tmp
if [ $? != 0 ]; then
    echo Error creating temp file. Aborting.
    exit 1
fi

# Copy files to destination
cp ${INDIR}/local.conf ${OUTDIR}
cp ${INDIR}/templateconf.cfg ${OUTDIR}
rm -f ${OUTDIR}/bblayers.conf
mv bblayers.tmp ${OUTDIR}/bblayers.conf

