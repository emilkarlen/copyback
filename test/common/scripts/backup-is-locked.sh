#!/bin/bash

# backup-is-locked - Checks if the given backup has/has not acorresponding
# lock file.

#
# Exit with
#  0  - the backup exists and is/is-not locked.
#  1  - the backup exists but is not/is locked.
#  2  - the backup does not exist
#  99 - wrong usage
#

readonly EXIT_USAGE=99
readonly EXIT_EXISTANCE=2

sTestFlag= # Set to ! if --not

readonly extLock='.lock'

readonly sUsage='[--not] FILE'

function showMsgExit # EXIT-CODE MSG
{
    echo $(basename $0)": ${2}" >&2
    exit ${1}
}

###############################################################################
# A. Check usage and read arguments.  Exit if wrong.
#    Read eCheckWp and fileBak to the arguments.
# B. Exit with `EXIT_EXISTANCE' if the backup does not exist.
# C. Construct the lock filename.
# D. Perform the check using test and exit with this status.
###############################################################################

### A ###

case "$1" in
    '--not') sTestFlag='!' ; shift ;;
esac

[ $# == 1 ] || showMsgExit ${EXIT_USAGE} "${sUsage}"
fileBak=${1}

### B ###

[ -e "${fileBak}" ] || showMsgExit ${EXIT_EXISTANCE} "not a file: ${fileBak}"

### C ###

dir=$(dirname "${fileBak}")
bakHead=$(basename "${fileBak}")
if [[ "${bakHead}" =~ ^(copyback-[0-9]{8}-[0-9]{4,6})($|-|\.) ]]; then
    bakHead="${BASH_REMATCH[1]}"
else
    echo "Not a copyback backup: ${fileBak}"
    exit 2
fi
fileLock="${dir}${dir:+/}${bakHead}${extLock}"

### D ###

test ${sTestFlag} -e "${fileLock}" || exit 1
exit 0
