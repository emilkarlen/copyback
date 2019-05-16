# -*- shell-script -*-

# lib-tools.bash - Library of utilities for the test tools.

###############################################################################
# EXPORTS
#
#   The following identifiers are "exported" from this file:
#
# * showUsageExit
# * printBackupName_options_except_datetime
#   All the options, except the -t option, that printBackupName accepts.
# * printBackupName
###############################################################################

###############################################################################
# VARIABLES
#
# These are set from command line arguments.
#
# * sProjDir
# * nNumNumber
# * sExtPart
# * sDateTimePart
#
# 'nNumNumber' is formatted into 'sNumPart'.
###############################################################################

# Prints a usage message to stderr and exits with status 2.
function showUsageExit # <program name> <usage description>
{
    echo "${1}: ${2}" >&2
    exit 2
}

printBackupName_options_except_datetime='
  -r Project root directory (without trailing /).
  -n Backup number - the number that will show up in the #NN part.
     Only the integer. It is automatically formated.
  -E Extionsion part (the same string that is given to copyback using -E.'

printBackupName_options="${printBackupName_options_except_datetime}"'
  -t A date that the date command can parse. Any underscore characters
     are replaced with spaces before the value is passed to date.'

printBackupName_usage="[OPTIONS]
${printBackupName_options}"

###############################################################################
# A. Read command line arguments.
#    Sets the variables.
# B. Check and format the different parts.
#    1. The project root directory.
#       Append a / if it does not allread end with one.
#    2. Format the tag part.
#    3. The extension part.
#       A dot shall be prepended to it.
# C. Print the backup name.
###############################################################################
function printBackupName
{
    local swGetoptOptions='t:r:n:E:g:'

    ### A ###

    local args=$(getopt -n "${0}" -o $swGetoptOptions -- "$@")

    if [ $? != 0 ]; then
	showUsageExit "${0}" "${printBackupName_usage}"
    fi

    eval set -- "${args}"

    local dt
    while [ "_$1" != '_--' ]; do
	case "${1}" in
	    -r) sProjDir="${2}";
		shift
		;;
	    -t) dt=$(echo "${2}" | sed 's/_/ /g')
		sDateTimePart=$(date --date "${dt}" +%Y%m%d-%H%M)
		shift
		;;
	    -E) sExtPart="${2}"
		shift
		;;
	    -g) sTag=${2}
		shift
		;;
	esac
	shift
    done
    if [ -z ${sDateTimePart} ]; then
	sDateTimePart=$(date +%Y%m%d-%H%M)
    fi
    ### B ###

    # 1 #
    if [ "${sProjDir}" ]; then
	if [[ ! "${sProjDir}" =~ ^.*/$ ]]; then
	    sProjDir="${sProjDir}/"
	fi
    fi
    # 2 #
    if [ "${sTag}" ]; then
	sTagPart="-${sTag}"
    fi
    # 3 #
    if [ "${sExtPart}" ]; then
	sExtPart=".${sExtPart}"
    fi

    ### C ###

    fileBak="${sProjDir}copyback-${sDateTimePart}${sTagPart}${sExtPart}"
    echo "${fileBak}"
}

###############################################################################
# Prints the name of a backup lock file.
#
# The arguments is one of those that printBackupName accepts
# - this method prints the name of
# a lock file for the backup file name printed by that method.
###############################################################################
function printBackupLockName # [-t DATE]
{
    echo $(printBackupName "${@}")'.lock'
}
