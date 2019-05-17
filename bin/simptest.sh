
# simptest - Execute the given testcases using simptestcase, or perform
# utility functionality.

###############################################################################
# Copyright (C) 2007,2019  Emil Karlen (email: emil.karlen@fripost.org)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.
###############################################################################

###############################################################################
# GLOBAL CONSTANTS
# ----------------------------------------
#
# *** nDebugLevel
#
#   Set to the debuglevel if the program is run in debug mode.
# Otherwise, undefined.
#   Currently the only debug level is 1.
#
# *** wslStandardDirectories
#
#   White space separated lists of the "standard test directories" - the
# directories that are created by --make-directories and
# --make-directories-and-makefile.
#
# *** sMakefile
#
#   The Makefile that is printed/created by --print-Makefile and
# --make-dirs-and-files, respecitvely.
#
# *** sREADME
#
#   The README file that is printed/created by --print-README and
# --make-dirs-and-files, respecitvely.
#
# *** swGetoptOptions
#
#   The options to tive to getopt for short and long options.
#
# *** VERSION
#
#   The current version of this program. Printed by -V, or --version.
#
# *** sInvocation
#
#   The syntax for the different ways to invoke simptest.
#
# GLOBAL VARIABLES
# ----------------------------------------
#
# *** optM4
#
#   Set to "--m4" if --m4 should allways be given to simptestcase.
# Otherwise empty.
#   If a filename ends with ".m4.simptestcase", the --m4 option is passed to
# simtestcase regardless of the value of this variable.
#
# *** wslM4_options
#
#   Set to the options to pass as --m4-options to simptestcase.  The string
# includes the name of this option.  Otherwise, empty.
#
# *** exitcode
#
#   Used in test mode when processing files and directories.
#   Tells the exitcode the program should have.
#
###############################################################################

readonly wslStandardDirectories='testcases input output data scripts tools'

readonly sMakefile='.PHONY: check

check:
	simptest testcases'

readonly sREADME='Directories and files hosting a Simptest test package.

Use simptestcase to run individual tests.
Use simptest to run all tests found in a given directory.

FILES
----------------------------------------
* Makefile
    Makefile for executing all testcases.
    The target "check" executes all tests.
* README
    This file.


DIRECTORIES
----------------------------------------
* testcases
    Files containging the Simptest testcases. If preprocessing with m4 is used,
    this directory may also contain m4 files to be included by the testcase
    files.
    Files ending with ".simptestcase" are Simptest testcase files.
    Files ending with ".m4.simptestcase" are testcases that should be
    preprocessed by m4. This is automatically done by simptest.
* input
    Files that are given as standard input (via stdin) to the testcases.
* output
    Files that should mach the output from testcases.
* data
    Various data used by the testcases. (Data that does not fit in the
    directories "input" or "output".)
* scripts
    Scripts and programs used from within the testcases.
* tools
    Tools used for testing of this test package.'

readonly swGetoptOptions="-o hVd -l help,version,make-dirs,print-Makefile,print-README,make-dirs-and-files,m4,m4-options:"

readonly VERSION=1.2.1

readonly sInvocation='1. simptest [COMMON_OPTIONS] [TEST_OPTIONS] FILE...
2. simptest [COMMON_OPTIONS] --make-dirs DIRECTORY
3. simptest [COMMON_OPTIONS] --print-Makefile
4. simptest [COMMON_OPTIONS] --print-README
5. simptest [COMMON_OPTIONS] --make-dirs-and-files DIRECTORY'

sHelp="${sInvocation}"'

simptest offers five differen functionalities - one "main" functionallity and
four "utility" functionallities.

MAIN FUNCTIONALLITY

The first syntax is for the main funcationallity.
The main functionality is to run simptestcase on test case files.
Each file given on the command line is given to simptestcase. If a directory is
given, simptest uses find to find all files ending with .simptestcase, and
gives these to simptestcase.
If --m4 or --m4-options are given, these are passed to simptestcase. If a
filename ends with .m4.simptestcase, simptest automatically passes --m4 to
simptestcase when processing this file. The output from simptestcase is
printed to stdout so that is can be examined separately.

UTILITY FUNCTIONALITIES

