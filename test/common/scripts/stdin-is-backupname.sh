# -*- shell-script -*-

# stdin-is-backupname - Checks that the contents of stdin is a given
# copyback backup name (and nothing more).

# Exits with given exit status after removing the temporary file.
function cleanExit # <exit-code>
{
    rm -f "${fileTmpStdin}"
    case "${1}" in
	0) echo "MATCH"    >&2 ;;
	1) echo "mismatch" >&2 ;;
	*) echo "failure"  >&2 ;;
    esac
    exit ${1}
}

###############################################################################
# 0. Source in lib-tools.bash.
# 1. Print usage and exit if the first argument is the help option
#    ("-h" or "--help").
# 2. Print usage and exit if no arguments are given or the first argument is
#    an option.
# A. Store the contents of stdin in the temporary file /tmp/
# B. Put all times (the remaining arguments preceding any option
#    argument) in the array 'aDateTime'.
# C. Check the file against each backup name.
###############################################################################

# 0 #

source $(dirname ${0})/lib-tools.bash

readonly sUsage='[TIME...] [OPTIONS]

Note: Non-option and option arguments are given in non-standard order!

This program exits with zero exit status if the contents of the file FILE is
exactly one line, which gives the name of a copyback backup.
Oterwise, it exits with non-zero exit status.

A set of different backup names is tried. Each name is constructed from
one of the DATETIME-PART (given after the file name, but before the first
option) togheter with the options.

OPTIONS'"${printBackupName_options_except_datetime}"

# 1 #

if [ "_${1}" == '_-h' -o "_${1}" == '_--help' ]; then
    showUsageExit $(basename ${0}) "${sUsage}"
fi

# A #

fileTmpStdin="/tmp/stdin-is-backupname-$(date +%Y%m%d)-$$"
trap 'cleanExit 1' 1 2 15
cat > ${fileTmpStdin}

# B #

declare -a aDateTime
i=0
while [ $# != 0 -a "_${1::1}" != '_-' ]; do
    aDateTime[$i]="${1}"
    let ++i
    shift
done

# C #

for dt in "${aDateTime[@]}"; do
    sBak=$(printBackupName "$@" -t "${dt}")
    echo "checking: $sBak" >&2
    echo "$sBak" | diff -q - "${fileTmpStdin}" 2> /dev/null
    [ $? == 0 ] && cleanExit 0
done
cleanExit 1