The syntaxes 2 to 5 are for utility functionalities. These are for
automatically creating directories and files that are suitable for hosting a
test package/test suit. If any of the test options are passed when invoking one
these functionallities, they are silently ignored.

The second functionality is to create a predefined standard directory structure
suitable for hosting the different files used for testing with simptest and
simptestcase.

The thrid functionality is to print a Makefile that is supposed to reside in
the directory containing the standard directories created by simptest (see the
functionality above).

The fourth functionality is to print a README that documents the standard
directories created by simptest --make-dirs.

The fifth functionality is a combination of the above: both create directories
and the files Makefile and README in the given directory.'


readonly M4_FILE_SUFFIX_RE='^.*\.m4\.simptestcase$'


###############################################################################
# - functions -
###############################################################################

# Prints an error message.
function printErrorMessage # <msg>
{
    echo $(basename $0)": ${1}" >&2  
}

# Print an error message ($1) and exit, with non-zero exitcode.
function printMsgExitError # <msg>
{
    printErrorMessage "${1}"
    exit 1
}

# Print the help text for this program and exit with zero exit status.
function printHelpExit
{
    echo $(basename $0)" [rot-dir]" >&2
    echo >&2
    echo "$sHelp" >&2
    exit
}

###############################################################################
#  Make the standard directories. Exit with non-zero status if we fail.
#
# A. Check syntax.  Print invokation info and exit non-zero if wrong.
# B. Check tat the argument is a writable directory.  Exit if it is not.
# C. Create the directories.
###############################################################################
function make_directories # <directory>
{
    # A #
    if [ $# != 1 ]; then
	printErrorMessage 'invalid syntax'
	echo >& 2
	echo "${sInvocation}" >& 2
	exit 1
    fi
    # B #
    [ ! -d  "${1}" ] && printMsgExitError "not a directory: ${1}"
    [ ! -w  "${1}" ] && printMsgExitError "not writable: ${1}"
    # C #
    for x in ${wslStandardDirectories}; do
	mkdir "${1}/${x}"
    done
}

##############################################################################
#   Process a single test case file.
# Set the global 'exitcode' to 1 if simptestcase does not succeed.
#
# Uses: nDebugLevel
#
# A. Start by setting the local variable 'file' to the name of the file and
#    print a processing message to stderr.
# B. If the filename ends with ".m4.simptestcase", the option --m4 should be
#    passed to simptestcase regardless of the value of 'optM4'.  Otherwise,
#    ${optM4} is passed.
#    Set 'exitcode' to 1 if simptestcase does not succeed.
##############################################################################
function process_file # FILE
{
    # A #
    local file=${1}
    echo "${file}:" >&2
    # B #
    if [[ "${file}" =~ ${M4_FILE_SUFFIX_RE} ]]; then
	if [ ${nDebugLevel} ]; then
	    if [ "${wslM4_options}" ]; then
		echo simptestcase --m4 "${wslM4_options}" "${file}"
	    else
		echo simptestcase --m4 "${file}"
	    fi
	else
	    if [ "${wslM4_options}" ]; then
		simptestcase --m4 "${wslM4_options}" "${file}" || exitcode=1
	    else
		simptestcase --m4 "${file}" || exitcode=1
	    fi
	fi
    else
	if [ ${nDebugLevel} ]; then
	    if [ "${wslM4_options}" ]; then
		echo simptestcase ${optM4} "${wslM4_options}" "${file}"
	    else
		echo simptestcase ${optM4} "${file}"
	    fi
	else
	    if [ "${wslM4_options}" ]; then
		simptestcase ${optM4} "${wslM4_options}" "${file}" || exitcode=1
	    else
		simptestcase ${optM4} "${file}" || exitcode=1
	    fi
	fi
    fi
}

###############################################################################
#   Execute the tests given as arguments.
# Each argument should be a test case file or a directory.  If it is a
# directory, we search for testcase files files using `find' and execute them.
#   If any test fails, exit the _program_ with non-zero exit code.  Otherwise,
# finish the procedure.
#
#   The exit code is stored in exitcode.
#
# Uses: optM4
# Uses: wslM4_options
#
# Sets: exitcode
#
# FLOW OF CONTROL
# ----------------------------------------
#
# A. Initialize the exit code to 0.
# B. For each testfile or directory.
#    1. If the argument is not an exising file: set the exit code to 1 and
#       print an error message.  Continue with the next file.
#    2. Process the file.
#       1. The file is a plain file. It is considered a test case file and
#          is processed using 'process_file'.
#       2. The file is a directory.
#          Find all test case files using `find' and process each of them
#          in a piped subprocess.  (Inside the subprocess, process-local
#          versions of 'file' and 'exitcode' are used.
#          Exit the subprocess with code ${exitcode} to comunicate our
#          exit status to the super-process.
#       3. Print a error message and set the exitcode to 1 if the file is
#          neither a plain file nor a directory.
# C. If we got a non-zero exit code from any of the steps above, exit with
#    the value 1.
###############################################################################
function execute_tests # FILE...
{
    # A #
    local file
    exitcode=0
    # B #
    for file; do
	# B1 #
	if [ ! -e "${file}" ]; then
	    printErrorMessage "file does not exist: ${file}"
	    exitcode=1
	    continue
	fi
	# B2 #
	if [ -f "${file}" ]; then
	    # B2.1 #
	    process_file "${file}"
	elif [ -d "${file}" ]; then
	    # B2.2 #
	    find "${file}" -type f -name "*.simptestcase" | {
		exitcode=0
		while read file; do
		    process_file "${file}"
		done
	        exit $exitcode
	    }
	    [ $? != 0 ] && exitcode=1
	else
	    # B2.3 #
	    printErrorMessage 'neither a file nor a directory: '"${file}"
	    exitcode=1
	fi
    done
    # C #
    [ $exitcode != 0 ] && exit 1
    return 0
}

###############################################################################
# - main -
###############################################################################

###############################################################################
#
# VARIABLES
# ----------------------------------------
#
# *** command
#
#   What simptest should do.  The value is the same string as the text of
# the long option that invokes it.  An exception is when test are performed:
# then the value is 'test'.
#
# FLOW OF CONTROL
# ----------------------------------------
#
# A. Read command line options arguments using getopt.
#    Leava the non option arguments as $1, $2, ...
#    1. Run getopt.
#    2. Print help and exit if invalid options.
#    3. Initialize 'command' and the globals 'optM4' and 'wslM4_options'.
#       (The second two are not mentioned because they are initialized to
#       <undefined>.)
#    4. Loop through the options and handle each.
#       Leave non option arguments as $1, $2, ...
#       (the value for true must be the integer 1 - it is used in testing
#       if more than one command is given.)
# B. Execute the given command.
#    * make-directories-and-makefile)
#      First run 'make_directories'.  If we return from this call, then we
#      have succeeded in making the directories.  This means that $1 is
#      a writable directory.  Because of this we can write our Makefile to
#      it.
###############################################################################

### A ###
# A1 #
args=$(getopt -n $(basename $0) $swGetoptOptions -- "$@")
# A2 #
[ $? != 0 ] && printHelpExit
# A3 #
command='test'
# A4 #
eval set -- "$args"
while [ "x$1" != 'x--' ] ; do
    case "$1" in
	-V|--version)           command='version' ;;
	-h|--help)              command='help' ;;
	-d)                     nDebugLevel=1 ;;
	--m4)                   optM4='--m4' ;;
	--m4-options)           wslM4_options="--m4-options=${2}" ; shift ;;
	--make-dirs)            command='make-dirs' ;;
	--print-Makefile)       command='print-Makefile' ;;
	--print-README)         command='print-README' ;;
	--make-dirs-and-files)  command='make-dirs-and-files' ;;
    esac
    shift
done
shift

### B ###

case "${command}" in
    version)
	echo $(basename $0)" ${VERSION}" >&2
	exit ;;
    help)
	echo "${sHelp}" >&2
	exit ;;
    make-dirs)
	make_directories "$@" ;;
    print-Makefile)
	echo "${sMakefile}" ;;
    print-README)
	echo "${sREADME}" ;;
    make-dirs-and-files)
	make_directories "$@"
	echo "${sMakefile}" > "${1}/Makefile"
	echo "${sREADME}" > "${1}/README" ;;
    test)
	execute_tests "$@" ;;
esac
