# -* bash *-
# The line above, and the following lines inside the "markers", are replaced
# when make-ing the program.
# Don't remove them, they make line numbers match.
#
###############################################################################

###############################################################################
# Copyright (C) 2007,2019  Emil Karlen (email: emil.karlen@fripost.org)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
###############################################################################

###############################################################################
#
# COMMENT FORMAT
# ------------------------------------------------------------
#
# * Comments above function definitions
#
# ** For each argument in the form of an option, a line: "Option: <opt>:"
# ** For each non-option argument, a line: "Argument N:"
# ** For each global variable used, a line: "Uses: <varname>..."
# ** For each global variable set, a line: "Sets: <varname>..."
# ** If stdin is read from, there is a line: "Uses: stdin..."
#    The word "consumes" is used for reading everything from a thing.
# ** For output from the function to stdout, a line: "Output: ..."
# ** "Exit status" documents all possible exit statuses.
#
# USE OF EXTERNAL PROGRAMS
# -----------------------------------------------------------------------------
#
# * bash  (>= 3.0)
# * rsync (>= 2.6.3)
# * getopt
# * GNU sed
# * tr
# * find (>= 4.1.20)
# * sort
# * cut
# * head
# * ls
# * tar
# * gzip/gunzip
# * touch
# * chmod
# * mv
# * rm
# * awk
# * cat
# * tac
#
# Usage of `rsync'
# -----------------------------------------------------------------------------
#
#   Here is a description of the `rsync' program is used by `copyback'.
#
#   The program `rsync' is used for copying/updating files and
# directories.  A task of `copyback' is to construct the correct `rsync'
# command line.
#  `rsync' is run using the `eval' shell command so that `simpack' will not
# unquote values that should be passed quoted to `rsync'.
#   The command line arguments passed to `rsync' can be divided inte categories
# which are treated separately.  The complete `rsync' command line is created
# by appending these.
#
#    - Constant options that are always passed.
#
#        Represented by the variable rsync_swConstant.
#
#    - `copyback' options that are forwarded unmodified to `rsync'.
#
#          The `getop' options `copyback' must use to parse these are in
#        `rsync_swGetoptForward'.
#          Options to forward are appended `rsync_swForward' during the
#        command line parsing (in the same order that they appear on the
#        `copyback' command line.
#          Arguments are surrounded with single quotes.
#
#    - `copyback' options that result in other options being passed to `rsync'
#
#          Options to pass to `rsync' are prepended to `rsync_swVariable' after
#        the command line parsing.  (Prepending instead of appending should not
#        make any difference, but should it make any difference, earlier options
#        have higher precedence for `rsync' so that the default ones can be
#        overriden).
#
#    - The source and destination arguments.
#
#          These need not be stored
#
# CONSTANTS
# -----------------------------------------------------------------------------
#
# * VERSION
#
#   Program version string. Printed with --version (or -V).
#
# * emailMAINTAINER
#
#   Email adress to the maintainer of the program - the adress to send bug reports
#   to.
#
# Constants for regexps
# ------------------------------
#
#   Regular expressions matching backup file names.
#
# * ereBnGzipFilesInDir
#     Matches if the string is the name of a directory with all files ziped in
#     it (it ends with ${extGzipFilesInDir}).
# * ereBnTarArhive
#     Matches names of directories that are a tar archive. Archives can be
#     compressed.
#     (Ending with '.tar' or '.tar' followed by a dot.)
#
#
# Other constants
# ------------------------------
#
# * sUsage
#     Usage descriptNAion for the program.
# * swGetopt_gen_bak
#     Options to pass to `getopt' - both switches and arguments. Use
#     getopt $swGetopt_gen_bak -- "$@"
# * swGetoptTest
#     Options to pass to `getopt' - both switches and arguments to get
#     test options.
# *
#
# * sGlobalUserSfx
#     Added to the global backup root directory, this makes the path of the
#     user backup root directory.
#     The value is "root" or "users/$(id -nu)".
# * TRGLOCKSFX
#     Lock file suffix. Appended to TARGET to get the name of targets lock
#     file.
# * sStandardFilterFile
#     The filename of the standard copyback file for rsync to read filters
#     from.  It is used as a rsync "dir-merge" filter:  `rsync' will look
#     for a file with this name in each directory.  If it find one, filters
#     will be read from it.
# * extGzipFilesInDir
#     The extension (without the leading dot) that should be given to
#     directories whose files are gziped (all files inside it).
#     This kind of directory cannot be updated for the moment.
#     The extension must be different than that used in all other cases.  This
#     excludes for example 'tar', 'gz' and 'tar.gz'.
#
# * aMainCommandNames
#
#     Associative array containing the main command name for command and
#     aliases.
#     Aliases are mapped to their main command name.
#     Main command names are mapped to themselves.
#     The keys are main command names and aliases.
#     Currently (2010-12-19), the array is incomplete.  Only the names that
#     are actually used are in it.
#
# * aHelpForCommand
#
#     Associative array of help texts for the individual commands.
#     Indexed by the "main" command name, i.e., not short-cut names.
#     Currently (2010-12-19), the array is incomplete.  Only the names that
#     are actually used are in it.
#
# * aGetoptOptions
#
#     Associative array containing the getopt options to use for spcific
#     commands.
#     The keys are the main command names.
#     Currently (2010-12-19), the array is incomplete.  Only the names that
#     are actually used are in it.
#
# VARIABLES
# ------------------------------------------------------------
#
#   For each COMMAND, set the variables for "backup destination" and
# "source usage". When that is done, the checking of valid CL options,
# arguments, checking of the source etc is taken care of. There is no need
# to do any checking based on the COMMAND.
#
# Backup Destination
# ----------------------------------------
#
#   The variables
#      - `bakDest_eType'
#      - `bakDest_eSrc'
#      - `bakDest_bMustExist'
#      - `bakDest_prjFile_eWhichBackups'
# determines which of the backup destinations is needed, i.e., which of
#      - `dirBakRoot'
#      - `dirPrjDir'
#      - `dirPrjDir', `aBakInfo_filePrjBak', `filePrjBak'
#
# is needed, and how they are derived.  They also determine whether or not
# some of the other variables are used (which is documented at these
# variables).
# `bakDest_eType' and `bakDest_eSrc' are set by
# looking at the command - each command requires one of these.  Once they
# are set, we can use common code (common for all commands) to derive
# `dirBakRoot', `dirPrjDir' and `filePrjBak'+`sFilePrjBakMinusExt'.
#   If [ `bakDest_bMustExist' ] the backup destination must exist.  Then it is
# also set to the _abspath_ of the file.
#
# * bakDest_eType
#
#    Enum for the type of "backup destination" that the user tells copyback
#    to operate upon:
#        - 'bak-dir'    : The destination is the backup root directory.
#                         `dirBakRoot' will be set.  `dirPrjDir' and
#                         `filePrjBak'+`sFilePrjBakMinusExt' are not needed,
#                         which means that `PRJTYPE' and `SRC' aren't either.
#        - 'prj-dir'    : The destination is the project directory.
#                         `dirPrjDir' will be set.  (`dirBakRoot' is maybe set
#                         but `filePrjBak'+`sFilePrjBakMinusExt' is not).
#                         `PRJTYPE' and `SRC' may be needed if they are
#                         either "read" from or if needed to derive
#                         `dirPrjDir'.
#        - 'prj-file'   : The destination is a specific backup file for a
#                         project.  For the moment, `bakDest_eSrc' must be
#                         abs-arg for this option.
#                         `filePrjBak'+`sFilePrjBakMinusExt' is set.
#                         (`dirBakRoot' and `dirPrjDir' are maybe set.)
#
#    This variable should be initialized by each COMMAND.
#
# * bakDest_eSrc
#
#    Enum that tells from what information the backup destination (specified by
# `bakDest_eType') should be derived.
#   - 'abs-arg'    : The file/directory is given explicitly by the first
#                    non-option CLA.
#                    If [ bakDest_bMustExist ] then this file/directory
#                    must exist.  `bakDest_eType' tells the type of it.
#                    If [ bakDest_eType == 'prj-file' ], the file must
#                    also has a valid copyback basename
#   - 'env-and-cla': The directory is derived from environment
#                    variables, option CLAs and maybe also `SRC'
#                    (if `NAMETYPE' is not 'constant').
#
#   This variable should be initialized by each COMMAND.
#
# * bakDest_bMustExist
#
#    Tells wheter the "backup destination"
# must be an existing file/directory or not. (Which one is relevant is
# determined by `bakDest_eType'.)
#
#    This variable should be initialized by each COMMAND.
#
# * bakDest_prjFile_eWhichBackups
#
#     For commands operating on existing backups, this variable tells which
#   of these are processed.  Used only if eType == 'prj-file'.
#     If the value is 'all', `bakDest_eType' is changed to 'prj-dir'
#   automatically.  This has to be observed by the code that executes the
#   command, and also, the command has to get the list of "all" backups in the
#   Project directory itself.
#     ERROR STATE: bakDest_prjFile_eWhichBackups != 'all' && bakDest_eSrc = 'abs-arg'
#   then
#     It is an enumeration of possible types:
#     'all'              : All existing backups are processed.
#                          This value is not valid for all commands, only those
#                          that can operate on either one or several backups.
#                          If `bakDest_eType' is found to be 'prj-file' by the
#                          "bak-dest deriving" code, it will be modified to be
#                          'prj-dir'.  The "final" execution of the command
#                          will have to check `bakDest_prjFile_eWhichBackups' to
#                          know if `dirPrjDir' or (`filePrjBak', ...) has been
#                          set.
#     'last'             : Only the last backup is processed.
#     'last-updatable'   : Only the last updatable backup (without --force).
#     'last-updatable/f' : Only the last updatable backup (with --force).
#     'date/DATE'        : The backup with the date DATE.
#     'tag/TAG'          : The backup with the tag TAG.
#
# Source Usage
# ----------------------------------------
#
# The "source" is the thing that is backed up.
#
# * srcUsage_wslValidTypes
#
#   Used only when bakDest_eType='prj-dir' and bakDest_eSrc='env-and-cla'.
#   A white-space separated list of valid project types. (See `PRJTYPE' for a
# list of possible values.) If empty, all project types are valid.
#   Should be initialized by each COMMAND that uses a source.
#
# * srcUsage_bRead
#
#   Used only when bakDest_eType='prj-dir' and bakDest_eSrc='env-and-cla'.
#   If a source is used, this tells how it is used.  If the value is False
# (not set), then the source is only used for deriving the project name, not
# for reading the "contents" of it.   If it is True (set), then it can be used
# both for deriving the project name and reading its "contents".  By contents
# it is ment the contents of the file or directory or the output from the
# program.  We need to read the contents only if we are creating a backup.
#   The value should be initialized by each COMMAND.  But it should not be
# set readonly.  This is because we may need to `stat' the source if it is
# a file or directory and we must use its abspath in the derivation of the
# project name, or we need to derive the project type and naming scheme
# automatically. This means that the program can update its value to True.
#
# =============================================================================
# |
# | Table 1: Consequences of different combinations of `bakDest_eType' and
# |          `bakDest_eSrc'
# |
# |----------------------------------------------------------------------------
# | bakDest_eSrc |bakDest_eType | Meaning
# |--------------|-------------------------------------------------------------
# |              |              | Not used: srcUsage_...
# |              |              | One (non-opt) arg: the absolute filename.
# |              |              | No options for project name and type used.
# |              |              | No options for backup root directory used.
# |              |              | => Not used: `NAMETYPE' (+ `CLO_NAME_sConstant' and
# |              |              | `CLO_NAME_sPrefix') `OUTPUTEXT',
# |  abs-arg     |    <any>     | `CLO_dirBakRoot', `CLO_dirGlobalRoot',
# |              |              | `CLO_DIRECT_ROOT', `CLO_sGlobalRootSuffix'.
# |              |              | Source not used: the argument is the file.
# |              |              | Source type is ignored.
# |              |              | See `aVarsNotUsed_bakDest_absArg_...'.
# |              |              | Arguments: exactly one must be present =
# |              |              | and file/directory.
# |              |--------------|----------------------------------------------
# |              |   bak-dir    | Set: maybe `dirBakRootGlobal',
# |              |              | `dirBakRoot', but not `dirPrjDir'.
# |              |--------------|----------------------------------------------
# |              |   prj-dir    | Set: maybe `dirBakRootGlobal',
# |              |              | `dirBakRoot', `dirPrjDir'.
# |--------------|--------------|----------------------------------------------
# |              |              | Set: maybe `dirBakRootGlobal',
# |              |              | `dirBakRoot', but not `dirPrjDir'.
# |              |              | (a) No (non-option) argument should be present.
# |              |              | Not used: srcUsage_...
# |              |   bak-dir    | (b) Source and sourcetype shold not be given:
# | env-and-cla  |              | => `PRJTYPE', `SRC' not given => NAMETYPE
# |              |              | not given.
# |              |--------------|----------------------------------------------
# |              |              | Set: maybe `dirBakRootGlobal',
# |              |              | `dirBakRoot', `dirPrjDir'.
# |              |              | Used: srcUsage_...
# |              |              | (a) Source and sourcetype used: `PRJTYPE', `SRC'.
# |              |   prj-dir    | (b) Used: `NAMETYPE'.
# |              |              | `NAMETYPE' != 'constant' => We must have a
# |              |              | source (that is a file/dir).
# |              |              | If not given, try to derive these
# |              |              | automatically: `PRJTYPE', `NAMETYPE'.
# =============================================================================
#
#
# =============================================================================
# |
# | Table 2: Given that srcUsage_... are needed (Table 1 describes when this
# |          is), this table describes when `SRC' and `PRJTYPE' are needed.
# |          Note: When `SRC' and `PRJTYPE' are needed, `NAMETYPE' is also.
# |
# |----------------------------------------------------------------------------
# | srcUsage_bRead | NAMETYPE   | `SRC' and `PRJTYPE' needed
# |                |  value     |
# |--------------------------------------------------------
# | True           |  <any>     | Yes
# |----------------|------------|--------------------------
# | False          | constant   | No
# |                |------------|--------------------------
# |                | !=constant | Yes (for deriving the project name).
# |                | or not     |
# |                | given      |
# =============================================================================
#
#
# * bImplicitCommand
#
#   Boolean.  Set if the command is given imlicitly.
#   The reason is for being able to print a good error message if the argument
#   supplied is neither a name of a command nor a file/directory.
#
#
# Set by command line arguments
# ----------------------------------------
#
#   The CLO_ prefix is sometimes used to indicate that the variable is set from
# a Command Line Option.
#
#
# * CLO_bDebug
#
#   Set from --debug.  This makes the command line argument being parsed
# for test options.
#
# * NAMETYPE (mandatory if command is not restore)
#     Enum for type of name:
#         - 'constant'
#         - 'basename'
#         - 'absolute'
#         - 'suffix'
#
# * CLO_NAME_sConstant
#
#     When NAMETYPE == 'constant'. The constant name.
#     cond: "/$CLO_NAME_sConstant" must be an absolute path.
#
# * CLO_NAME_sPrefix
#
#     When NAMETYPE == 'suffix'. The prefix to remove.
#     Set by Command Line Arguments.
#
# * CLO_sGlobalRootSuffix
#
#     Set from --root-global-suffix.
#
# * CLO_bPrjNameHead
# * CLO_sPrjNameHead
#
#     Set from --project-name-head.
#     `CLO_bPrjNameHead' indicates wether a name head is set using options or not.
#     `CLO_sPrjNameHead' is the name head set using options.  This is empty, if
#     --project-name-head is used without argument.
#
#
# * eBakPresFormat
#
#   Enum telling how backups should be presented to the user.
#   - 'filename'       : print the filename.
#   - 'filename-extra' : print the filename with extra info (asterisks for
#                        locked backups)
#   - 'formatted'      : print date, lock-status and tag ... formatted.
#
#   Not used by all commands.
#   The function `presentBackup' uses this variable.
#
# * sPrjName
#
#     The project name.
#
# * COMMAND
#
#     Enum that describes what is to be done. If not testing, one of:
#         - 'backup'     : Create or update a backup.
#         - 'list'       : Lists all backups for a project in creation time order.
#         - 'find'       : Lists all directories that contain copyback backups.
#         - 'clean'      : Cleaning of old backups for a given project.
#         - 'lock'       : Lock an existing backup.
#         - 'unlock'     : Unlock an existing backup.
#         - 'restore'    : Restore names in directory structure.  NOT IMPLEMENTED
#         - 'tag'        : Tagging an existing backup.  NOT IMPLEMENTED
#         - 'untag'      : Removing a tag from an existing backup.  NOT IMPLEMENTED
#         - 'print-backup-root-directory'
#         - 'print-project-directory'
#         - 'print-project-name'
#         - 'print-backup-file'
#         - 'print-file-inside-backup'
#   If we are testing using the test command test-dest-deriv, OPEATION can
# have one of the values described under the documentation for this
# test-command.
#
# * PRJTYPE
#     Enum for type of source to backup (the "project type"):
#         - 'file'      : backup a file,
#         - 'directory' : backup directory,
#         - 'program'   : backup output from program.
#
# * SRC
#     The source: a file, a directory or a program. Same as SRC{FILE,DIR,PGM}.
#
# * CLO_bRecursive
#
#     If the "recursive" (-r) option is given.
#     Set if it is given, otherwise non-set.
#
# * CLO_bak_bForce
#
#     If the backup option "force" (--force) option is given.
#     Set if it is given, otherwise non-set.
#     WARNING: This variable DOES NOT correspond to the force flag used by
#     other commands!
#
# * CLO_nonBak_bForce
#
#     If the non-backup option "force" (--force) option is given.
#     Set if it is given, otherwise non-set.
#     WARNING: This variable DOES NOT correspond to the force flag used by
#     the backup command, only by non-backup commands.
#
# * CLO_bak_eUpdate
# * CLO_bak_bNoDelete
#
#     Valid if the COMMAND is 'backup'.
#
#     `CLO_bak_eUpdate' is an enum telling if we are to update an existing
#     backup:
#       - 'update' : We are to update an EXISTING backup.  Fails if there
#                    is no existing backup.
#       - 'update-or-create' : We are to update an existing backup, or create
#                    a new if the referens to an existing backup does not
#                    referens a backup.
#     The boolean `CLO_bak_bNoDelete' is applicable when we are updating
#     a directory.  Then it tells if we should delete files from it or not.
#
#
# * cmdTest
#    If in test mode, the test command given with -c <cmd>.
# * test_DateNow
#    If testing, the date and time to use when generating a unique backup
#    name
# * test_bakDest_bMustExist
#    Set to true if the test option -e is given.
#
#
# * CLO_bak_bTar : boolean
#     A tar archive is to be generated (if set and value is non-empty).
# * CLO_bak_bGzip : boolean
#     Archive is to be compressed (if set and value is non-empty).
# * CLO_bak_bLock
#     If the created backup should be locked (-L).
# * nVerboseLvl : integer
#     Level of verbiosity for messages printed to stderr.
#     Initialized to 1.
#       == 0 -> don't print
#       >  0 -> print
# * OUTPUTEXT
#     Valid only when source is a program:
#     An extension to add to the generated backup file.
#     If set this string prefixed with a "." is added to the
#     backup file name. (For example: if output is SQL-statements an extension
#     of "sql" could be adequate.)
#
# ** Set by command line arguments or read from environment
#
#
# * dirBakRootGlobal (mandatory)
#     Root dir for backups. Under this directory, there must be exactly the
#     directory structure used by copyback (see manual).
#
#
# COMPUTED VALUES
# ------------------------------------------------------------
#
# * dirBakRoot
#     See "DIRECTORY VARIABLES" below!
# * dirBakRootUser
#     Se "DIRECTORY VARIABLES" below!
# * sPrjRootSfx
#     The suffix to be appended to dirBakRootGlobal to get the root directory for
#     this project, dirPrjDir.
#     Does not begin and does not end with a "/".
# * dirPrjDir
#     The absolute path of the root of the projects root directory in the
#     backup root directory structure. Beginns with a '/' but doesn't end with
#     one: dirBakRootGlobal + sPrjRootSfx.
# * TARGET_WoEXT
#     Part of TARGET before the first ".".
#     Unique for this project.
# * TARGET
#     Full path of the target directory or file.
# * TARGET_fileLock
#     The file name of the file which is used to lock the TARGET name
#     from use by other copyback processes. It resides in dirPrjDir.
# * OLDTRG
#     Full path for target directory of an existing, not locked, backup.
#     Only used when doing an update.
#     Only set when doing an update and there exists a backup.
# * OLDTRG_fileLocke
#     The absolute file name of the file which is used to lock the old target
#     directory when doing an update.
#     Only used when doing an update.
#     Only set when doing an update and there exists a backup.
#
#
# Backup Root Directory Variables
# -----------------------------------------------------------------------------
#                     |---root-global-suffix-|
# |-dirBakRootGlobal-||---users/<user>-------|
# |-dirBakRoot-------------------------------||-sPrjNameHead-||-sPrjNameTail-|
# |-dirBakRoot-------------------------------||----------sPrjName------------|
# |-dirPrjDir----------------------------------------------------------------|
#
#
# <user> is the name of the operating system user running copyback.
# <user-subdir> is one of userHomeStdSubdir_...
###############################################################################

###############################################################################
# - constants and variables -
###############################################################################

readonly IFS_DEFAULT="${IFS}"
readonly IFS_NEWLINE='
'

# If we fail creating the backup.
readonly EXIT_USAGE=1		# Exit code for CLA usage error.
readonly EXIT_ERROR=2		# Exit code for failure of command.
readonly EXIT_IMPLEMENTED=100	# Exit code for NOT IMPLEMENTED features.
readonly EXIT_INTERNAL=101	# Exit code for internal error.

readonly sStandardFilterFile='.copyback-filter'
readonly sStandardExcludeFile='.copyback-exclude'

readonly PROGNAME=$(basename "$0") # The basename of this executable.

readonly sUsage="Try \`copyback --help' for more information."
readonly sHelp='Program to create and maintain simple backups.
Backups of files and directories are copies created using rsync.
Backups of "program output" (to stdout) are files storing this output.

See copyback-UsersGuide-en.html for more information. This file may be
installed at /usr/share/doc/copyback, or a corresponding directory.


General syntax:

copyback [GENERAL-OPTIONS] COMMAND [BACKUP-OPTIONS] [COMMAND-ARGUMENTS]

COMMAND is one of the following (names in parenthesis are aliases):

    backup   (b)    Create or update a backup.
    clean           Remove all but the latest backup for a project.
    remove-project  Removes all backups for a given project.
    find            Lists all directories that contain copyback backups.
    list     (l,lf) Lists all backups for a project in creation time order.
    lock            Lock an existing backup.
    unlock          Unlock an existing backup.
    tag             Add a tag to an existing backup.
    untag           Remove the tag from an existing backup.
    backup-root-directory (brd)  Print the current Backup root directory.
    project-directory     (pd)   Print the current Project directory.
    project-name          (pn)   Print the current Project name.
    print-backup-file     (pbf)  Print the absolute filename of a backup file.
    print-file-inside-backup (pfib) Prints the aboslute filename of the given
                                    file inside the a backup.
If no COMMAND is given, backup is assumed.


Backups are stored under the directory specified by the environment variable
  COPYBACK_ROOT,
or the option
  --root=DIRECTORY.
Each source makes a "project" and its backups are stored in a unique
"project directory", under the above mentioned directory.


To backup a file or directory, issue

  copyback backup FILE

To backup the output from a program (to stdout), issue

  copyback --program --constant=STORAGE-SUBDIRECTORY backup COMMAND-LINE
or
  copyback --program --constant=STORAGE-SUBDIRECTORY backup -


Report bugs to <'"${emailMAINTAINER}"'>.'

declare -A aHelpForCommand
aHelpForCommand=(
    ['print-backup-file']='Prints the abolute path of the specified backup file.'
    ['print-file-inside-backup']='Prints the abolute path of a file inside a backup of a directory.'
)

readonly help_s_backup='copyback backup: Create a new or update an existing backup.' # [TODO more here!]
readonly help_s_list='copyback list: List existing backups for a project.' # [TODO more here!]
readonly help_s_find='copyback find: Find directories containing backups.' # [TODO more here!]
readonly help_s_lockUnlock='copyback lock/unlock: Lock/unlock existing backups.' # [TODO more here!]
readonly help_s_tag='copyback tag: Mark a backup with a unique string' # [TODO more!]
readonly help_s_Untag='copyback untag: Remove the tag from a backup.' # [TODO more here!]
readonly help_s_clean='copyback clean: Remove all but the latest backup for a project.' # [TODO more here!]
readonly help_s_removeProject='remove-project: Remove all backups of a project, and the project directory.

SYNOPSIS

  [GENERAL-AND-BACKUP-OPTIONS] remove-project [RP-OPTIONS] [SOURCE]

  If the root directory can be derived, all empty directories down to it, but
not including it, will be removed.
  Projects containing locked backups will not be removed (unless --force is
used).

OPTIONS

  --force | -f
      Projects containing locked backups will be removed, if the lock is not
      write-protected.
  --explicit | -e
      The project directory is given explictly as the single comman line
      argument.
'

declare -A aCommandSyntax
aCommandSyntax=(
    ['print-file-inside-backup']='[GENERAL-AND-BACKUP-OPTIONS] print-file-inside-backup [BACKUP-FILE-OPTIONS] [SOURCE] FILE'
)

readonly syntax_s_tag='copyback tag: [GENERAL-AND-BACKUP-OPTIONS] tag [TAG-OPTIONS] TAG [SOURCE]'

readonly errMsg_s_test_usage="Invalid test usage.
Try \`copyback -- test: --help' for help.\\n"
readonly msgTestHelp='Run copyback for testning.
  --help  Show this help and exit.
  -d date
          The time to use when generating a unique backup name for
          a datem,time.
          The format of the time must be one that is understood by
          the date program. An exception is that underscores can be
          used - these are replaced with spaces before the value is
          given to the date program.
  -e      Sets bakDest_bMustExist to True, independet of COMMAND.
  -c test-command
          Run specified test. Possible tests are:
          print-rsync-options
            Print the options that would be passed to
            rsync. The source and destination are not printed.
            The options are only printed if the options given to copyback
            really leads to running rsync, so correct copyback command line
            must be used!
          print-prjname
            Prints sPrjName.
          print-prjname-tail
            Prints sPrjNameTail.  Tests setPrjNameTail.
            No other options than those relevant for setting sPrjnameTail are
            required.
          print-source
            After all checking of the source, print it and exit.
          gen-target-name
            Runs getAndLockFreshBackupNameForDtPart, prints TARGET_WoEXT and TARGET_fileLock
            and exits.
          print-derived-options
            Prints the values of the options that can be derived and exit.
            These are: COMMAND, PRJTYPE, NAMETYPE.
            The nametype is followed by the
            additional value that is dependent of it (see the code!).
            Caution: These values are only derived if they are needed.
          print-free-dt-part
            Prints the datetime part that sould be used for a given datetime.
            The used time is the current time, or, if the test
            option -d, is used, that date,time.
          test-dest-deriv
            Tests the derivation of the backup destination.
            See Table 1 for info on these.
            The first (non-option) argument sets the subtest of this test.
            One of:
                abs-arg/bak-dir/existing    abs-arg/bak-dir
                abs-arg/prj-dir/existing    abs-arg/prj-dir
                abs-arg/prj-file/existing   abs-arg/prj-file
                env-and-cla/bak-dir
                env-and-cla/prj-dir/program
                env-and-cla/prj-dir/file
            This command sets cmdTest to test-dest-deriv and
            COMMAND to test-dest-deriv/${subtest}.
          doRemoveProject
	    Runs the function doRemoveProject with the given arguments.
            (The arguments are not checked for correctness.)
            Argument 1: project directory (PD)
            Argument 2: OPTIONAL backup root directory (BRD)
            If given, the BRD must be a parent directory of PD, and also
            the string BRD must be a "head" of PD.
          dest-deriv-prj-file
            Tests deriving bakInfo for a "backup file" or the Project directory.
            The test options should be terminated by a -- and followd by the
            CLAs used for lock/unlock (to imitate them as closly as possible).
          bak-info-select
            Run bakInfo_list_sortedOnDt and exit.
            Argument: the directory to list.

'

readonly errMsg_pf_invalidTestCommand='Invalid test command:%s.\n'

nVerboseLvl=1
eBakPresFormat='filename-extra'

# -----------------------------------------------------------------------------
# Variables for values to pass to `rsync'
# Ska --xattrs och --acls tas bort som standard - bara användas om en speciell växel anges?
#readonly rsync_swConstant="--archive --executability --xattrs --acls --filter=dir-merge_${sStandardFilterFile}"
readonly rsync_swConstant="--archive" # rsync version 2.6.3
# Options that should be recognized by `copyback' and forwarded to `rsync'
# without modification.
# These must not collide with other `copyback' options!
readonly rsync_swGetoptForward_long='chmod:,exclude:,exclude-from:,include:,include-from:,cvs-exclude,filter:'
# Options to pass to `rsync' that cannot be determined in advance are
# accumulated in this variable (separated by spaces).
rsync_swVariable=
rsync_swForward=
readonly rsync_EXIT_USAGE=1 # Exit code from rsync for wrong syntax or usage.
# -----------------------------------------------------------------------------

# Name of options that are used in messages.
readonly optname_sAdd='--no-delete'
readonly optname_sTar='--tar'
readonly optname_sExt='--extension'

readonly swGetopt_gen_long='debug,help,version,root:,root-global:,gr:,root-global-suffix:,grs:,print-filename,prfn,print-filename-extra,prfne,print-formatted,prft'
readonly swGetopt_gen_short='V'

readonly swGetopt_naming_long='absolute,constant:,basename,suffix:,suffix-home'
readonly swGetopt_naming_short='abc:hs:'
readonly swGetopt_bak_long="${swGetopt_naming_long},${rsync_swGetoptForward_long},source:,file,directory,program,project-name-head::,pnh::,no-delete,update,update-or-create,force,lock,gzip,tar,extension:,assign-tag:,last,date:,tag:,rsync-filter"
readonly swGetopt_bak_short="${swGetopt_naming_short}AE:FfLnTuUzg:ld:t:"

readonly swGetopt_gen_bak_long="-l ${swGetopt_gen_long} -l ${swGetopt_bak_long}"
readonly swGetopt_gen_bak_short="${swGetopt_gen_short}${swGetopt_bak_short}"

readonly swGetopt_gen_bak="-n copyback -o +${swGetopt_gen_bak_short} ${swGetopt_gen_bak_long}"

readonly swGetoptTest="-n copyback/test -o +c:d:e -l help"
readonly wslTestCommands='print-rsync-options print-prjname print-prjname-tail print-source print-free-dt-part print-derived-options gen-target-name test-dest-deriv dest-deriv-prj-file bak-info-select doRemoveProject'

# Parsing of Command specific options
readonly getopt_backup_swOptions="-o +${swGetopt_bak_short} -l help,${swGetopt_bak_long}"
readonly getopt_list_swOptions='-o +e -l help,explicit'
readonly getopt_find_swOptions='-o +e -l help,explicit'
readonly getopt_lockUnlock_swOptions='-o +eld:t: -l help,explicit,all,last,date:,tag:'
readonly getopt_tagUntag_swOptions='-o +led:t: -l help,explicit,last,date:,tag:'
readonly getopt_printBackupFile_swOptions='-o +ld:t: -l help,last,date:,tag:'
readonly getopt_clean_swOptions='-o +fer -l help,force,explicit,recursive'
readonly getopt_removeProject_swOptions='-o +ef --long explicit,force,help'
readonly getopt_singleBackupFileNonExplicit_swOptions='-o +ld:t: -l help,last,date:,tag:'

declare -A aGetoptOptions
aGetoptOptions=(
    ['print-backup-file']="${getopt_singleBackupFileNonExplicit_swOptions}"
    ['print-file-inside-backup']="${getopt_singleBackupFileNonExplicit_swOptions}"
)

declare -A aMainCommandNames
aMainCommandNames=(
    ['print-file-inside-backup']='print-file-inside-backup'
    ['pfib']='print-file-inside-backup'

    ['print-backup-file']='print-backup-file'
    ['pbf']='print-backup-file'
)

# Default project name heads.
readonly predefPnTail_sOther='other'
readonly predefPnTail_sRoot='root'
readonly predefPnTail_sHome='home'

# Matches a backupname, anywhere in the string. Parentheses around the
#   1. basename head (without tag and extension)
#   2. date-time-part
readonly ereBakNameHead_BnHead_Dt_Tag='(copyback-([[:digit:]]{8}-[[:digit:]]{4,6}))(-[^/.*"]+)?'
# The basename of a backup name (does not include a ^).
readonly ereBakNameBn="${ereBakNameHead_BnHead_Dt_Tag}($|\..*)"
readonly ereBakNameBn_BnHead_Dt_Tag_Ext="${ereBakNameHead_BnHead_Dt_Tag}($|\..+)"
readonly find_ereBakNameFn='.*/copyback-[0-9][^/]+'

# Format string for printf to construct a backup basename.
# A backup (base-) name must not contain a dot!
# Arguments: DATETIME-PART, #NN|empty (as formated by format_date_DtPart)
readonly format_bakName_fromDtPart_1='copyback-%s'

# The format string for `date', to format the date+time part of a backupname.
readonly format_date_DtPart='%Y%m%d-%H%M%S'

# Indexes for the fields output by `bakInfo_select'.
# The indexes start a 0 (as do the indexes in arrays.)
# For using the indexes as $1, $2, ..., add 1 to each index.
readonly bakInfo_idx_dt=0
readonly bakInfo_idx_lockPerm=1
readonly bakInfo_idx_lockFile=2
readonly bakInfo_idx_tag=3
readonly bakInfo_idx_bnHead=4
readonly bakInfo_idx_bn=5
readonly bakInfo_idx_ext=6
readonly bakInfo_nNumFields_lockOnly=3
readonly bakInfo_nNumFields_backup=7

readonly LOCKFILE_EXT='lock'
readonly TRGLOCKSFX='.lock'
readonly sGlobalUserSfx="users/"$(id -nu)
readonly extGzipFilesInDir='gzs'
readonly ereBnGzipFilesInDir='\.gzs$'
readonly ereBnTarArhive='\.tar($|\.)' # Ending with '.tar' or '.tar' followed by a dot.

readonly tag_ereTag='[^/.]+' # A valid tag.
readonly ereSimpbackDatetime='[[:digit:]]{8}-[[:digit:]]{4,6}'
readonly usageDescr_pf_prjRoot_1='%s: Usage PROJECT-DIRECTORY\n'
readonly usageDescr_pf_Args_1='%s: Usage ARGUMENT...\n'
readonly usageDescr_s_bakInfoSelect='bak-info-select: FROM WHERE ORDERBY PROJECT-DIRECTORY'
readonly usageDescr_s_doRemoveProject='doRemoveProject: Usage project-directory [backup-root-directory]'

readonly usageErr_s_SpecifyBackup="Specify a backup using --last, --date, --tag (or maybe --all)."

readonly errMsg_pf_Internal_1="INTERNAL ERROR (%s).
${PROGNAME}: Please report bug to <${emailMAINTAINER}>.\n"
readonly errMsg_pf_NotImplemented_1='Sorry, not implemented yet: %s\n'

readonly errMsg_pf_InvalidTag_1='A tag string must not be empty and cannot contain / or .: %s\n'
readonly errMsg_s_tagMissing='No tag string given.'
readonly errMsg_pf_tagAlreadyInUse='The tag string is already in use: %s\n'

readonly errMsg_s_printPrjNameTail_FileMissing='print-prjname-tail: When NAMETYPE != constant a FILE is needed.'
readonly errmsg_pf_ErrorRunningProgram_1='No backup created - the program exited with non-zero exit status (%s).\n'
readonly errMsg_pf_UnknownBackupType_1="Backup not updated - unknown backup name extension: %s\n"
readonly errMsg_pf_untar_1='Backup not updated - error un-taring archive %s\n'
readonly errMsg_s_program_constantOnly='When the source is program, the constant naming scheme must be used (-c).'
readonly errMsg_s_BakRoot_Missing="No backup root directory given.
${PROGNAME}: Use --root or  --root-global or one of the environment variables
${PROGNAME}: COPYBACK_ROOT and COPYBACK_ROOT_GLOBAL."
readonly errMsg_s_bak_NoBakRef='Must specify which backup to update using --last, --date or --tag.'
readonly errMsg_pf_NotADirectory_1='Not a directory: %s\n'
readonly errMsg_pf_NotAFile_1='Not a file: %s\n'
readonly errMsg_s_NoSuchBackup='No such backup.'
readonly errMsg_pf_NotAReadableDirectory_1='Not a readable directory: %s\n'
readonly errMsg_pf_NotAReadableFile_1='Not a readable file: %s\n'
readonly errMsg_pf_FileNotExisting_1='File does not exist: %s\n'
readonly errMsg_pf_NotASimpbackBackup_1='Not the name of a copyback backup: %s\n'
readonly errMsg_pf_RootDirIsBackup_1='Not a valid root directory (it is a copyback backup): %s\n'
readonly errMsg_pf_CantDerivePrjType_fileDir_1='Cannot derive the source type, the source is not a file or directory: %s\n'
readonly errMsg_pf_NorACmdOrFile_1='Neither a file nor a command name: %s\n'
readonly errMsg_pf_CantDeriveNameType_fileDontExist_1='The source is not a file - the naming scheme cannot be derived: %s\n'
readonly errMsg_pf_NotAllowedPrjType_1='The project type '"'%s'"' is not allowed for this command.\n'
readonly errMsg_pf_PrjRootNotExisting_1='The project directory is not an exsisting directory: %s\n'
readonly errMsg_pf_PrjRootNotWritable_1='The project directory is not writable: %s\n'
readonly errMsg_pf_BakRootNotExisting_1='The backup root directory is not an exsisting directory: %s\n'
readonly errMsg_pf_BakRootNotWritable_1='The backup root directory is not writable: %s\n'
readonly errMsg_pf_BackupNotWritable_1='The backup is not writable: %s\n'
readonly errMsg_pf_CantCreatePrjRoot_1='Cannot create the project directory: %s\n'
readonly errMsg_pf_SrcPrefixOfPrjRoot_2="The source file cannot be a prefix of the project root:
${PROGNAME}: SOURCE      : %s
${PROGNAME}: PROJECT-ROOT: %s\n"
readonly errMsg_s_pfxAndSourceSame='The name prefix and source are the same.'
readonly errMsg_pf_NotAPrefix_2="The given prefix is not a prefix of the source:
${PROGNAME}: SOURCE: %s
${PROGNAME}: PREFIX: %s\n"
readonly errMsg_pf_PrjRootPrefixOfSrc_2="The project root cannot be a prefix of the source file:
${PROGNAME}: SOURCE      : %s
${PROGNAME}: PROJECT-ROOT: %s\n"
readonly errMsg_s_nt_constant_slash="The project name can't begin with '/'."
readonly errMsg_s_nt_constant_relative="The project name can't be relative."
readonly errMsg_pf_Opt_CanOnlyForPrjType_Program_1='%s can only be used when the source is a program.\n'
readonly errMsg_s_Opt_InvalidOutputExt='The extension cannot be "lock", this extension is reserved for lock files.'
readonly errMsg_pf_Opt_CanOnlyForPrjType_Dir_1='%s can only be used when the source is a directoty.\n'
readonly errMsg_pf_ExactlyOneArgument_1='Exactly one argument expected (now %d).\n'
readonly errMsg_s_SourceMissing='No source given (give it as an argument or use --source=SOURCE).'
readonly errMsg_s_SourceDuplicate='The source cannot be given using --source and as an argument at the same time.'
readonly errMsg_s_NoArgumentExpected='No (non-option) argument expected.'
readonly errMsg_pf_prjNameHead_ContainsSlashes_1='The project name head cannot begin or end with a slash: %s'
readonly errMsg_rsync_s_usage="The options forwarded to \`rsync' are invalid."
readonly errMsg_rsync_s_error="The program \`rsync' failed - no backup created."
readonly errMsg_pf_CantCreateLock_1='Error locking - the lock file cannot be created (%s).\n'
readonly errMsg_pf_noBackup_CantCreateLock_1='No backup created - cannot create lock file: %s\n'
readonly errMsg_pf_noFreeDtPart="No backup created - there is already a backup for the current datetime: %s.
${PROGNAME}: Try again next second!\n"
readonly msg_pf_NoBackupInDir_1='No existing backups in the directory %s.\n'
readonly msg_s_BackupNotLocked='The backup is not locked.'
readonly msg_s_BackupAlreadyLocked='The backup is alread locked.'
readonly msg_pf_SyncingBackup_1='Updating backup: %s\n'
readonly msg_s_NoExistingCreatingNew='No existing updatable backup - creating a new.'
readonly msg_pf_cleaningDir_1='Cleaning directory: %s\n'

readonly msg_pf_ErrorUnlockingSkipping_1='Error removing the lock file, skipping locked backup: %s\n'
readonly msg_pf_WriteProtectedLockSkipping_1='The lock file is write-protected, skipping backup: %s\n'
readonly msg_s_WriteProtectedLockSkipping='The lock file is write-protected - unlocking not possible.'
readonly msg_pf_skippingLockedBackup_1='Skipping locked backup: %s\n'
readonly pgmMsg_s_skippingLockedBackup="${PROGNAME}: Skipping locked backup: "
readonly pgmMsg_s_WriteProtectedLockSkipping='${PROGNAME}: The lock file is write-protected, skipping backup: '
readonly msg_s_backupNotLocked_1='Backup not locked.'

declare -a aVarsNotUsed_bakDest_bakDir_sVarNam
declare -a aVarsNotUsed_bakDest_bakDir_sErrMsg
declare -a aBackupInfos

aVarsNotUsed_bakDest_bakDir_sVarNam[0]='NAMETYPE'
aVarsNotUsed_bakDest_bakDir_sErrMsg[0]='Naming scheme is not used (--absolute,--basename,--constant,--suffix,--suffix-home)'
aVarsNotUsed_bakDest_bakDir_sVarNam[1]='OUTPUTEXT'
aVarsNotUsed_bakDest_bakDir_sErrMsg[1]="Project name extension is not used (${optname_sExt})"
# CAUTION: If indexes is added or removed, also update
# aVarsNotUsed_bakDest_absArg_...!
# The first part of that array should be the above array!

readonly -a aVarsNotUsed_bakDest_bakDir_sVarNam
readonly -a aVarsNotUsed_bakDest_bakDir_sErrMsg

declare -a aVarsNotUsed_bakDest_absArg_sVarNam
declare -a aVarsNotUsed_bakDest_absArg_sErrMsg

aVarsNotUsed_bakDest_absArg_sVarNam=("${aVarsNotUsed_bakDest_bakDir_sVarNam[@]}")
aVarsNotUsed_bakDest_absArg_sErrMsg=("${aVarsNotUsed_bakDest_bakDir_sErrMsg[@]}")

readonly aVarsNotUsed_bakDest_absArg_sVarNam
readonly aVarsNotUsed_bakDest_absArg_sErrMsg

declare -a aMandatoryVars_bakDest_prjDir_envAndCla_sVarNam
declare -a aMandatoryVars_bakDest_prjDir_envAndCla_sErrMsg

aMandatoryVars_bakDest_prjDir_envAndCla_sVarNam[0]='PRJTYPE'
aMandatoryVars_bakDest_prjDir_envAndCla_sErrMsg[0]='Project type not given (use --file, --directory or --program).'

aMandatoryVars_bakDest_prjDir_envAndCla_sVarNam[1]='NAMETYPE'
aMandatoryVars_bakDest_prjDir_envAndCla_sErrMsg[1]='Naming scheme not given (use --absolute,--basename,--constant,--suffix or --suffix-home).'

readonly aMandatoryVars_bakDest_prjDir_envAndCla_sVarNam
readonly aMandatoryVars_bakDest_prjDir_envAndCla_sErrMsg

# Array variables must be declared as such before use.
declare -a GLOB_aRemainingArgs
declare -a RENAME_TAG_aBakInfo
declare -a aBakInfo_filePrjBak

###############################################################################
#   - functions -
###############################################################################

###############################################################################
# Prints a message from the program to stderr.
# The message is preceeded by the name of the executable.
###############################################################################
function echoMsg # MESSAGE...
{
    echo "${PROGNAME}: ${*}" >&2
}

###############################################################################
# -- echoMsgExit --
#
#   Prints a given message and exists with given status.
#
# Arguement: 1 : The exit code to exit with.
# Arguments: 2 : A message to be printed to stderr.
#
###############################################################################
function echoMsgExit # EXIT-CODE MESSAGE...
{
    st=${1}; shift
    echoMsg "${@}"
    exit ${st}
}

# Print message and exit with EXIT_ERROR.
function echoMsgExitErr # MESSAGE...
{
    echoMsgExit ${EXIT_ERROR} "${@}"
}

# Print message and exit with EXIT_USAGE.
function echoMsgExitUsage # MESSAGE...
{
    echoMsgExit ${EXIT_USAGE} "$@"
}

function printfMsg # printf-ARGUMENT...
{
    echo -n "${PROGNAME}: " >&2
    printf "$@" >&2
}

###############################################################################
# - printfMsgExit -
#
#   Prints a message and exists with given exit-code.
#
# Argument 1: The exit code to exit with.
# Argument: rest: arguments to pass to `printf' for printing.
###############################################################################
function printfMsgExit # EXIT-CODE <printf arguments>
{
    st=${1}; shift
    printfMsg "$@"
    exit ${st}
}

# Prints a printf formated message and exists with EXIT_ERROR.
function printfMsgExitErr # <printf arguments>
{
    printfMsgExit ${EXIT_ERROR} "$@"
}

# Prints a printf formated message and exists with EXIT_USAGE.
function printfMsgExitUsage # <printf arguments>
{
    printfMsgExit ${EXIT_USAGE} "$@"
}

###############################################################################
#   Prints the absolute path for the given filename.
#
# Argument 1: FILE, which must exist.
#
# Output: the absolute filename of FILE.
#
# IMPLEMENTATION
# --------------
#   The current directory is saved and restored using pushd and popd.
#   Get the absolute path by changing to the directory itself, or the
# directory containing the file.  The absolute path for the directory
# is then in ${PWD}.
#
# A. FILE is a directory.
# B. FILE is not a directory.
###############################################################################
function abspath # FILE
{
    if [ -d "${1}" ]; then
	pushd "${1}" > /dev/null
	d=${PWD}
	popd > /dev/null
	echo "${d}"
    else
	d=$(dirname "$1")
	b=$(basename "$1")
	pushd "${d}" > /dev/null
	d=${PWD}
	popd > /dev/null
	echo "${d}/${b}"
    fi
}

###############################################################################
# -- pathIsAbsolute --
#
# Argument: 1 : a path
# Output: Return 0 for false and 1 for true.
#
# An absolute path:
#   - start with a "/"
#   - doesn't contain "/.(/|$)" or "/..(/|$)"
###############################################################################
function pathIsAbsolute # PATH
{
    [ "${1:0:1}" != "/" ]        && return 1
    [[ "${1}" =~  /\.\.?(/|$) ]] && return 1
    return 0
}

###############################################################################
#   Formats a datetime to the format that is used in backup filenames.
#
#   The given datetime can be invalid, no checks are performed.
# The date must either already be a "copyback" date, or in the format that is
# printed by `presentBackup'.
#
# Argument 1: input date
# Output: the copyback date
###############################################################################
function formatDatetime # DATETIME
{
    if [[ "${1}" =~ ^${ereSimpbackDatetime}$ ]]; then
	echo "${1}"
    else
	echo "${1}" | ${SED} 's/[-:]//g;s/ /-/'
    fi
}

###############################################################################
# Tells if the given string WORDS contains _exactly_ the word WORD.
#
# A "word" is any nonempty sequence of non [[:space:]].
# WORDS is a sequence of words, separated by [[:space:]].
###############################################################################
function containsWord # WORDS WORD
{
    eval '[[ "$1" =~ (^|[[:space:]])('"$2"')([[:space:]]|$) ]]'
}

###############################################################################
# As containsword, but words are separated with a comma.
###############################################################################
function containsWordComma # WORDS WORD
{
    eval '[[ "$1" =~ (^|,)('"$2"')(,|$) ]]'
}

###############################################################################
# Creates a lock file with a given name.
#
# The file is given write permission.
#
# Argument: FILENAME the name of the lockfile.
#
# Exit status: boolean: if successful.
###############################################################################
function makeLockFile # FILENAME
{
    local -r fn="${1}"

    if touch "${fn}"; then
	chmod +w "${fn}"
    else
	false
    fi
}
###############################################################################
#  Set `aBakInfo_filePrjBak' to the bak-info array for a file.
#
# Argument: FILE : a copyback backup file (or directory) to set the bak-info
#                  array from.
#
# Sideeffekct: Exists with EXIT_ERROR if FILE exists but the basename of it
#              is not the name of a copyback backup.
#
# Sets: aBakInfo_filePrjBak: If FILE exists, the variable is set to the
#                           bak-info array for this file.
#                           If FILE does not exist, it is unset.
# Sets: sBakInfo_filePrjBak: Corresponding to the above.  The array as a
#                            single string with fields separated by /.
#
# A. Unset `aBakInfo_filePrjBak' and return if the file does not exist.
# B. FILE exists and has the right name.  Set  `aBakInfo_filePrjBak'.
#    1. Get the filename parts.
#    2. Get lock-file info into `sLockInfo'.
#    3. Set `aBakInfo_filePrjBak'.
# C. FILE exists but doesn't got the name of a copyback backup.  Exit with
#    EXIT_ERROR (and print a message).
###############################################################################
function set_aBakInfo_filePrjBak_orExit # FILE
{
    local file=${1} dir=$(dirname "${1}") bn=$(basename "${1}")

    ### A ###
    if [ ! -e "${file}" ]; then
	unset aBakInfo_filePrjBak
	return
    fi
    if [[ "${bn}" =~ ^${ereBakNameBn_BnHead_Dt_Tag_Ext} ]]; then
	### B ###
	# 1 #
	local sBn=${BASH_REMATCH[0]}
	local sBnHead=${BASH_REMATCH[1]}
	local sDt=${BASH_REMATCH[2]}
	local sTag=${BASH_REMATCH[3]}
	[ "${sTag}" ] && sTag="${sTag:1}"
	local sExt=${BASH_REMATCH[4]}

        aBakInfo_filePrjBak[${bakInfo_idx_dt}]="${sDt}"
        aBakInfo_filePrjBak[${bakInfo_idx_tag}]="${sTag}"
        aBakInfo_filePrjBak[${bakInfo_idx_bnHead}]="${sBnHead}"
        aBakInfo_filePrjBak[${bakInfo_idx_bn}]="${sBn}"
        aBakInfo_filePrjBak[${bakInfo_idx_ext}]="${sExt}"

	# 2 #

	local sBnLock="${sBnHead}${TRGLOCKSFX}"
	local fileLock="${dir}/${sBnLock}"
	local sLockFile
	local sLockFilePerm
	if [ -e "${fileLock}" ]; then
	    sLockFile="${sBnLock}"
	    if [ -w "${fileLock}" ]; then
		sLockFilePerm='w'
	    else
		sLockFilePerm='r'
	    fi
	else
	    sLockFile=''
	    sLockFilePerm=''
	fi
        aBakInfo_filePrjBak[${bakInfo_idx_lockFile}]="${sLockFile}"
        aBakInfo_filePrjBak[${bakInfo_idx_lockPerm}]="${sLockFilePerm}"
	local sLockInfo="${sLockFilePerm}/${sLockFile}"
	# 3 #
	sBakInfo_filePrjBak="${sDt}/${sLockInfo}/${sTag}/${sBnHead}/${sBn}/${sExt}"
    else
	### C ###
	unset aBakInfo_filePrjBak sBakInfo_filePrjBak
	printfMsg "${errMsg_pf_NotASimpbackBackup_1}" "${file}"
	exit ${EXIT_ERROR}
    fi
}

###############################################################################
#   Utility function used by `bakInfo_select'.
#
#   Produces all the information needed to produce the output from
# `bakInfo_select_prim'.  A backup file and lock file produces one
# line each.
# For a backup file: datetime:B:tag/basename-head/basename/extension
# For a lock   file: datetime:L:<access>/<lock-file-basename>
###############################################################################
function bakInfo_select_prim # DIRECTORY
{
    local dir=${1}
    # A #
    ls -U1 "${dir}" | {
	while read fn; do
	    # 1 #
	    if [[ "${fn}" =~ ^${ereBakNameBn_BnHead_Dt_Tag_Ext} ]]; then
		# 2 #
		sBn=${BASH_REMATCH[0]}
		sBnHead=${BASH_REMATCH[1]}
		sDt=${BASH_REMATCH[2]}
		sTag=${BASH_REMATCH[3]}
		[ "${sTag}" ] && sTag="${sTag:1}"
		sExt=${BASH_REMATCH[4]}

		if [ "${sExt}" = "${TRGLOCKSFX}" ]; then
		    fn="${dir}/${sBn}"
		    if [ -w "${fn}" ]; then
			echo "${sDt}:L:w/${sBn}"
		    else
			echo "${sDt}:L:r/${sBn}"
		    fi
		else
		    echo "${sDt}:B:${sTag}/${sBnHead}/${sBn}/${sExt}"
		fi
	    fi
	done
    }
}

###############################################################################
# Awk program that transforms the output from
#   'bakInfo_select_prim'
# into the format that is output from
#   'bakInfo_select'
#
# Each input line represents either a backup or lock file.
# lock file  : <dt>:L:/<bIsLocked>/<bLockIsWriteProtected>
# backup file: <dt>:B:<everything except datetime and lock-info>
#
# IFS should be ":".
#
# The program puts all datetimes in an array `aDt'.
# For each backup, it puts the backup info in the array aBakInfo[datetime].
# For each lock,   it puts the lock   info in the array aLckInfo[datetime].
# In the END, one line is printed for each datetime.  This is the information
# that `bakInfo_select' outputs.
###############################################################################
readonly bakInfo_select_all_awkProcess='
          { aDt[$1]=1        }
$2 == "B" { aBakInfo[$1]=$3  }
$2 == "L" { aLckInfo[$1]=$3  }
END       {
    for (dt in aDt)
	if (!(dt in aLckInfo))
	    print dt "///"                aBakInfo[dt]
	else if (!(dt in aBakInfo))
	    print dt "/" aLckInfo[dt]
	else
	    print dt "/" aLckInfo[dt] "/" aBakInfo[dt]
}'

###############################################################################
#   Like `bakInfo_select_all_awkProcess', but only print bak-infos for
# backup files - no lock-only-records.
###############################################################################
readonly bakInfo_select_bak_awkProcess='
$2 == "B" { aBakInfo[$1]=$3  }
$2 == "L" { aLckInfo[$1]=$3  }
END       {
    for (dt in aBakInfo)
	if (!(dt in aLckInfo))
	    print dt "///"                aBakInfo[dt]
	else
	    print dt "/" aLckInfo[dt] "/" aBakInfo[dt]
}'

###############################################################################
#   Like `bakInfo_select_all_awkProcess', but only print bak-infos for
# non-locked backup files (no lock-only-records).
###############################################################################
readonly bakInfo_select_bakNonLocked_awkProcess='
$2 == "B" { aBakInfo[$1]=$3  }
$2 == "L" { aLckInfo[$1]=$3  }
END       {
    for (dt in aBakInfo)
	if (!(dt in aLckInfo))
	    print dt "///" aBakInfo[dt]
}'

###############################################################################
#   Like `bakInfo_select_all_awkProcess', but only print bak-infos for
# backup files and lock-only-records whos lock is not read-only.
###############################################################################
readonly bakInfo_select_bakW_awkProcess='
$2 == "B" { aBakInfo[$1]=$3  }
$2 == "L" { aLckInfo[$1]=$3  }
END       {
    for (dt in aBakInfo)
	if (!(dt in aLckInfo))
	    print dt "///" aBakInfo[dt]
        else if (substr(aLckInfo[dt],1,1) == "w")
	    print dt "/" aLckInfo[dt] "/" aBakInfo[dt]
}'

###############################################################################
#   Prints information about the backups in a given directory.
#
#   The information should be everything that is needed for the commands.
#   One line is printed for each backup.  If there exists lock files without
# a corresponding backup file, one line is printed for the lock file too
# (although it can be excluded using some of the arguments).
#
#   Output fields are separated by '/'
# For a backup, the following fields are printed:
#     1. date-time-part
#     2. 'w' or 'r' if the lock is writable or read only respectively.
#        empty if the backup is not locked
#     3. lock-file filename
#        empty if the backup is not locked
#     4. tag
#     5. basename head (without tag and extension)
#     6. basename
#     7. extension (including the preceeding dot)
# For a lock file without a backup, the following is printed:
#     1. date-time-part
#     2. 'w' or 'r' if the lock is writable or read only,
#        respectively.
#     3. lock-file filename
#
#   The first part is the basename without the extension, the second
# is the basename including it.  The two parts are separated by a slash ('/').
#
# Argument 1: The (project) directory whose backups should be listed.
# Argument 2: FROM (all|bak|bak/w|bak/)
#               - 'all'   : Both backups and lock-onlys.
#               - 'bak'   : All backups (locked and unlocked).
#               - 'bak/w' : All backups without a readonly lock.
#               - 'bak/'  : All backups without any lock.
# Argument 3: WHERE: ('all'|'non-latest'|'latest'|'date/DATE'|'tag/TAG')
#             Filters the set of bak-infos specified by FROM.
#              - 'all'        : include all
#              - 'non-last'   : all but the latest
#              - 'last'       : only the latest
#              - 'date/DATE'  : the _single_ bak-info for the date DATE, or
#                               empty if the date is not found.  Gives 0|1 rec.
#              - 'tag/TAG'    : the _single_ bak-info for the tag TAG, or
#                               empty if the tag is not found.  Gives 0|1 rec.
# Argument 4: ORDERBY: optional ('asc'|'desc'|*)
#             How to order the result set. Anything other than 'asc', 'desc'
#             means random ordering.
#
# IMPLEMENTATION
# ----------------------------------------
#   Use `bakInfo_select_prim' to produce one line for each backup
# and lock file.  Thus, a locked backup results in two lines.  This data is
# then processed with an awk program to combine backup and lock information
# into single records.
#   For every WHERE, the bak-infos to apply the WHERE condition is produced
# by the chain of two programs described above.  It is called to "produce the
# FROM set".
#   Different awk programs are used depending on FROM.  Either one that
# prints all records (for both backup files with or without a lock file, and
# for lock only files), or one that only print lines for backup files.
#   Process this info with a awk program, to produce the final output.
#   The reason for using awk is that it's got associative arrays.  These are
# handy for combining the backup-file and lock-file infos.
#
# A. Select the awk program to use depening on FROM.  Store it in `awkProcess'.
# B. Get the bak-infos depending on WHERE "clause".
#    'all') 1. Set the extra options to pass to `sort' for the sorting
#              direction ORDERBY.
#           2. "Produce the FROM set" and then sort it.
#    'non-last')
#           1. Set the `cmdPostProc' to either copy the output or reverse it.
#              Using this command as the last in the pipe chain, the result
#              will be ordered correctly.
#           2. "Produce the FROM set", sort it in reverse order (sort -r ...),
#              remove the first bak-info (${SED} 1d) and then sort it (cat|tac).
#    'last')
#           The result is 0|1 record, so no sorting is needed.
#             "Produce the FROM set", sort it in reverse order (sort ...)
#           and then get the first bak-info (head -1).
#     date/*)
#     tag/*)
#           The result is 0|1 record, so no sorting is needed.
#           1. Set `sLookFor' to the string to look for, and `i' to the
#              index of the bak-info to look for it in.
#           2. "Produce the FROM set" and preprocess it with a loop that
#              looks for the given string.  If it is found, the bak-info
#              string is printed and we exit the loop.
#                 One "string bak-info record" is read for each iteration.
#                 This string is splitted into an array.  Then the array
#                 value at the index for the value is compared to the value
#                 we look for.
#     tag/*)
#           Similair to date/*).  The only difference is that we
# A. List all files using `ls'.  For each valid backupname, print a line that
#    can be used both for sorting the files without respect of any extension,
#    and getting the full basename with extension.  This requires two
#    "fields", each separated by '/'.  This output is passed to `sort' for
#    sorting, and then to `cut' for discarding what is not the "complete"
#    basename (including extension).
#    1. Skip non-backup files.
#    2. Set some variables.
#    3. Skip lock-files.
#    4. Print the line
###############################################################################
function bakInfo_select # DIRECTORY FROM WHERE ORDERBY
{
    local dir=${1} eFrom=${2} sWhere=${3} eOrderBy=${4}
    # A #
    local awkProcess
    case "${eFrom}" in
	'all')
	    awkProcess="${bakInfo_select_all_awkProcess}"
	    ;;
	'bak')
	    awkProcess="${bakInfo_select_bak_awkProcess}"
	    ;;
	'bak/w')
	    awkProcess="${bakInfo_select_bakW_awkProcess}"
	    ;;
	'bak/')
	    awkProcess="${bakInfo_select_bakNonLocked_awkProcess}"
	    ;;
    esac
    # B #
    case "${sWhere}" in
	'all')
	    # 1 #
	    local optSortDir=''
	    [[ ${eOrderBy} = 'desc' ]] && optSortDir='-r'
	    # 2 #
	    bakInfo_select_prim "${dir}"     | \
		${AWK} -F ':' "${awkProcess}" - | \
		sort ${optSortDir} -t '/' -k 1,1
	    ;;
	'non-last')
	    # 1 #
	    local cmdPostProc='tac'
	    [[ ${eOrderBy} = 'desc' ]] && cmdPostProc='cat'
	    # 2 #
	    bakInfo_select_prim "${dir}"     | \
		${AWK} -F ':' "${awkProcess}" - | \
		sort -r -t '/' -k 1,1        | \
		${SED} '1d'                     | \
		${cmdPostProc}
	    ;;
	'last')
	    bakInfo_select_prim "${dir}"     | \
		${AWK} -F ':' "${awkProcess}" - | \
		sort -r -t '/' -k 1,1        | \
		head -1
	    ;;
	date/* | tag/*)
	    # 1 #
            local sLookFor i
            if [ ${sWhere::1} = 'd' ]; then
		sLookFor=${sWhere:5}
		i=${bakInfo_idx_dt}
	    else
		sLookFor=${sWhere:4}
		i=${bakInfo_idx_tag}
	    fi
	    # 2 #
	    bakInfo_select_prim "${dir}"     | \
		${AWK} -F ':' "${awkProcess}" - | {
		IFS='/'
		declare -a aBakInfo
		while read sBakInfo; do
		    aBakInfo=(${sBakInfo})
		    if [[ ${sLookFor} = ${aBakInfo[${i}]} ]]; then
			echo "${sBakInfo}"
			exit
		    fi
		done
		}
	    ;;
    esac
}

###############################################################################
# Puts the lines output by bakInfo_select into the array aBackupInfos.
#
# All arguments are passed to bakInfo_select.
#
# Sets: aBackupInfos
###############################################################################
function bakInfo_select_aBackupInfos # bakInfo_select-ARGS
{
    local IFS="${IFS_NEWLINE}"
    aBackupInfos=($(bakInfo_select "${@}"))
}

###############################################################################
# Returns true if any of the backupInfos in aBackupInfos
# is a locked backup or a lock without a backup.
#
# ** Argument: OPTINAL --force
# If backups locked by a writable lock file is concidered to be locked or not.
###############################################################################
function aBackupInfos_containsLocking # [--force]
{
    local -a force="${1}"
    local -a bakInfo
    local sBakInfo
    local IFS='/'
    for sBakInfo in "${aBackupInfos[@]}"; do
	bakInfo=(${sBakInfo})
	case "${bakInfo[${bakInfo_idx_lockPerm}]}" in
	    'w')
		if [ -z "${force}" ]; then
		    return 0
		fi
		;;
	    'r')
		return 0
		;;
	esac
    done
    return 1
}

###############################################################################
# Tells if the bn-part record represents a locked backup or a lock file only.
#
# Argument: the fields of the record.
#
#   See `bakInfo_select' for information on the fields.
###############################################################################
function bakInfo_isLockOrLockedBackup # FIELD...
{
    local -a bakInfo=("${@}")
    [ -n "${bakInfo[${bakInfo_idx_lockFile}]}" ]
}

###############################################################################
# Tells if the bn-part record represents a lock-only record.
#
# Argument: the fields of the record.
#
#   See `bakInfo_select' for information on the fields.
###############################################################################
function bakInfo_isLockOnly # FIELD...
{
    [ $# = ${bakInfo_nNumFields_lockOnly} ]
}

###############################################################################
#   Rename a backup using a new or removed tag.
#
#   To rename using a tag, give the tag as the first arguments using --tag TAG.
# To remove a tag, don't give any tag, just the bak-info array.
#
# Argument 1: [--tag TAG] (optional) - the new tag.
# Argument 2: bak-info-array representing the existing backup
#
# Sets: RENAME_TAG_aBakInfo
#
# A. Parse arguments.  Set RENAME_TAG_aBakInfo and sNewTag.
# B. Extract the constant parts: datetime and extension.
# C. Set sTag to the new "filename tag component".
# D. Construct the new basename.
# E. Assign the new values to the arary using eval.
###############################################################################
function bakInfo_rename_tag # [--tag TAG] BAK-INFO-FIELD...
{
    # A #
    local sNewTag=
    if [ "${1}" = '--tag' ]; then
	sNewTag=${2}
	shift ; shift
    fi
    RENAME_TAG_aBakInfo=("$@")
    # B #
    local sDt="${RENAME_TAG_aBakInfo[${bakInfo_idx_dt}]}"
    local sExt="${RENAME_TAG_aBakInfo[${bakInfo_idx_ext}]}"
    # B #
    local sTag=
    if [ "${sNewTag}" ]; then
	sTag="-${sNewTag}"
    fi
    # C #
    local sBn
    sBn="copyback-${sDt}${sTag}${sExt}"
    # D #
    RENAME_TAG_aBakInfo[${bakInfo_idx_tag}]="${sNewTag}"
    RENAME_TAG_aBakInfo[${bakInfo_idx_bn}]="${sBn}"
}

###############################################################################
# - getMostRecentUpdatableBackup -
#
#   Sets OLDTRG, OLDTRG_BASENAME, OLDTRG_WoEXT and OLDTRG_fileLock to the most
#  recent updateable existing backup.
#   If bForce is False, locked backups are skipped.  Otherwise, locked backups
# are included and `CLO_bak_bLock' is set to True so that the backup is still
# locked after the backup.
#   If a non-locked updatable backup is found, a read-only lock file
# (with the name of ${OLDTRG_fileLock}) is created.
#
# Argument 1: The project directory to look for backups in.
# Argument 2: Force inclusion of locked files: non-empty for True
#
# Sets: OLDTRG
#   <arg 1> + '/' + basename of an existing backup (if updatable backup is
#   found)
# Sets: OLDTRG_BASENAME
#   The basename of OLDTRG.
# Sets: OLDTRG_WoEXT
#   As OLDTRG but with any extensions removed (if updatable backup is
#   found).
#   An extension is the part from (and including) any dot.
# Sets: OLDTRG_fileLock:
#   <arg 1> + '/' + basename of an existing backup (if updatable
#   backup is found)
# Sets: OLDTRG_TAG
#   Set to the tag of the old backup.  Empty if it didn't have one.
# Sets: CLO_bak_bLock
#   If a locked backup is found, this is set to True so that the the
#   updated backup will also be locked.
#
# Creates file: ${OLDTRG_fileLock}
#
# A. Forcing of including locked backups.
#    1. Get the backup name parts of the most recent updatable
#       backup inte sParts.
#       If a backup is not found, don't set any variables.
#    2. An existing backup was found.
#       1. Split sParts into the bn-part fields into the array `aFields'.
#       2. Set `OLDTRG', `OLDTRG_BASENAME', `OLDTRG_WoEXT', `OLDTRG_fileLock'
#          and `OLDTRG_TAG'.
#       3. Fix lock-file.
#          1. There backup is locked by an existing lock file.
#             Set `CLO_bak_bLock' so that the lock is preserved. TODO sätt CLO_bak_eLock=w|r
#          2. The backup is not locked.
#             Lock by creating lock file.
# B. Do not include locked backups.
#    1. Get the backup name parts of the most recent updatable, not locked
#       backup inte sParts.
#       If a backup is not found, don't set any variables.
#    2. An existing backup was found.
#       1. Split sParts into the basename without/with extension.
#       2. Set `OLDTRG', `OLDTRG_BASENAME', `OLDTRG_WoEXT', `OLDTRG_fileLock'
#          and `OLDTRG_TAG'.
#       3. Lock by creating lock file.  Unset `OLDTRG_BASENAME'.
#    3.
###############################################################################
function getMostRecentUpdatableBackup # DIRECTORY bForce
{
    local dir=${1} bForce=${2}
    local IFS='/'
    if [ "${bForce}" ]; then
	# A #
	# 1 #
	local sBakInfo
	sBakInfo=$(bakInfo_select "${dir}" 'bak/w' 'last')
	if [ "${sBakInfo}" ]; then
	    # 2 #
	    # 2.1 #
	    local -a aBakInfo
	    aBakInfo=(${sBakInfo})
	    # 2.2 #
	    OLDTRG_BASENAME="${aBakInfo[${bakInfo_idx_bn}]}"
	    local sBnHead="${aBakInfo[${bakInfo_idx_bnHead}]}"
	    OLDTRG="${dir}/${OLDTRG_BASENAME}"
	    OLDTRG_fileLock="${OLDTRG_WoEXT}${TRGLOCKSFX}"
	    OLDTRG_TAG="${aBakInfo[${bakInfo_idx_tag}]}"
	    OLDTRG_WoEXT="${dir}/${sBnHead}"
	    [ "${OLDTRG_TAG}" ] && OLDTRG_WoEXT="${OLDTRG_WoEXT}-${OLDTRG_TAG}"
	    # 2.3 #
	    if [ "${aBakInfo[${bakInfo_idx_lockPerm}]}" ]; then
		# 2.3.1 #
		CLO_bak_bLock=1 # TODO ="${aBakInfo[${bakInfo_idx_lockPerm}]}"
	    else
		# 2.3.2 #
		makeLockFile "${OLDTRG_fileLock}"
	    fi
	fi
    else
	# B #
	# 1 #
	local sBakInfo
	#sBakInfo=$(bakInfo_select_sortedOnDt "${dir}" '-r' | bakInfo_filterOut_LockedBackups | head -1)
	sBakInfo=$(bakInfo_select "${dir}" 'bak/' 'last')
	if [ "${sBakInfo}" ]; then
	    # 2 #
	    # 2.1 #
	    local -a aBakInfo
	    aBakInfo=(${sBakInfo})
	    # 2.2 #
	    OLDTRG_BASENAME="${aBakInfo[${bakInfo_idx_bn}]}"
	    local sBnHead="${aBakInfo[${bakInfo_idx_bnHead}]}"
	    OLDTRG="${dir}/${OLDTRG_BASENAME}"
	    OLDTRG_fileLock="${OLDTRG_WoEXT}${TRGLOCKSFX}"
	    OLDTRG_TAG="${aBakInfo[${bakInfo_idx_tag}]}"
	    OLDTRG_WoEXT="${dir}/${sBnHead}"
	    [ "${OLDTRG_TAG}" ] && OLDTRG_WoEXT="${OLDTRG_WoEXT}-${OLDTRG_TAG}"
	    # 2.3 #
	    makeLockFile "${OLDTRG_fileLock}"
	fi
    fi
}

###############################################################################
#   Prints the datetime part to use for the next backup in a given directory.
#
#   Nothing is printed if the datetime is occupied.
# for a given date+time-part.
#
# Argument 1: project directory
# Argument 2: Date+time-part of a backupname (incl. seconds): YYYYMMDD-hhmmss
#
# A. List all backups using `bakInfo_select'.
#    Process each in a subprocces who's task is
#    to print the datetime part we can used or '', if non if all are busy.
#    The "processing" process works as follows:
#      1. Set the answer to datetime without seconds.
#      2. If we find a backup for this minute (any seconds), set the answer to
#         include seconds.
#      3. If we find a backup for this second, exit without printing anything.
#      4. We have processed all backups, print ANS.
###############################################################################
function getFreeDtPartForDatetime # DIRECTORY YYYYMMDD-hhmmss
{
    local dirPrjDir=${1}
    local sDtPart_sec=${2}
    local sDtPart_min=${2::13}

    # A #
    bakInfo_select "${dirPrjDir}" 'all' 'all' '-' | {
	IFS='/'
	# 1 #
	ANS=${sDtPart_min}
	while read sDt sRest; do
	    # 2 #
	    if [ "${sDt::13}" = "${sDtPart_min}" ]; then
		ANS=${sDtPart_sec}
	    fi
	    # 3 #
	    if [ "${sDt}" = "${sDtPart_sec}" ]; then
		exit
	    fi
	done
	echo "${ANS}"
    }
}

###############################################################################
#   Generates a backup (target) namn and creates a lock file for that name.
#
#   Exits with an error message if no backup name is free for the currrent
# datetime.
#
# Argument 1: project directory.
# Argument 2: DATE-TIME part of filename [YYYYMMDD-hhmmss]
# Argument 3: (optional) TAG. An empty TAG represents a non-existing TAG.
#
# Uses: TRGLOCKSFX
# Uses: test_DateNow
#
# Sets: TARGET_WoEXT
# Sets: TARGET_fileLock
#
# Sets: TARGET_BN_HEAD
# Sets: TARGET_BN_WoEXT # TARGET_BN_HEAD + tag (if a tag is given)
# Sets: TARGET_BN_LOCK  # TARGET_BN_HEAD + lock extension
#
# Creates file: TARGET_fileLock
#
# A. Run `getFreeDtPartForDatetime' to get the name of the latest existing
#    backup (for our datetime-part) into `sFreeDtPart'.
# B. No free dtpart - print error message and exit.
# C. Set TARGET_BN_HEAD.
# D. Set TARGET_BN_WoEXT and TARGET_BN_LOCK.
# E. Set `TARGET_WoEXT'.
# F. Set `TARGET_fileLock' and create the lock-file.
###############################################################################
function getAndLockFreshBackupNameForDtPart # DIRECTORY DATETIME-PART [TAG]
{
    local dirPrjDir=${1}
    local sDtPart=${2}
    local sTag=${3}

    # A #
    sFreeDtPart=$(getFreeDtPartForDatetime "${dirPrjDir}" "${sDtPart}")
    # B #
    if [ ! "${sFreeDtPart}" ]; then
	printfMsgExitErr "${errMsg_pf_noFreeDtPart}" ${sDtPart}
    fi
    # C #
    TARGET_BN_HEAD=$(printf "${format_bakName_fromDtPart_1}" "${sFreeDtPart}")
    # D #
    TARGET_BN_LOCK="${TARGET_BN_HEAD}${TRGLOCKSFX}"
    TARGET_BN_WoEXT=${TARGET_BN_HEAD}
    [ "${sTag}" ] && TARGET_BN_WoEXT="${TARGET_BN_WoEXT}-${sTag}"
    # E #
    TARGET_WoEXT="${dirPrjDir}/${TARGET_BN_WoEXT}"
    # F #
    TARGET_fileLock="${dirPrjDir}/${TARGET_BN_LOCK}"
    makeLockFile "${TARGET_fileLock}"
}

###############################################################################
#   Runs getAndLockFreshBackupNameForDtPart with the current datetime.
#
# Sets: See getAndLockFreshBackupNameForDtPart.
###############################################################################
function getAndLockFreshBackupNameForCurrTime # DIRECTORY [TAG]
{
    local sDtPart=$(date +"${format_date_DtPart}")

    if [ $# = 2 -a "${2}" ]; then
	getAndLockFreshBackupNameForDtPart "${1}" "${sDtPart}" "${2}"
    else
	getAndLockFreshBackupNameForDtPart "${1}" "${sDtPart}"
    fi
}

###############################################################################
#   Tells if the given directory contains any copyback backups.
#
# Return: 0 - yes, 1 - no
#
# List the copyback-files of the directory using `bakInfo_select' and `wc'.
###############################################################################
function dirContainsBackups # DIRECTORY
{
    local nSbFiles=$(bakInfo_select "${1}" 'all' 'all' '-' | wc -l)
    [ "${nSbFiles}" != '0' ]
}

###############################################################################
#   Prints the name, relative DIRECTORY, of presumptive project directories
# found under DIRECTORY.
#
#   DIRECTORY itself is not printed.
#
# Argument 1: DIRECTORY - the directory to search under
#
# Output: one directory per line (if directories don't contain new-line).
###############################################################################
function findPresumptiveProjectSubDirs # DIRECTORY
{
    find "${1}" -mindepth 1 -type d \
	\( -regex "${find_ereBakNameFn}" -prune -o -printf '%P\n' \)
}

###############################################################################
#   Prints the names of all directories that correspond to a copyback project
# with existing backups, sorted.
#
#   The directory itself and all its sbdirectories are inspected.  (The
# exception is of course directories that are copyback backups themselves.)
#
# A. Print the name of the current directory if it contains backups.
# B. Descend subdirectories that are not backups.
###############################################################################
function doFindProjectDirs # DIRECTORY
{
    local dir=${1}
    #echo "dir=${dir}"
    # A #
    dirContainsBackups "${dir}" && echo '.'
    # B #
    findPresumptiveProjectSubDirs "${dir}" | {
	while read subdir; do
	    dirContainsBackups "${dir}/${subdir}" && echo "${subdir}"
	done
    } | sort
}


###############################################################################
# Implements the command 'remove-project'.
#
# SPECIFICATION (put this in the manual instead):
#
# - (A). If the project directory (PD) does contain locked backups,
#   or lockfiles, nothing is done.
#   (Perhaps it would be usefull with a --force option that overrides this.)
# - (B). Otherwise, remove all copyback backup related files in the directory
#   (remove copyback backup directories recursively, of course).
# - (C). If (B), and a backup root directory (BRD) is given (which is a parent
#   of the PD, empty directories - starting with the PD - are removed down to
#   the BRD, but not including it.
#
# * Uses
# ** Uses: CLO_bForce.
#
# * Arguments
# ** The project directory.
#    This is the directory from which to remove all backups.
# ** OPTIONAL A parent dirctory of the project directory, that tells where to
#    stop removing empty parent dirctories of the project directory.
#    If given, this is a parent directory of the project directory -
#    "literary".  This string must be an existing directory, be a prefix of
#    the previous argument, and not end with a '/'.
###############################################################################
function doRemoveProject # dirPrjDir [dirStopRmdirAtParent]
{
    #
    # AA. Assign local variables from the arguments.
    # BB. Quit if any needed argument is missing.
    # CC. Remove all backups from the project directory.
    # DD. Remove the project directory if it is empty.
    # EE. If the backup root directory is given: remove empty directories
    #     as specified in the description of the arguments.

    # AA #
    local dirPrjDir=${1}
    local dirStopRmdirAtParent=${2}

    local -r msgRemDir="Removed empty directory "

    # BB #
    if [ -z "${dirPrjDir}" ]; then
	echoMsgExitErr 'The project directory cannot be derived.'
    fi
    # CC #
    ## Read the backups (into the array aBackupInfos).
    bakInfo_select_aBackupInfos "${dirPrjDir}" 'all' 'all'
    ## Exit if there are locked backups.

    if aBackupInfos_containsLocking ${CLO_bForce}; then
	echoMsgExitErr 'Aborting, since the project contains locked backups.'
    fi

    ## Remove all backups.
    for bakInfo in "${aBackupInfos[@]}"; do
	if ! removeBackupForBakInfo ${CLO_bForce} "${dirPrjDir}" "${bakInfo}"; then
	    exit ${EXIT_ERROR}
	fi
    done
    # DD #
    if rmdir "${dirPrjDir}" 2> /dev/null; then
	echoMsg "${msgRemDir}${dirPrjDir}"
    fi
    # EE #
    dirPrjDir="$(dirname "${dirPrjDir}")"
    if [ -n "${dirStopRmdirAtParent}" ]; then
	while [ "${dirPrjDir}" != "${dirStopRmdirAtParent}" ]; do
	    if ! rmdir "${dirPrjDir}" 2> /dev/null; then
		break
	    fi
	    echoMsg "${msgRemDir}${dirPrjDir}"
	    dirPrjDir="$(dirname "${dirPrjDir}")"
	done
    fi
}

###############################################################################
#   Tells if the given filename is the name of a copyback backup file (or
# directory).
#
#   Only checks the basename.  Could be modified to check each component
# of the path to detect if any of these is the name of a copyback backup. If
# there is one, then this file resides _inside_ a copyback backup, so it is
# not a copyback backup itself.
###############################################################################
function isSimpbackBackupFilename # FILE
{
    [[ "$(basename "${1}")" =~ ^${ereBakNameBn} ]]
}

###############################################################################
#   Given a backup filename, LOCK_FILENAME is set to the name of the
# corresponding lockfile.  Only strings are operated on - no checks of whether
# any files exists or not.
#   If the backup-name given is not a valid copyback backup name, an
# erormssage is printed and the program exists with non-zero exit status.
#
# Sets: LOCK_FILENAME
###############################################################################
function lockFileNameFromBakName # BACKUP-FILENAME
{
    local fileBak=${1}
    local dir=$(dirname "${fileBak}")
    local bakHead=$(basename "${fileBak}")
    [[ "${bakHead}" =~ ^${ereBakNameBn} ]] || \
	printfMsgExitErr "${errMsg_pf_NotASimpbackBackup_1}" "${fileBak}"
    [[ "${bakHead}" =~ ^([^.]*)\..* ]] && bakHead="${BASH_REMATCH[1]}"
    LOCK_FILENAME="${dir}${dir:+/}${bakHead}${TRGLOCKSFX}"
}

###############################################################################
#   Unlocks a given backup by removing the given lock-file.  Can also print the
# name of the removed backup.
#
# Option: --print: If this flag is present, PRINTED-FILENAME will be printed
#             to stdout if the backup is unlocked successfully.
# Argument 1: LOCK-FILE - Name of the lock-file.
# Argument 2: PRINTED-FILENAME - If name of the backup that is printed.
#
#
# Returns 0 - backups has no lock or lock removed successfully.
#             If a lockfile is removed, PRINTED-FILENAME is
#             printed.
# Returns EXIT_ERROR: The backup has a lock but this cannot be
#                     removed.   Either the lockfile is write-protectd or
#                     cannot be removed for other circumstances.
#
# A. Create the lock file basename (sBnLock), the lock filename
#    (fileLock) and the lock file permission (eLockPerm).
# B. Depending on the lock file permission...
#    'w') Remove the lock file.  Return EXIT_ERROR if unsuccessful.
#    'r') Don't unlock.  Return EXIT_ERROR.
#      *) Backup is already unlocked.  Print a message and return 0.
##############################################################################
function tryUnlockBakFile_prim_2 # DIRECTORY BAK-INFO-FIELD...
{
    local dir=${1}
    shift
    local -a aBakInfo
    aBakInfo=("$@")
    # A #
    local sBnLock="${aBakInfo[${bakInfo_idx_bnHead}]}${TRGLOCKSFX}"
    local fileLock="${dir}/${sBnLock}"
    # B #
    case "${aBakInfo[${bakInfo_idx_lockPerm}]}" in
	'w')
	    if ! rm -f "${fileLock}"; then # TODO behövs -f här?
		printfMsg "${msg_pf_ErrorUnlockingSkipping_1}" "${fileLock}"
		return ${EXIT_ERROR}
	    fi
	    ;;
	'r')
	    echoMsg "${msg_s_WriteProtectedLockSkipping}"
	    return ${EXIT_ERROR}
	    ;;
	*)
	    return 0
	    ;;
    esac
}

###############################################################################
#   Creates a lock file if the backup given as argument is not already locked,
# and prints the name of the backup file.
#
# Output: basename of backup (even if it was already locked, but not if the
#         lock file could not be created.)
#
# Returns: 0 - success
# Returns: EXIT_ERROR - cannot create the lock file.
#
# 1. Set `aBakInfo' to the fields of the bak-info, and
#    `sBakFile' to the backup basename.
# 2. If the backup is NOT already locked...
#    Construct the lock file name and try to create it.  Exit with an
#    error message if we can't.
# 3. Print the name of the backup.
###############################################################################
function bakInfo_doTryLockAndPrint # DIRECTORY BAK-INFO-RECORD-AS-SINGLE-STRING
{
    local dir=${1}
    # 1 #
    local IFS='/'
    local -a aBakInfo
    aBakInfo=(${2})
    local sBakFile="${aBakInfo[${bakInfo_idx_bn}]}"
    # 2 #
    if [ ! "${aBakInfo[${bakInfo_idx_lockFile}]}" ]; then
	local sBnHead="${aBakInfo[${bakInfo_idx_bnHead}]}"
	local fileLock="${dir}/${sBnHead}${TRGLOCKSFX}"
	if ! makeLockFile "${fileLock}"; then
	    printfMsg "${errMsg_pf_CantCreateLock_1}" "${fileLock}"
	    return ${EXIT_ERROR}
	fi
    fi
    # 3 #
    echo "${sBakFile}"
}

###############################################################################
# -- doCleanDir --
#
#   In a given directory: removes all copyback backups, except for
# the most recent one. Also leave locked backups. (Write-protected backups, on
# the other hand, may be removed.)
#
# Argument 1: Directory to clean.
# Argument 2: Force deletion of locked files: non-empty for True
#
# A. Loop over all backups except the first.
#    Set IFS to split.  Read the bak-info array using `read'.
#    1. Skip the backup if it is locked and we are not using --force.
#    2. Try to remove the backup.
###############################################################################
function doCleanDir # DIRECTORY bForce
{
    local dir=${1} bForce=${2}
    # A #
    bakInfo_select "${dir}" 'bak' 'non-last' 'desc' | {
	IFS='/'
	while read -a aBakInfo; do
	    # 1 #
	    if [ "${aBakInfo[${bakInfo_idx_lockPerm}]}" -a ! "${bForce}" ]; then
		echo -n "${pgmMsg_s_skippingLockedBackup}" >&2
		presentBackup "${aBakInfo[@]}" >&2
		continue
	    fi
	    # 2 #
	    if tryUnlockBakFile_prim_2 "${dir}" "${aBakInfo[@]}"; then
		fileBak="${dir}/${aBakInfo[${bakInfo_idx_bn}]}"
		rm -rf "${fileBak}" && presentBackup "${aBakInfo[@]}"
	    fi
	done
    }
}

###############################################################################
# -- doCleanDirsRecursively --
#
#   Cleans directories recursively starting from $1.
#   For each directory to clean: clean it and then decend directories that are
# not copyback backups.
#
#   Comment: A directory under a copyback backup root, that is not a copyback
# backup
# itself, should not contain plain files since plain source files have their
# own _subdirectory_ for storing their backups.  Therefore, this program could
# assume to not find any plain files.  But we do not do that - we allow for
# these "mystical" files to exist.
#
#
# Argument 1 : Root directory for start of cleaning.
# Argument 2 : Force deletion of locked files: non-empty for True
#
# A. Clean the current directory if it contains any backups.
#    Decrease `nVerboseLvl' before calling `doCleanDir' to supress output
#    from it.  Increase again afterwards to restore previous level.
# B. Get all subdirectories that are presumptive Project directories.
#    And repeat the above for each of them.
###############################################################################
function doCleanDirsRecursively # DIRECTORY bForce
{
    local dir=${1} bForce=${2}
    # A #
    if dirContainsBackups "${dir}"; then
	[  ${nVerboseLvl} -gt 0 ] && printfMsg "${msg_pf_cleaningDir_1}" "${dir}"
	let --nVerboseLvl
	doCleanDir "${dir}" "${bForce}"
	let ++nVerboseLvl
    fi
    # B #
    findPresumptiveProjectSubDirs "${dir}" | {
	while read sSubdir; do
	    sCurrSubDir="${dir}/${sSubdir}"
	    if dirContainsBackups "${sCurrSubDir}"; then
		[  ${nVerboseLvl} -gt 0 ] && printfMsg "${msg_pf_cleaningDir_1}" "${sCurrSubDir}"
		let --nVerboseLvl
		doCleanDir "${sCurrSubDir}" "${bForce}"
		let ++nVerboseLvl
	    fi
	done
    }
}

###############################################################################
#   Prints the "formated" version of the given date, without a newline
# character.
###############################################################################
function printFormatedDate_WoNl # YYYYMMDD-hhmm[ss]
{
    local sDt=${1}
    local sDate="${sDt::4}-${sDt:4:2}-${sDt:6:2}"
    local sHhMm="${sDt:9:2}:${sDt:11:2}"
    local sFix="${sDate} ${sHhMm}"
    local sSs=${sDt:13:2}
    if [ ${#sDt} = 13 ]; then
	echo -n "${sFix}"
    else
	echo -n "${sFix}:${sSs}"
    fi
}

###############################################################################
#   Prints a bak-info record formatted.
#
# Output: formatted backup info
#
# A. Put the bak-info record in an array.
# B. Set the date-time output to `sDtFmt'.
# C. Set `sLockFmt' to the string to print for locking - the asterisk.
# D. Set the tag to `sTagFmt' to empty or the formatted tag, if there is one.
# E. Print.
###############################################################################
function bakInfo_printFormatted # BAK-INFO-FIELD...
{
    # A #
    local -a aBakInfo
    aBakInfo=("$@")
    # B #
    local sDt="${aBakInfo[${aBakInfo_idx_dt}]}"
    local sDate="${sDt::4}-${sDt:4:2}-${sDt:6:2}"
    local sHhMm="${sDt:9:2}:${sDt:11:2}"
    local sFix="${sDate} ${sHhMm}"
    local sSs=${sDt:13:2}
    if [ ${#sDt} = 13 ]; then
	sDtFmt="${sFix}"
    else
	sDtFmt="${sFix}:${sSs}"
    fi
    # C #
    sLockFmt=''
    case "${aBakInfo[${bakInfo_idx_lockPerm}]}" in
	'r') sLockFmt='**' ;;
	'w') sLockFmt='*'  ;;
	  *) sLockFmt=''   ;;
    esac
    # D #
    local sTagFmt="${aBakInfo[${bakInfo_idx_tag}]}"
    if [ "${sTagFmt}" ]; then
	sTagFmt="\"${sTagFmt}\""
    fi
    # E #
    printf '%-21s %s\n' "${sDtFmt}${sLockFmt}" "${sTagFmt}"
}

###############################################################################
#   Print a backup to stdout, either as its filename or formatted.
#
# Uses: eBakPresFormat
#
# Output: One line presenting a backup.
#
# A. Get the directory - if one is given - and shift it away.
# B. Get the bakInfo into an array.
# C. Print.
#    1. Print formatted.
#    2. Print filename/filename-extra.
#       First print the directory and the filename without extra info and
#       newline.  Then if 'filename-extra' print asterisks and newline,
#       otherwise, print newline only.
###############################################################################
function presentBackup # [-d DIR] BAK-INFO-FIELD...
{
    # A #
    local dir=
    if [ "$1" = '-d' ]; then
	dir=${2}
	shift ; shift
    fi
    # B #
    local -a aBakInfo
    aBakInfo=("$@")
    # C #
    if [ "${eBakPresFormat}" = 'formatted' ]; then
	# 1 #
	bakInfo_printFormatted "${aBakInfo[@]}"
    else
	# 2 #
	[ "${dir}" ] && echo -n "${dir}/"
	echo -n "${aBakInfo[${bakInfo_idx_bn}]}"
	if [ "${eBakPresFormat}" = 'filename-extra' ]; then
	    case "${aBakInfo[${bakInfo_idx_lockPerm}]}" in
		'r') echo '**' ;;
		'w') echo '*'  ;;
		  *) echo      ;;
	    esac
	else
	    echo
	fi
    fi
}

###############################################################################
# Removes the backup, or backup lock file, specified by the given bakInfo
# record.
#
# Backups locked by a read-only lock-file, or read-only lock-files
# cause error.
#
# ** Argument: OPTIONAL "--force".
# If given, backups locked by writable lock files will be removed.
# ** Argument: The project directory that contains the files listed in the
# BAK-INFO argument.
# ** Argument: BAK-INFO record as a string.
#
# Exit status: ERROR if the bakInfo is locked by a read-only lock file.
###############################################################################
function removeBackupForBakInfo # [--force] PROJECT-DIRECTORY bakInfo
{
    #
    # AA. Read CLAs.
    # BB. Split the record into an array.
    # CC. Handle the lock file, if any.
    #     10. Fail if it is read-only.
    #     20. Try to remove it if we are "forcing".
    # DD. Remove the backup, if any.
    #

    ### AA ###
    if [ "_${1}" = '_--force' ]; then
	bForce=1
	shift
    fi
    local dirPrjDir="${1}"
    ### BB ###
    local IFS='/'
    local -a bakInfo=(${2})
    ### CC ###

    if [ -n "${bForce}" ]; then
	if ! tryUnlockBakFile_prim_2 "${dirPrjDir}" "${bakInfo[@]}"; then
	    return 1
	fi
    else
	local -r lockPerm="${bakInfo[${bakInfo_idx_lockPerm}]}"
	if [ -n "${lockPerm}" ]; then
    	    printfMsg 'Not removing locked backup %s.\n' "$(presentBackup "${aBakInfo[@]}")"
	fi
    fi
    ### DD ###
    local -r bn="${bakInfo[${bakInfo_idx_bn}]}"
    if [ -n "${bn}" ]; then
	printfMsg 'Removing backup %s\n' $(presentBackup "${bakInfo[@]}")
	local -r fileBak="${dirPrjDir}/${bn}"
	if ! rm -rf "${fileBak}"; then
	    printfMsg 'Failed to remove backup %s.\n' "$(presentBackup "${aBakInfo[@]}")"
	    return 1
	fi
    fi
}

###############################################################################
#   Prints the basename of backups in the given directory in creation-time
# order.
#
# Argument 1: How to format the output. Either 'formatted' or 'filename'.
# Argument 2: The (project) directory to list.
#
# A. Read CLA.
# B. Iterate over all backups.
#    1. For each backup, read the bak-info and split it to the array `aBakInfo.
#    2. Print the date/filename.
#    3. Print an asterisk if the backup is locked.  Also print the ending
#       newline.
###############################################################################
function doListBackups # DIRECTORY
{
    # A #
    local dir=${1}
    # B #
    bakInfo_select "${dir}" 'bak' 'all' 'asc' | {
	IFS='/'
	declare -a aBakInfo
	while read sBakInfo; do
	    # 1 #
	    aBakInfo=(${sBakInfo})
	    # 2 #
	    presentBackup "${aBakInfo[@]}"
	done
    }
}

###############################################################################
#   Locks a given backup.
#
#   If the backup is already locked, a message and printed and nothing more is
# done.
#   No check is done if the file exists or is a copyback backup, it could be
# any file - it is only the lock file that is considered.
#
# A. Print message and exit if the lockfile already exists (according to the
#    bak-info).
# B. Create the lock file basename (sBnLock), and the lock filename
#    (fileLock).
# C. Create a writable lockfile.
#    Print error message and exit if it does not succeed.
# D. Update bakInfo to include info about the new lock file.
#    We have to check explicitly if the lock file is writable or not, since
#    "umask" influence which permissions it has got.
# F. "Present" the backup to the user.
###############################################################################
function cmdLockBackup # DIRECTORY BAK-INFO-FIELD...
{
    local dir=${1}
    shift
    local -a aBakInfo
    aBakInfo=("$@")
    # A #
    if [ "${aBakInfo[${bakInfo_idx_lockPerm}]}" ]; then
	presentBackup -d "${dir}" "${aBakInfo[@]}"
	echoMsgExit 0 "${msg_s_BackupAlreadyLocked}"
    fi
    # B #
    local sBnLock="${aBakInfo[${bakInfo_idx_bnHead}]}${TRGLOCKSFX}"
    local fileLock="${dir}/${sBnLock}"
    # C #
    if ! makeLockFile "${fileLock}"; then
	printfMsgExitErr "${errMsg_pf_CantCreateLock_1}" "${fileLock}"
    fi
    # D #
    aBakInfo[${bakInfo_idx_lockFile}]=${sBnLock}
    if [ -w "${fileLock}" ]; then
	aBakInfo[${bakInfo_idx_lockPerm}]='w'
    else
	aBakInfo[${bakInfo_idx_lockPerm}]='r'
    fi
    # E #
    presentBackup -d "${dir}" "${aBakInfo[@]}"
}

###############################################################################
#   Unlocks a given backup.
#
#   If the backup is already unlocked, a message and printed and nothing more
# is done.
#   No check is done if the file exists or is a copyback backup, it could be
# any file - it is only the lock file that is considered.
#
# A. Print message and exit if the lockfile already exists (according to the
#    bak-info).
# B. Create the lock file basename (sBnLock), and the lock filename
#    (fileLock).
# C. Create a lockfile.
#    Print error message and exit if it does not succeed.
# D. Update bakInfo to include info about the new lock file.
#    We have to check explicitly if the lock file is writable or not, since
#    "umask" influence which permissions it has got.
# F. "Present" the backup to the user.
###############################################################################
function doUnlockBackup # DIRECTORY BAK-INFO-FIELD...
{
    local dir=${1}
    shift
    local -a aBakInfo
    aBakInfo=("$@")
    # A #
    tryUnlockBakFile_prim_2 "${dir}" "${aBakInfo[@]}"
    local st=$?
    if [[ $st = 0 ]]; then
	presentBackup -d "${dir}" "${aBakInfo[@]}"
	return 0
    else
	return $st
    fi
}

###############################################################################
#   Lock all existing backups in the given directory.
#
#   Locks all backups that can be locked, even if one of them could not be.
#
# Argument 1: Project directory.
#
# Output: prints the names of all backups (in time-creation order).
#
# Returns: 0 if we succeeded locking all unlocked backups,
#          non-zero otherwise.
#
# A. Iterate over all existing backups.
#    1. Split sParts into the basename without/with extension and create the
#       lock file filename.  Set TARGET to the name of the backup.
#    2. Try to lock it using `bakInfo_doTryLockAndPrint'.  Store EXIT_ERROR
#       as our exit code if one locking fails.
#    3. Exit with the right value (which is propagated to the top level
#       process).
###############################################################################
function cmdLockAll # DIRECTORY
{
    local dir=${1}
    # A #
    bakInfo_select "${dir}" 'bak' 'all' 'asc' | {
	st=0
	while read sBakInfoRec; do
	    # 1 #
	    if ! bakInfo_doTryLockAndPrint "${dir}" "${sBakInfoRec}"; then
		st=${EXIT_ERROR}
	    fi
	done
	exit ${st}
    }
}

###############################################################################
#   Unlock all existing backups in the given directory.
#
#   Unlocks all backups that can be unlocked, even if one of them could not.
#
# Argument 1: Project directory.
#
# Output: prints the names of all backups (in time-creation order).
#
# Returns: 0 if we succeeded unlocking all locked backups,
#          non-zero otherwise.
#
# A. Iterate over all existing backups and unlock them using
#    `doUnlockBackup'.
###############################################################################
function cmdUnlockAll # DIRECTORY
{
    local dir=${1}
    # A #
    bakInfo_select "${dir}" 'bak' 'all' 'asc' | {
	IFS='/'
	while read -a aBakInfo; do
	    doUnlockBackup "${dir}" "${aBakInfo[@]}"
	done
    }
}

###############################################################################
# - doCreateNewBackup -
#
#   Creates a new backup.
#   If an error occurs, no backup is created, an errormessage is printed and
# the function returns non-zero.
#
# Argument: [TAG]
#
# Sets: TARGET - The name of the created backup.
#
# A. Source is a file.
#    1. Generate unique target name for this project and lock it.  Also set
#       TARGET.
#    2. Copy the file.
#    3. Post-process the file.
# B. Source is a directory.
#    1. Generate unique target name for this project and lock it.  Set
#       TARGET to the name of it.
#    3. Copy with `rsync'.
#    4. Postprocess the directory.
# C. Source is a program.
#    1. Generate unique target name for this project and lock it.
#    2. Set `TARGET'.  If an extension is given, append it. Sets 'TARGET'.
#    3. If SOURCE is '-', the program should be `cat'.
#    4. Run program and redirect stdout to the TARGET.
#    5. New backup created successfully.  Do post-processing of the file
#       (and set TARGET).
#    6. Failed to create new backup.  Remove the created target-file and
#       lock file.  Return with EXIT_ERROR.
# D. If `CLO_bak_bLock': write-protect the backup by leaving the lock-file.
#    Otherwise, remove the lock file.
###############################################################################
function doCreateNewBackup # [TAG]
{
    local sTag=${1}

    if [ "${PRJTYPE}" = 'file' ] ; then
        ### A ###
	# A1 #
	getAndLockFreshBackupNameForCurrTime "${dirPrjDir}" "${sTag}"
	# A2 #
	run_rsync "${SRC}" "${TARGET_WoEXT}"
	# A3 #
	postProcBakFile "${TARGET_WoEXT}" "${TARGET_BN_WoEXT}"
    elif [ "${PRJTYPE}" = 'directory' ] ; then
        ### B ###
	# .1 #
	getAndLockFreshBackupNameForCurrTime "${dirPrjDir}" "${sTag}"
	TARGET="${TARGET_WoEXT}"
	# .3 #
	run_rsync "${SRC}/" "${TARGET_WoEXT}"
	# .4 #
	postProcBakDir "${TARGET_WoEXT}" "${TARGET_BN_WoEXT}"
    elif [ "${PRJTYPE}" = 'program' ] ; then
        ### C ###
	# 1 #
	getAndLockFreshBackupNameForCurrTime "${dirPrjDir}" "${sTag}"
        # 2 #
	if [ "${OUTPUTEXT}" ]; then
	    TARGET="${TARGET_WoEXT}.${OUTPUTEXT}"
	else
	    TARGET="${TARGET_WoEXT}"
	fi
        # 3 #
	[ "${SRC}" = '-' ] && SRC='cat'
        # 4 #
	if ${SRC} > "${TARGET}" 2> /dev/null ; then
	    # 5 #
	    postProcBakFile "${TARGET}" "${TARGET_BN_WoEXT}"
	else
	    # 6 #
	    rm -f "${TARGET}"      2> /dev/null
	    rm -f "${TARGET_fileLock}" 2> /dev/null
	    printfMsg "${errmsg_pf_ErrorRunningProgram_1}" "${SRC}"
	    return ${EXIT_ERROR}
	fi
    fi
    ### D ###
    [ "${CLO_bak_bLock}" ] || rm -f "${TARGET_fileLock}"
}

###############################################################################
# - doSyncExistingBackup -
#
#   Do synchronize or add of existing backup. Create a new backup if there is
#   no existing updatable one.
#
# Uses: CLO_bak_bForce
# Uses: CLO_bak_bNoDelete
#
# Uses: aBakInfo_filePrjBak
# Uses: dirPrjDir
# Uses: SRC
#
# Sets: OLDTRG
# Sets: OLDTRG_WoEXT
# Sets: OLDTRG_fileLock
#
# A. Exit if we can't update the backup because it is locked.  Also set
#    OLDTRG_fileLock to the lock file and CLO_bak_bLock if a lock file
#    exists.
#    If the backup is not locked, we must create a lock file.
#
# B. Set some variables for convenience.
#    1. Set sNewTag to the tag to use, or empty if none.
#    2. Set some OLDTRG_...
#
# C. Print a message telling which backup we are updating.
# D. There IS an existing updatable backup, and the project type is directory.
#    The project type is 'directory' and we got an existing backup.
#    1. Create a lock file for the backup to create.
#    2. The backup is archived, and perhaps also compressed, - uncompress
#       and unpack it.  The result is a non-archived/compressed backup by the
#       name of `OLDTRG_WoEXT'.
#       1. Create the destination directory `OLDTRG_WoEXT'.
#       2. Set `swTarCompress' to the option to pass to `tar' for
#          uncompression.
#       3. Unpack/uncompress the bacup into the directory directory
#          `OLDTRG_WoEXT'. Exit if `tar' is unsuccessfull.
#       4. Remove the old backup.
#    3. The old backup is a a directory with each file compressed.
#       unzip the files and rename it to `OLDTRG_WoEXT'.
#
# From here, we assume that `OLDTRG_WoEXT' is the name of the directory to
# upate.
#
#    4. Do the update using `rsync'.
#    5. Rename old backup to current target.
#    6. Do post-processing of the directory.
#       Sets `TARGET' and `TARGET_BN_WiEXT'.
#    7. Remove the lock for the old backup.
#    8. If not `CLO_bak_bLock': Remove the lock file for the created backup.
# E. There IS an existing updatable backup, and the project type is file.
#    1. Generate a new backup name, which sets 'TARGET_WoEXT''
#    2. If it is compressed, we should decompress it first.  Also set OLDTRG
#       to the name of the uncompressed file (which is `OLDTRG_WoEXT').
#    3. Move the old backup to the new name, remove the old lock file and
#       rsync the new file.
#    4. Postprocess the file.
#    5. If not `CLO_bak_bLock': Remove the lock file for the created backup.
# F. There IS an existing updatable backup, and the project type is program.
#    Updating a program project means creating a new backup in the same
#    way as new backups are created (without regard to updating), and
#    then removing the old one (if we succeed creating the new backup).
#    1. Create a new backup.
#    2. The new backup was created successfully.
#       Remove the old backup (and its lock-file).
#    3. We faild creating a new backup.
#       Unlock the old backup and return with error-status.
###############################################################################
function doSyncExistingBackup # [NEW-TAG]
{
    local sNewTag=${1}
    ### A ###
    case ${aBakInfo_filePrjBak[${bakInfo_idx_lockPerm}]} in
	'w')
	    if [ ! "${CLO_bak_bForce}" ]; then
		echo -n "${pgmMsg_s_skippingLockedBackup}" >&2
		presentBackup "${aBakInfo_filePrjBak[@]}"  >&2
		exit ${EXIT_ERROR}
	    else
		OLDTRG_fileLock="${dirPrjDir}/${aBakInfo_filePrjBak[${bakInfo_idx_lockFile}]}"
		CLO_bak_bLock=1
	    fi
	    ;;
	'r')
	    echo -n "${pgmMsg_s_WriteProtectedLockSkipping}" >&2
	    presentBackup "${aBakInfo_filePrjBak[@]}"  >&2
	    exit ${EXIT_ERROR}
	    ;;
	*)
	    local OLDTRG_BN_lockFile="${aBakInfo_filePrjBak[${bakInfo_idx_bnHead}]}${TRGLOCKSFX}"
	    local OLDTRG_fileLock="${dirPrjDir}/${OLDTRG_BN_lockFile}"
	    if ! makeLockFile "${OLDTRG_fileLock}"; then
		printfMsg "${errMsg_pf_noBackup_CantCreateLock_1}" "${OLDTRG_fileLock}"
		exit ${EXIT_ERROR}
	    fi
	    ;;
    esac
    ### B ###
    # 1 #
    [ "${sNewTag}" ] || sNewTag="${aBakInfo_filePrjBak[${bakInfo_idx_tag}]}"
    # 2 #
    OLDTRG_BASENAME="${aBakInfo_filePrjBak[${bakInfo_idx_bn}]}"
    OLDTRG_EXT="${aBakInfo_filePrjBak[${bakInfo_idx_ext}]}"
    OLDTRG="${dirPrjDir}/${OLDTRG_BASENAME}"
    OLDTRG_WoEXT="${OLDTRG%${OLDTRG_EXT}}"

    ### C ###

    printfMsg "${msg_pf_SyncingBackup_1}" "$(presentBackup "${aBakInfo_filePrjBak[@]}")"

    if [ "${PRJTYPE}" = 'directory' ]; then
        ### D ###
        # 1 #
	getAndLockFreshBackupNameForCurrTime "${dirPrjDir}" "${sNewTag}"
	# 2 #
	if [[ "${OLDTRG_BASENAME}" =~ ${ereBnTarArhive} ]]; then
	    # .2 #
	    # .2.1 #
	    mkdir "${OLDTRG_WoEXT}"
	    # .2.2 #
	    local swTarCompress
	    case "${OLDTRG_EXT}" in
		*.tar)     swTarCompress=''   ;;
		*.tar.gz)  swTarCompress='-z' ;;
		*.tar.bz2) swTarCompress='-j' ;;
		*.tar.Z)   swTarCompress='-Z' ;;
		*) printfMsgExitErr "${errMsg_pf_UnknownBackupType_1}" "${OLDTRG_EXT}" ;;
	    esac
	    # .2.3 #
	    tar ${swTarCompress} -C "${OLDTRG_WoEXT}" -x -f "${OLDTRG}"
	    if [ $? != 0 ]; then
		printfMsgExitErr "${errMsg_pf_untar_1}" "${OLDTRG}"
	    fi
	    # .2.4 #
	    rm "${OLDTRG}"
	elif [[ "${OLDTRG_BASENAME}" =~ ${ereBnGzipFilesInDir} ]]; then
	    # 3 #
	    find "${OLDTRG}" -type f -print0 | xargs -0 -exec gunzip
	    mv "${OLDTRG}" "${OLDTRG_WoEXT}"
	fi
        # 4 #
	run_rsync "${SRC}/" "${OLDTRG_WoEXT}"
	# 5 #
	mv "${OLDTRG_WoEXT}" "${TARGET_WoEXT}"
	# 6 #
	postProcBakDir "${TARGET_WoEXT}" "${TARGET_BN_WoEXT}"
        # 7 #
	rm -f "${OLDTRG_fileLock}"
	# 8 #
	[ "${CLO_bak_bLock}" ] || rm -f "${TARGET_fileLock}"
    elif [ "${PRJTYPE}" = 'file' ]; then
	### E ###
	# 1 #
        getAndLockFreshBackupNameForCurrTime "${dirPrjDir}" "${sNewTag}"

	# 2 #
	case "${OLDTRG}" in
	    *.gz)  gunzip  "${OLDTRG}" ; OLDTRG=${OLDTRG_WoEXT} ;;
	    *.bz2) bunzip2 "${OLDTRG}" ; OLDTRG=${OLDTRG_WoEXT} ;;
	esac
	# 3 #
	mv        "${OLDTRG}" "${TARGET_WoEXT}"
	rm -f     "${OLDTRG_fileLock}"
	run_rsync "${SRC}" "${TARGET_WoEXT}"
        # 4 #
	postProcBakFile "${TARGET_WoEXT}" "${TARGET_BN_WoEXT}"
	# 5 #
	[ "${CLO_bak_bLock}" ] || rm -f "${TARGET_fileLock}"
    elif [ "${PRJTYPE}" = 'program' ]; then
	### F ###
	# 1 #
	if doCreateNewBackup "${sNewTag}"; then
	    # 2 #
	    rm -f "${OLDTRG_fileLock}"
	    rm -f "${OLDTRG}"
	else
	    # 3 #
	    rm -f "${OLDTRG_fileLock}"
	    return ${EXIT_ERROR}
	fi
    fi
}

###############################################################################
# - postProcBakDir -
#
#   Do post processing of a directory backup.
#   Postprocessing means to archive using tar and to compress.  Sets `TARGET'
# to the name of the final directory/archive file.
#
# Argument 1: The name of the source directory that contains a backup that
#             should be post-processed.
# Argument 2: The basename of the source directory.
#
# Uses: CLO_bak_bTar - Tells if the directory should be tar archived.
# Uses: CLO_bak_bGzip - Tells if the directory should be compressed.
#
# Sets: TARGET, TARGET_BN_WiEXT: The correct extension is appended.
#   Let ${dir} be the source directory, then, if
#   Only tar : TARGET=${dir}.tar
#   tar+zip  : TARGET=${dir}.tar.gz
#   Only zip : TARGET=${dir}.${extGzipFilesInDir}
#   Otherwise: ${dir}
#
# A. The directory should be archived using `tar'.
#    1. Set TARGET to the name of the directory followed by '.tar'.
#    2. Move to that directory and create tar archive, then go back.
#       Use `shopt -s dotglob' to include hidden files, but not "." and "..".
#    3. Remove the source directory.
#    4. If zipping: Zip the tar-file and append '.gz' to the target name.
# B. No tar archiving but zipping of every file inside the directory.
#    Set TARGET to the source directory followed by the extension for
#    directories with zipped files in it. Move the source directory to this
#    name and use `find' to gzip all files in it.
# C. No post-processing should be done. TARGET is the same as the name of the
#    source directory.
###############################################################################
function postProcBakDir # DIRECTORY TARGET_BN_WoEXT
{
    local dir=${1}
    TARGET_BN_WiEXT=${2}

    if [ "${CLO_bak_bTar}" ] ; then
	### A ###
        # A1 #
	TARGET="${dir}.tar"
	TARGET_BN_WiEXT="${TARGET_BN_WiEXT}.tar"
	# A2 #
	pushd "${PWD}" > /dev/null
	cd "${dir}"
	shopt -s dotglob
	tar -c -f "${TARGET}" *
	shopt -u dotglob
	popd > /dev/null
        # A3 #
	rm -rf "${dir}"
        # A4 #
	if [ "${CLO_bak_bGzip}" ] ; then
	    gzip "${TARGET}"
	    TARGET="${TARGET}.gz"
	fi
    elif [ "${CLO_bak_bGzip}" ] ; then
        ### B ###
	TARGET="${dir}.${extGzipFilesInDir}"
	TARGET_BN_WiEXT="${TARGET_BN_WiEXT}.${extGzipFilesInDir}"
	mv "${dir}" "${TARGET}"
	find "${TARGET}" -type f -print0 | xargs -0 -exec gzip --name
    else
	### C ###
	TARGET=${dir}
	TARGET_BN_WiEXT="${TARGET_BN_WiEXT}"
    fi
}

###############################################################################
# - postProcBakFile -
#
#   Do post processing of a file backup.
#   Postprocessing means to compress the file.
#
# Argument 1: The name of the file that is the backup that
#             should be post-processed.
# Argument 2: The basename of the source directory.
#
# Uses: CLO_bak_bGzip - Tells if the file should be compressed.
#
# Sets: TARGET, TARGET_BN_WiEXT: The correct extension is appended.
#   Let ${dir} be the source directory, then, if
#   Only zip : TARGET=${dir}.${extGzipFilesInDir}
#   Otherwise: ${dir}
#
# A. Initialize TARGET.
# B. If zipping: gzip the file and append '.gz' to TARGET.
###############################################################################
function postProcBakFile # FILE TARGET_BN_WoEXT
{
    # A #
    TARGET=${1}
    TARGET_BN_WiEXT=${2}
    # B #
    if [ "${CLO_bak_bGzip}" ] ; then
	gzip "${TARGET}"
	TARGET="${TARGET}.gz"
	TARGET_BN_WiEXT="${TARGET_BN_WiEXT}.gz"
    fi
}

###############################################################################
#   Checks that the given NAMETYPE is valid for the given PRJTYPE.
# Exists with an error message if not.
#
# Argument 1: PRJTYPE
# Argument 2: NAMETYPE
#
#  The only restriction is that if the PRJTYPE is 'program', the NAMETYPE must
# be 'absolute'.
###############################################################################
function checkValidNametypeForSourcetype # PRJTYPE NAMETYPE
{
    local PRJTYPE=${1} NAMETYPE=${2}
    if [ "${PRJTYPE}" = 'program' -a "${NAMETYPE}" != 'constant' ]; then
	echoMsgExitUsage "${errMsg_s_program_constantOnly}"
    fi
}

###############################################################################
# -- setBakRootFromClaOrEnv --
#
#   Checks usage of the options to set dirBakRoot and sets dirBakRoot if they
# are correct.  Otherwise, print an error message and exit
#
# Uses: CLO_dirGlobalRoot     (from --root-global)
# Uses: CLO_sGlobalRootSuffix (from --root-global-suffix)
# Uses: CLO_dirBakRoot        (from --root)
# Uses: COPYBACK_ROOT
# Uses: COPYBACK_ROOT_GLOBAL
#
# Sets: dirBakRoot
#
# B. Sets the backup root using the "method" with highest precedence.
#    Quit if no root is given.
#    1. --root)        Set dirBakRoot using --root.
#    2. --root-global) Derive dirBakRoot from a global root.
#    3. COPYBACK_ROOT) Set dirBakRoot to COPYBACK_ROOT.
#    4. COPYBACK_ROOT_GLOBAL) Derive dirBakRoot from a global root.
#    5. No backup root given.  Print error message and exit.
###############################################################################
function setBakRootFromClaOrEnv
{
    # B #
    if [ "${CLO_dirBakRoot}" ]; then
	# 1 #
	dirBakRoot=${CLO_dirBakRoot}
    elif [ "${CLO_dirGlobalRoot}" ]; then
	# 2 #
	dirGlobalRoot=${CLO_dirGlobalRoot}
	dirBakRoot=${dirGlobalRoot}/${CLO_sGlobalRootSuffix:-${sGlobalUserSfx}}
    elif [ "${COPYBACK_ROOT}" ]; then
	# 3 #
	dirBakRoot=${COPYBACK_ROOT}
    elif [ "${COPYBACK_ROOT_GLOBAL}" ]; then
	# 4 #
	dirGlobalRoot=${COPYBACK_ROOT_GLOBAL}
	dirBakRoot=${dirGlobalRoot}/${CLO_sGlobalRootSuffix:-${sGlobalUserSfx}}
    else
	# 5 #
	echoMsgExitErr "${errMsg_s_BakRoot_Missing}"
    fi
}

###############################################################################
#   Sets `sPrjNameHead' to the predefined value, depending on the naming
# scheme, absolute filename and absolute prefix.
#
# Argument 1: NAMETYPE - same as global variable `NAMETYPE'.
# Argument 2: [optional] absolute filename of the source
# Argument 3: [optional] absolute filename of prefix,
#             if the suffix naming scheme is used.
#
# Sets: sPrjNameHead
###############################################################################
function setDefaultPrjNameHead # NAMETYPE [ ABSOLUTE-SRC ABSOLUTE-NAME-PREFIX ]
{
    local NAMETYPE=${1} sAbsSrc=${2} sAbsNamePfx=${3}
    case "${NAMETYPE}" in
	'constant')
	    sPrjNameHead=${predefPnTail_sOther}
	    ;;
	'basename')
	    sPrjNameHead=${predefPnTail_sOther}
	    ;;
	'absolute')
	    sPrjNameHead=${predefPnTail_sRoot}
	    ;;
	'suffix')
	    if [[ ${sAbsNamePfx} = ${HOME} ]]; then
		sPrjNameHead=${predefPnTail_sHome}
	    else
		sPrjNameHead=${predefPnTail_sOther}
	    fi
	    ;;
    esac
}

###############################################################################
#   Set sPrjNameTail depending on which kind of name we are using.  Print a
# message and exits if an error is encountered.
#
# Argument 1: sAbsSrc (optional)
#            If the file name is used for setting the name tail, this argument
#            must be the absolute filename of the source file.
#
# Uses: NAMETYPE
# Uses: CLO_NAME_sConstant (if [ NAMETYPE = 'constant' ])
# Uses: CLO_NAME_sPrefix (if [ NAMETYPE = 'suffix'] )
# Uses: SRC - must be an existing file/dir if it is used in setting the name
#       tail.
#
# Sets: sPrjNameTail
# Sets: CLO_NAME_sPrefix (optional)
#       If it is used, it is also updated to the real path of its prior value.
#
# 1. Absolute name ('CLO_NAME_sConstant') must not be empty.
# 2. The base name of the source file.
#    Get the real path of the file and get the basename.
# 3. The name of the source file.
#    Get the real path of the file and remove the beginning /.
# 4. Suffix name.
#    1. Exit if CLO_NAME_sPrefix is not a directory.  Otherwise, set
#       it to the abspath of itself.
#    2. Exit if the prefix and the source are the same.
#    3. Get the postfix part.
#    4. Exit if CLO_NAME_sPrefix is not a prefix of sAbsSrc.
#    5. set sPrjNameTail to the postfix without the leading "/".
###############################################################################
function setPrjNameTail # [sAbsSrc]
{
    local sAbsSrc=${1}

    case "${NAMETYPE}" in
	'constant')
	    # 1 #
	    [ "${CLO_NAME_sConstant:0:1}" = "/" ]   && echoMsgExitErr "${errMsg_s_nt_constant_slash}"
	    pathIsAbsolute "/${CLO_NAME_sConstant}" || echoMsgExitErr "${errMsg_s_nt_constant_relative}"
	    sPrjNameTail="${CLO_NAME_sConstant}"
	    ;;
	'basename')
	    # 2 #
	    sPrjNameTail=$(basename "${sAbsSrc}")
	    ;;
	'absolute')
	    # 3 #
	    sPrjNameTail=${sAbsSrc:1}
	    ;;
	'suffix')
	    # 4 #
	    # 4.1 #
	    [ ! -d "${CLO_NAME_sPrefix}" ] && printfMsgExitErr "${errMsg_pf_NotADirectory_1}" "${CLO_NAME_sPrefix}"
	    CLO_NAME_sPrefix=$(abspath "${CLO_NAME_sPrefix}")
	    # 4.2 #
	    [ "${CLO_NAME_sPrefix}" = "${sAbsSrc}" ] && echoMsgExitErr "${errMsg_s_pfxAndSourceSame}"
	    # 4.3 #
	    local nLenPrefix=${#CLO_NAME_sPrefix}
	    sPrjNameTail=${sAbsSrc:${nLenPrefix}}
	    # 4.4 #
	    if [ "${CLO_NAME_sPrefix}" != "${sAbsSrc::${nLenPrefix}}" ]; then
		printfMsgExitErr "${errMsg_pf_NotAPrefix_2}" "${sAbsSrc}" "${CLO_NAME_sPrefix}"
	    fi
	    # 4.5 #
	    sPrjNameTail=${sPrjNameTail:1}
	    ;;
	*)
	    printfMsgExit ${EXIT_INTERNAL} "${errMsg_pf_Internal_1}" "unknown NAMETYPE (${NAMETYPE})"
	    ;;
    esac
}

###############################################################################
#   Set sPrjName depending on which kind of name we are using.  Print a
# message and exits if an error is encountered.
#
#   Errors are all invalid combinations of setting the project name.
#   If no naming scheme options are given we are to figure them out
# automatically.
#
# Uses: NAMETYPE
# Uses: CLO_NAME_sConstant (if [ NAMETYPE == 'constant' ])
# Uses: CLO_NAME_sPrefix (if [ NAMETYPE == 'suffix'] )
# Uses: SRC
# Uses: CLO_bPrjNameHead
# Uses: CLO_sPrjNameHead
#
# Sets: sPrjNameHead
# Sets: sPrjNameTail
# Sets: sPrjName
#
# A. Set `sPrjNameTail' and `CLO_NAME_sPrefix' (if it is used).
#    setPrjNameTail should be given the absolute name of the source file/dir
#    if the source is a file/dir.
# B. Set sPrjNameHead.
#    1. An explicit value for it is set using --project-name-head.
#       If there is a non-empty value it must NOT begin or end with a slash.
#    2. The default value should be used.
# C. Set `sPrjName'.
#    If 'sPrjNameHead' is empty, it is just sPrjNameTail.  Otherwise append
#    the two separated by a slash.
###############################################################################
function setPrjName
{
    # A #
    if [ "${NAMETYPE}" = 'constant' ]; then
	setPrjNameTail
    else
	local sAbsSrc=$(abspath "${SRC}")
	setPrjNameTail "${sAbsSrc}"
    fi
    # B #
    if [ "${CLO_bPrjNameHead}" ]; then
	# .1 #
	if [ "${CLO_sPrjNameHead}" ]; then
	    if [[ "${CLO_sPrjNameHead::1}" = '/' ]] || \
		[[  "${CLO_sPrjNameHead}" =~ .*/$ ]]; then
		printfMsgExitErr "${errMsg_pf_prjNameHead_ContainsSlashes_1}" "${CLO_sPrjNameHead}"
	    fi
	    sPrjNameHead=${CLO_sPrjNameHead}
	else
	    sPrjNameHead=
	fi
    else
	# .2 #
	setDefaultPrjNameHead "${NAMETYPE}" "${sAbsSrc}" "${CLO_NAME_sPrefix}"
    fi
    # C #
    if [ "${sPrjNameHead}" ]; then
	sPrjName="${sPrjNameHead}/${sPrjNameTail}"
    else
	sPrjName=${sPrjNameTail}
    fi
}

###############################################################################
#   Sets variables from environment and command line arguments.
#
# Sets: dirBakRoot
# Sets: dirPrjDir
# Sets: sPrjNameHead
# Sets: sPrjNameTail
# Sets: sPrjName
###############################################################################
function setPrjNameAndDir
{
    setBakRootFromClaOrEnv
    setPrjName
    dirPrjDir="${dirBakRoot}/${sPrjName}"
}

###############################################################################
#   Tries to derive PRJTYPE and NAMETYPE from a source if these are not set.
#
#   The source needs to be stated - so its is read (regardless of what
# `srcUsage_bRead says').
#   The function prints an error message and quits the whole program
# with EXIT_USAGE  if one
# of the mentioned variables are missing and cannot be derived.  This includes
# the case when the given source is not an existing file, since information
# about it is needed.
#
# Argument: the source (may be a relative filename)
#
# Uses: bImplicitCommand
#
# Sets: PRJTYPE (only set if not already set)
# Sets: NAMETYPE (only set if not already set)
# Sets: CLO_NAME_sPrefix (only if NAMETYPE is also set to 'suffix')
#       Is only set to ${HOME}.
#
# A. The project type is missing.
# B. The naming scheme is missing.
#    1. Exit with error message if the project type is 'program' (because then
#       the naming scheme must be 'constant', which requires the user to
#       supply the constant name).
#    2. Exit if the source is not an existing file.
#    3. Now we know that we can derive the naming scheme.
#       Get the absolute filename.  If that begins with, but is not the same
#       as, ${HOME}, use the  'suffix' naming scheme with the prefix ${HOME}.
#       Otherwise, use the 'absolute' naming scheme.
###############################################################################
function tryDeriveMissingPrjInfo # SOURCE
{
    local SRC=${1}
    # A #
    if [ ! "${PRJTYPE}" ]; then
	if [ -f "${SRC}" ]; then
	    PRJTYPE='file'
	elif [ -d "${SRC}" ]; then
	    PRJTYPE='directory'
	else
	    if [ "${bImplicitCommand}" ]; then
		printfMsgExit ${EXIT_USAGE} "${errMsg_pf_NorACmdOrFile_1}" "${SRC}"
	    else
		printfMsgExit ${EXIT_USAGE} "${errMsg_pf_CantDerivePrjType_fileDir_1}" "${SRC}"
	    fi
	fi
    fi
    # B #
    if [ ! "${NAMETYPE}" ]; then
	# .1 #
	if [ "${PRJTYPE}" = 'program' ]; then
	    echoMsgExit ${EXIT_USAGE} "${errMsg_s_program_constantOnly}"
	fi
	# .2 #
	if [ ! -e "${SRC}" ]; then
	    if [ "${bImplicitCommand}" ]; then
		printfMsgExit ${EXIT_USAGE} "${errMsg_pf_NorACmdOrFile_1}" "${SRC}"
	    else
		printfMsgExit ${EXIT_USAGE} "${errMsg_pf_CantDeriveNameType_fileDontExist_1}" "${SRC}"
	    fi
	fi
	# .3 #
	local sAbsSrc=$(abspath "${SRC}")
	# .4 #
	if [ "${HOME}" = "${sAbsSrc::${#HOME}}" -a "${HOME}" != "${sAbsSrc}" ]; then
	    NAMETYPE='suffix'
	    CLO_NAME_sPrefix=${HOME}
	else
	    NAMETYPE='absolute'
	fi
    fi
}

###############################################################################
#   Run `rsync' or the test-command 'print-rsync-options'.
#
#   Print error message and exit if anything goes wrong.
#
# Uses: CLO_bak_eUpdate
# Uses: CLO_bak_bNoDelete
# Uses: rsync_swConstant
# Uses: rsync_swVariable
# Uses: rsync_swForward
#
# Sets: rsync_swVariable
#
# A. Prepend non-forward options to `rsync' in `rsync_swForward'.
#    If we are NOT adding, we should use --delete-excluded (which
#    implies --delete).
# B. If the test command is 'print-rsync-options', execute it and exit.
# C. Run `rsync' and set `rsync_st' to it's exit status.
# D. Print error message and exit if `rsync' exited with non-zero status.
###############################################################################
function run_rsync # SOURCE DESTINATION
{
    local SRC=${1} DST=${2}
    # A #
    if [[ ! "${CLO_bak_bNoDelete}" ]]; then
	rsync_swVariable="--delete-excluded ${rsync_swVariable}"
    fi
    # B #
    if [ "${cmdTest}" = 'print-rsync-options' ]; then
	# NOTE: The following line must be synced(!) with the one really invoking `rsync'!
	eval echo -- "${rsync_swForward}" "${rsync_swVariable}" ${rsync_swConstant}
	exit 0
    fi
    # C #
    # NOTE: Update the "eval echo -- ..." line above if the following is modifie!
    eval rsync "${rsync_swForward}" "${rsync_swVariable}" ${rsync_swConstant} "'${SRC}'" "'${DST}'" >&2
    local rsync_st=$?
    # D #
    if [ ${rsync_st} != 0 ]; then
	if [ ${rsync_st} = ${rsync_EXIT_USAGE} ]; then
	    echoMsgExit ${EXIT_USAGE} "${errMsg_rsync_s_usage}"
	else
	    echoMsgExit ${EXIT_ERROR} "${errMsg_rsync_s_error}"
	fi
    fi
}

###############################################################################
#   Main function for parsing command line options using `getopt'.
#
#   This function parses a command line by using a callback function to
# handle each individual option given.  This function is given the options to
# pass to `getopt', the name of the callback function and the
# optionas-and-arguments to parse.
#   The array variable `GLOB_aRemainingArgs' is set to the command line
# arguments remaining after the parse so that the caller can process these
# further.
#   The callback function takes all remaining command line arguments as
# it's argumets, so these can be any number greater or equal to 1.  The first
# of these is of course the name of the option (including starting dashes).
# The
# callback sets the global variable `parseCmdOpts_nShift' to tell how many of
# these it did consume.  (For options without any argument this is 1.)
# `parseCmdOpts_nShift' is initalized to 1 before the callback is called, so
# `parseCmdOpts_nShift' only needs to be set if it should not be 1.
#    The callback function most likely consts of a single `case' satatement
# that handles all recognized options and sets `parseCmdOpts_nShift':
#
#        case "$1" in
#            OPTION-WITHOUT-ARGUMENTS)
#                    <handle option>
#                    ;;
#            OPTION-WITH-ARGUMENT)
#                    <handle option>
#                    parseCmdOpts_nShift=2 # (if the option had arguments)
#                    ;;
#            ...
#        esac
#
#    When this function is finished $1, $2, ... contains thenon-option
# arguments.  `parseCmdOpts_nShift' is unset.
#
# Argument 1: Name of program to pass to getopt using the -n option.
# Argument 2: Options to pass to `getopt'.
# Argument 3: Callback function.  Type: OPTION ARGUMENTS -> ()
#             Should set `parseCmdOpts_nShift' to tell how many values
#             it has "consumed".  `parseCmdOpts_nShift' is initialized to
#             1, so the value 1 needs never be set explicitly.
# Argument 4...: Options and arguments (the command line) to parse
#
# Uses: parseCmdOpts_nShift
#
# Sets: parseCmdOpts_nShift
# Sets: GLOB_aRemainingArgs - Array of the command line arguments that
#       remain after the parse.
#
#   Parse command line options for the '' command.
#
# A. Parse command line options using `getopt'.
#    Shift away the arguments that are not part of the command line to parse.
# B. Operate on each option.
# C. Shift away the mandatory -- ( that tells us that there are no more
#    options), set `GLOB_aRemainingArgs' and unset `parseCmdOpts_nShift'.
###############################################################################
function parseCmdOptions # PROGRAM-NAME getopt-OPTIONS OPTION-HANDLER-CALLBACK-FUN [OPTIONS-AND-ARGUMENTS...]
{
    local sPgmName=${1} swGetoptOptions=${2} funOptionCallback=${3} args
    # A #
    shift ; shift ; shift
    args=$(getopt -n "${sPgmName}" ${swGetoptOptions} -- "$@")

    [ $? != 0 ] && exit ${EXIT_USAGE}

    eval set -- "${args}"
    # B #
    while [ "_${1}" != '_--' ]; do
	parseCmdOpts_nShift=1
	${funOptionCallback} "$@"
	shift ${parseCmdOpts_nShift}
    done
    # C #
    shift
    GLOB_aRemainingArgs=("$@")
    unset parseCmdOpts_nShift
}

function parseCmdOptions_callback_backup
{

    case "$1" in
	'--file')               PRJTYPE='file' ;;
	'--directory')          PRJTYPE='directory' ;;
	'--program')            PRJTYPE="program" ;;

	'-a' | '--absolute')    NAMETYPE='absolute' ;;
	'-b' | '--basename')    NAMETYPE="basename" ;;

	'-c' | '--constant')    NAMETYPE='constant'
	                        CLO_NAME_sConstant="$2" ; parseCmdOpts_nShift=2 ;;
	'-s' | '--suffix')      NAMETYPE='suffix'
	                        CLO_NAME_sPrefix="$2" ; parseCmdOpts_nShift=2 ;;
	'-h' | '--suffix-home') NAMETYPE='suffix'
	                        CLO_NAME_sPrefix=${HOME} ;;
	'--pnh' | '--project-name-head')
	                        CLO_bPrjNameHead=1
	                        CLO_sPrjNameHead=${2}
				parseCmdOpts_nShift=2 ;;

	'-g' | '--assign-tag')  bak_sAssignTag=${2}
	                        parseCmdOpts_nShift=2 ;;

	'--source')             SRC=${2} ; parseCmdOpts_nShift=2 ;;


	'-u' | '--update')      CLO_bak_eUpdate='update' ;;
	'-U' | '--update-or-create')
                                CLO_bak_eUpdate='update-or-create' ;;
	'-n' | '--no-delete')   CLO_bak_bNoDelete=1 ;;

	'-l' | '--last')        bak_bakDest_prjFile_eWhichBackups='last' ;;
	'-d' | '--date')        bak_bakDest_prjFile_eWhichBackups="date/"$(formatDatetime "$2")
	                        parseCmdOpts_nShift=2
				;;
	'-t' | '--tag')         bak_bakDest_prjFile_eWhichBackups="tag/${2}"
	                        parseCmdOpts_nShift=2
				;;

	'-E' | '--extension')   OUTPUTEXT="$2" ; parseCmdOpts_nShift=2 ;;
	'-T' | '--tar')         CLO_bak_bTar=1  ;;
	'-z' | '--gzip')        CLO_bak_bGzip=1 ;;
	'-L' | '--lock')        CLO_bak_bLock=1 ;;

	'-f' | '--force')       CLO_bak_bForce=1 ;;

	'-F' | '--rsync-filter')
	                        rsync_swForward="${rsync_swForward} -F" ;;

	# Options to forward to `rsync'.
	'--chmod' | '--exclude' | '--exclude-from' | '--include' | '--include-from' | '--filter')
	                        rsync_swForward="${rsync_swForward} ${1} '${2}'"
	                        parseCmdOpts_nShift=2
				;;
	'--cvs-exclude')        rsync_swForward="${rsync_swForward} ${1}" ;;

	'--help')               echo "${help_s_backup}" ; exit 0 ;;
	*)                      printfMsg "${errMsg_pf_Internal_1}" "Unknown option ${1}"
	                        exit ${EXIT_INTERNAL} ;;
    esac
}

function parseCmdOptions_callback_clean
{
    case "$1" in
	'-e' | '--explicit')    bakDest_eSrc='abs-arg' ;;
	'-f' | '--force')       CLO_nonBak_bForce=1 ;;
	'-r' | '--recursive')   CLO_bRecursive=1 ;;
	'--help')               echo "${help_s_clean}" ; exit 0 ;;
	*)                      printfMsg "${errMsg_pf_Internal_1}" "Unknown option ${1}"
	                        exit ${EXIT_INTERNAL} ;;
    esac
}

function parseCmdOptions_callback_removeProject
{
    case "$1" in
	'-e' | '--explicit')    bakDest_eSrc='abs-arg' ;;
	'-f' | '--force')       CLO_bForce='--force' ;;
	'--help')               echo "${help_s_removeProject}" ; exit 0 ;;
	*)                      printfMsg "${errMsg_pf_Internal_1}" "Unknown option ${1}"
	                        exit ${EXIT_INTERNAL} ;;
    esac
}

function parseCmdOptions_callback_find
{
    case "$1" in
	'-e' | '--explicit')    bakDest_eSrc='abs-arg' ;;
	'--help')               echo "${help_s_find}" ; exit 0 ;;
	*)                      printfMsg "${errMsg_pf_Internal_1}" "Unknown option ${1}"
	                        exit ${EXIT_INTERNAL} ;;
    esac
}

function parseCmdOptions_callback_list
{
    case "$1" in
	'-e' | '--explicit')    bakDest_eSrc='abs-arg' ;;
	'--help')               echo "${help_s_list}" ; exit 0 ;;
	*)                      printfMsg "${errMsg_pf_Internal_1}" "Unknown option ${1}"
	                        exit ${EXIT_INTERNAL} ;;
    esac
}

function parseCmdOptions_callback_lockUnlock
{
    case "$1" in
	       '--all')         bakDest_prjFile_eWhichBackups='all'  ;;
	'-l' | '--last')        bakDest_prjFile_eWhichBackups='last' ;;
	'-d' | '--date')        bakDest_prjFile_eWhichBackups="date/"$(formatDatetime "$2")
	                        parseCmdOpts_nShift=2
				;;
	'-t' | '--tag')         bakDest_prjFile_eWhichBackups="tag/${2}"
	                        parseCmdOpts_nShift=2
				;;
	'-e' | '--explicit')    bakDest_eSrc='abs-arg' ;;
	'--help')               echo "${help_s_lockUnlock}" ; exit 0 ;;
	*)                      printfMsg "${errMsg_pf_Internal_1}" "Unknown option ${1}"
	                        exit ${EXIT_INTERNAL} ;;
    esac
}

# Uses: COMMAND
function parseCmdOptions_callback_tagUntag
{
    case "$1" in
	'-l' | '--last')        bakDest_prjFile_eWhichBackups='last' ;;
	'-d' | '--date')        bakDest_prjFile_eWhichBackups="date/"$(formatDatetime "$2")
	                        parseCmdOpts_nShift=2
				;;
	'-t' | '--tag')         bakDest_prjFile_eWhichBackups="tag/${2}"
	                        parseCmdOpts_nShift=2
				;;
	'-e' | '--explicit')    bakDest_eSrc='abs-arg' ;;
	'--help')               if [[ ${COMMAND} = 'tag' ]]; then
	                            echo "${help_s_tag}"
				else
				    echo "${help_s_Untag}"
				fi
				exit 0
				;;
	*)                      printfMsg "${errMsg_pf_Internal_1}" "Unknown option ${1}"
	                        exit ${EXIT_INTERNAL} ;;
    esac
}

###############################################################################
# Parses CL-arguments for a command that needs an existing backup file, not
# specified implicitly.
#
# The getopt arguments are those in
#   'getopt_singleBackupFileNonExplicit_swOptions'.
#
# Uses: COMMAND
###############################################################################
function parseCmdOptions_callback_singleBackupFileNonExplicit
{
    case "$1" in
	'-l' | '--last')        bakDest_prjFile_eWhichBackups='last' ;;
	'-d' | '--date')        bakDest_prjFile_eWhichBackups="date/"$(formatDatetime "$2")
	                        parseCmdOpts_nShift=2
				;;
	'-t' | '--tag')         bakDest_prjFile_eWhichBackups="tag/${2}"
	                        parseCmdOpts_nShift=2
				;;
	'--help')               doPrintHelpForCommand "${COMMAND}"
	                        exit 0
				;;
	*)                      printfMsg "${errMsg_pf_Internal_1}" "Unknown option ${1}"
	                        exit ${EXIT_INTERNAL} ;;
    esac
}

###############################################################################
# Prints help for the given command.
#
# * Arguments
# ** Argument: COMMAND
# Must be a command with help in 'aHelpForCommand'.
###############################################################################
function doPrintHelpForCommand # COMMAND
{
    local command="$1"
    echo "${PROGNAME}: ${command}: ${aHelpForCommand[${command}]}"
}

###############################################################################
#   Parses the options and arguments for the commands.
#
#  These are the options and arguments that follow the general options and the
# debug options (if --debug is used).
#
# Sets: GLOB_aRemainingArgs - command line arguments remaining after parsing
#       the debug arguments.
#
# A. Parse the commands.
#    The next argument is the name of the command, or options and arguments
#    if the command is left out (so that it default's to 'backup').
#    If it is the name of a command, set
#    COMMAND to it and parse command specific options.
#    find)
#       Set `find_bBakRoot' to true if no argument is given and
#       --explicit is not given.
#    clean)
#       3. Two cases for CLO_bRecursive:
#          Set "prj-dir" if not recursive, otherwise "bak-dir".
#          This is rather arbitrary, but feels right!
#    list)
#       1. Set the command and shift it away.  If the command is 'lf',
#          eBakPresFormat should be initialized to 'filename'.
#       2. Set constants.
#       3. Initialize default values.
#       4. Parse command options.
#    tag|untag)
#       1. Set COMMAND and shift away the command string.
#       2. Initialize bakDest_...
#       3. Parse command options using `parseCmdOptions'.
#       4. If the command is "tag"
#          The tag string must be given as argument.  If there are no
#             arguments, quit with EXIT_USAGE.
#          Read the tag into `tag_sTag' and shift it away.
#    *) - backup -
#       1. If the first argument is NOT the name of an command, default the
#          COMMAND to 'backup'.
#          Set bImplicitCommand if 'backup' or 'b' is not used, and also
#          dont' whift away the $1.
#          Otherwise, shift away $1 (which is the name of the command).
#       2. Parse backup options.
#       3. Set bakDest_...
#          We always use bakDest_eSrc='env-and-cla' and srcUsage_bRead='1'.
#          The rest of bakDest_... depends on wether we do an update or not.
#           1. Update.  `ak_bakDest_prjFile_eWhichBackups' must be set by
#              options to tell us which backup to update.  Exit if not.
#              Set the valid project types, depending on `CLO_bak_bNoDelete'.
#           2. Create a new backup.
#
# B. Set `GLOB_aRemainingArgs' to the remaining arguments.
###############################################################################
function parseCommand # ARGUMENT ...
{
    # A #
    case "${1}" in
        'clean')
    	    COMMAND='clean'
    	    shift
	    # Set constants.
    	    bakDest_bMustExist=1
    	    # 1 # Initialize default values.
    	    bakDest_eSrc='env-and-cla'
    	    # 2 #
    	    parseCmdOptions 'copyback clean' "${getopt_clean_swOptions}" \
                parseCmdOptions_callback_clean "$@"
            set -- "${GLOB_aRemainingArgs[@]}"
    	    # 3 # Code from old C
    	    if [ "${CLO_bRecursive}" ]; then
    		bakDest_eType='bak-dir'
    	    else
    		bakDest_eType='prj-dir'
    	    fi
	    ;;
	'find')
	    COMMAND='find'
	    shift
	    # Set constants
	    bakDest_bMustExist=1
	    # 1 # Initialize default values.
	    bakDest_eSrc='env-and-cla'
	    # 2 #
	    parseCmdOptions 'copyback find' "${getopt_find_swOptions}" \
		parseCmdOptions_callback_find "$@"
            set -- "${GLOB_aRemainingArgs[@]}"
	    # 3 # If no argument is supplied and we should NOT give the
	    # Project directory explicitly, the Backup root directory should be used.
	    if [ $# = 0 -a "${bakDest_eSrc}" != 'abs-arg' ]; then
		bakDest_eType='bak-dir'
	    else
		bakDest_eType='prj-dir'
	    fi
	    ;;
	'list' | 'l' | 'lf')
	    # 1 #
	    COMMAND='list'
	    if [ "${1}" = 'lf' ]; then
		eBakPresFormat='formatted'
	    fi
	    shift
	    # 2 #
	    bakDest_eType='prj-dir'
	    bakDest_bMustExist=1
	    # 3 #
	    bakDest_eSrc='env-and-cla'
	    # 4 #
	    parseCmdOptions 'copyback list' "${getopt_list_swOptions}" \
		parseCmdOptions_callback_list "$@"
            set -- "${GLOB_aRemainingArgs[@]}"
	    ;;
	'lock' | 'unlock')
	    # CAUTION: If modified, also modify the parsing of the test
	    # command 'dest-deriv-prj-file'!
	    COMMAND=${1}
	    shift
	    # 1 #
	    bakDest_eType='prj-file'
	    bakDest_eSrc='env-and-cla'
	    bakDest_bMustExist=1
	    # 2 #
	    parseCmdOptions "copyback ${1}" "${getopt_lockUnlock_swOptions}" \
		parseCmdOptions_callback_lockUnlock "$@"
	    set -- "${GLOB_aRemainingArgs[@]}"
	    ;;
	'backup-root-directory' | 'brd')
	    COMMAND='print-backup-root-directory'
	    shift
	    bakDest_eType='bak-dir'
	    bakDest_eSrc='env-and-cla'
	    ;;
	'project-name' | 'pn')
	    COMMAND='print-project-name'
	    shift
	    bakDest_eType='prj-dir'
	    bakDest_eSrc='env-and-cla'
	    ;;
	'project-directory' | 'pd')
	    COMMAND='print-project-directory'
	    shift
	    bakDest_eType='prj-dir'
	    bakDest_eSrc='env-and-cla'
	    ;;
	'print-backup-file' | 'pbf')
	    # 1 #
	    COMMAND="${aMainCommandNames[${1}]}"
	    shift
	    # 2 #
	    bakDest_eType='prj-file'
	    bakDest_eSrc='env-and-cla'
	    bakDest_bMustExist=1
	    # 3 #
	    parseCmdOptions "copyback ${COMMAND}" "${aGetoptOptions[${COMMAND}]}" \
		parseCmdOptions_callback_singleBackupFileNonExplicit "$@"
	    set -- "${GLOB_aRemainingArgs[@]}"
	    ;;
	'print-file-inside-backup' | 'pfib')
	    # 1 #
	    COMMAND="${aMainCommandNames[${1}]}"
	    shift
	    # 2 #
	    bakDest_eType='prj-file'
	    bakDest_eSrc='env-and-cla'
	    bakDest_bMustExist=1
	    parseCmdOptions "copyback ${COMMAND}" "${aGetoptOptions[${COMMAND}]}" \
		parseCmdOptions_callback_singleBackupFileNonExplicit "$@"
	    set -- "${GLOB_aRemainingArgs[@]}"
	    case $# in
		1)
		    printFileInsideBackup_sFile=${1}
		    shift
		    ;;
		2)
		    printFileInsideBackup_sFile=${2}
		    set -- "${1}"
		    ;;
		*)
		    echoMsg "${aCommandSyntax[${COMMAND}]}"
		    exit ${EXIT_USAGE}
		    ;;
	    esac
	    ;;
	'tag' | 'untag')
	    # CAUTION: If modified, also modify the parsing of the test command 'dest-deriv-prj-file'!
	    # 1 #
	    COMMAND=${1}
	    shift
	    # 2 #
	    bakDest_eType='prj-file'
	    bakDest_eSrc='env-and-cla'
	    bakDest_bMustExist=1
	    # 3 #
	    parseCmdOptions "copyback ${1}" "${getopt_tagUntag_swOptions}" \
		parseCmdOptions_callback_tagUntag "$@"
	    set -- "${GLOB_aRemainingArgs[@]}"
	    # 4 #
	    if [[ ${COMMAND} = 'tag' ]]; then
		# .1 #
		case $# in
		    1)
			tag_sTag=${1}
			shift
			;;
		    2)
			tag_sTag=${2}
			set -- "${1}"
			;;
		    *)
			echo "${syntax_s_tag}" >&2
			exit ${EXIT_USAGE}
			;;
		esac
	    fi
	    ;;
	'remove-project')
	    COMMAND=${1}
	    shift
	    bakDest_eType='prj-dir'
	    bakDest_eSrc='env-and-cla'
	    bakDest_bMustExist=1 # Correct?
	    unset srcUsage_bRead # Correct?
    	    parseCmdOptions 'copyback remove-project' "${getopt_removeProject_swOptions}" \
                parseCmdOptions_callback_removeProject "$@"
            set -- "${GLOB_aRemainingArgs[@]}"
	    ;;
	'restore' | 'diff' | 'remove' | 'rm')
	    printfMsgExit ${EXIT_IMPLEMENTED} "${errMsg_pf_NotImplemented_1}" "${1}"
	    bakDest_eType='bak-dir'
	    bakDest_eSrc='abs-arg'
	    bakDest_bMustExist=1
	    ;;
	*)
	    # 1 #
	    COMMAND='backup'
	    case "${1}" in
		'backup' | 'b') shift ;;
		*)              bImplicitCommand=1 ;;
	    esac
	    # 2 #
	    parseCmdOptions 'copyback backup' "${getopt_backup_swOptions}" \
		parseCmdOptions_callback_backup "$@"
            set -- "${GLOB_aRemainingArgs[@]}"
	    # 3 #
	    bakDest_eSrc='env-and-cla'
	    srcUsage_bRead=1
	    if [ "${CLO_bak_eUpdate}" ]; then
		# .1 #
		if [ ! "${bak_bakDest_prjFile_eWhichBackups}" ]; then
		    echoMsg "${errMsg_s_bak_NoBakRef}"
		    exit ${EXIT_USAGE}
		fi
		bakDest_eType='prj-file'
		bakDest_prjFile_eWhichBackups=${bak_bakDest_prjFile_eWhichBackups}
		# If 'update-or-create', we do not need to have an existing backup.
		# Otherwise, we must.
		if [ "${CLO_bak_eUpdate}" = 'update-or-create' ]; then
		    bakDest_bMustExist=
		else
		    bakDest_bMustExist=1
		fi
		if [ "${CLO_bak_bNoDelete}" ]; then
		    readonly srcUsage_wslValidTypes='file directory'
		else
		    readonly srcUsage_wslValidTypes=
		fi
	    else
		# .2 #
		bakDest_eType='prj-dir'
		bakDest_bMustExist=
	    fi
	    ;;
    esac
    # B #
    GLOB_aRemainingArgs=("$@")
}

###############################################################################
#   Check options and set variables for the root directory and backup
# destination.
#
#    `abspath' is not used here, even if the file must exist.  Each command
# that uses the "absolute path" must calculate this itself.
#
# Sets: dirBakRoot
# Sets: dirPrjDir
# Sets: filePrjBak
# Sets: aBakInfo_filePrjBak
#
# Sets: GLOB_aRemainingArgs - command line arguments remaining after parsing
#       the debug arguments.
#
#
#
# A. If bakDest_eType = 'prj-file' we may need some preprocessing here,
#    depending on `bakDest_eSrc' and `bakDest_prjFile_eWhichBackups'.
#
# B. Do the real work.
#    0. No backup destination is TODOX
#    1. [bakDest_eSrc = 'abs-arg']
#       1. Check that exactly one (non-option) argument is given.
#          Assign this to `sAbsArg' and shift it away.
#       2. Check that no not-used (or ignored) options are given.
#       3. Set `dirBakRoot' or `dirPrjDir'.
#          1. Check that the directory doesn't have the name of a backup.
#          2. If [bakDest_bMustExist], check that the argument exists as a file
#             of the right type.
#          3. Check bakDest_bWritable.
#          4. Set `dirBakRoot' or `dirPrjDir'.
#       4. Set `filePrjBak'.
#          2. If [bakDest_bMustExist], check that the argument exists.
#          3. Check bakDest_bWritable.
#          4. Set `dirPrjDir', `filePrjBak' and `aBakInfo_filePrjBak'.
#             `set_aBakInfo_filePrjBak_orExit' checks that the file has the name
#             of a backup.
#       3. Check that unused options are not used.
#       4. Exit if we got an error.
#    2. [bakDest_eSrc != 'abs-arg' && bakDest_eType = 'bak-dir' ]
#       Set `dirBakRoot'.
#       1. Table 1/env-and-cla/bak-dir/(a).
#       2. Table 1/env-and-cla/bak-dir/(b).
#       3. Exit if we got an error.
#       4. Set the root directories using `setRootDirsFromClaOrEnv'.
#       5. If [ bakDest_bMustExist ], we must check that `dirBakRoot' is an
#          existing directory.
#       6. If [ bakDest_bWritable ], we must check that `dirBakRoot' is
#          writable.
#    3. [bakDest_eSrc != 'abs-arg' && bakDest_eType = 'prj-dir' ]
#       Set `dirPrjDir' and `SRC'.
#       1. Table 1/env-and-cla/prj-dir/(a).  Set `SRC'.
#          The source should be given EITHER using --source OR as an argument.
#       2. Try to derive needed variables that has not been given by the user.
#       3. Table 1/env-and-cla/prj-dir/(b).
#       4. Check the project type.  It must be one of those listed in
#          `srcUsage_wslValidTypes' (if that variable is non-empty).
#       5. Given the `PRJTYPE', check that the `NAMETYPE' is valid.
#       6. Set `srcUsage_bRead' to True (1) if the NAMETYPE requires us to
#          stat the file/directory.
#       7. If the source type is file/directory, and [ srcUsage_bRead ],
#          check that the source is an existing readable file/directory.
#       8. Set the backup root directory, project name and project directory.
#       9. If [ bakDest_bMustExist ], we must check that `dirPrjDir' is an
#           existing directory.
#       10. If [ bakDest_bWritable ], we must check that `dirPrjDir' is
#           writable..
# C. Do "postprocessing" if `bakDest_filePrjBak_bPostprocPrjDir' says so
#    1. Restore the value of `bakDest_eType' to 'prj-file'.
#    2. Exit if `bakDest_bMustExist' but the project directory does not exist.
#    3  Use bakDest_prjFile_eWhichBackups to get the backup.  The value cannot
#       be 'all', so we know that we get exactly one or zero backup(s).
#       Set `sBakInfo_filePrjBak' to empty if the project directory does not
#       exist.
#       The bakInfo string is stored in `sBakInfo_filePrjBak'.
#    4. Set `aBakInfo_filePrjBak' and `filePrjBak'.
#       If `sBakInfo_filePrjBak' is empty, this will be empty too.  Otherwise
#       we split it into an array.
#       We must add one element to the array if the last element in the string
#       representation of it was empty.  This is an unfortunate feature of
#       array setting, in this situation at least.
#    5. If `bakDest_bMustExist' is true:
#       1. Exit if the project directory does not exist.
#       2. Exit if `sBakInfo_filePrjBak' is empty.
# D. Set `GLOB_aRemainingArgs' to the remaining arguments.
###############################################################################
function deriveRootsAndBakDest # COMMAND-LINE-ARGUMENT...
{
    ### A ###
    if [[ ${bakDest_eType} = 'prj-file' ]]; then
	case "${bakDest_prjFile_eWhichBackups}" in
	    '') # Table 3 (c)
		if [[ ${bakDest_eSrc} = 'env-and-cla' ]]; then
		    # Table 3 (c.1).
		    echoMsgExitUsage "${usageErr_s_SpecifyBackup}"
		    exit ${EXIT_USAGE}
		fi
		;;
	    'all') # Table 3 (a)
		# Change bakDest_eType permanently to 'prj-dir'.
		bakDest_eType='prj-dir'
	        # done
		;;
	    *) # Table 3 (b)
		bakDest_filePrjBak_bPostprocPrjDir=1
		bakDest_eType='prj-dir'
		;;
	esac
    fi

    # bakDest_eSrc  = env-and-cla
    # bakDest_eType = prj-dir
    # annat         = date/

    ### B ###

    bUsageError=
    if [ "${bakDest_eSrc}" = 'abs-arg' ]; then
        # 1 #
        # 1.1 #
	[ $# = 1 ] || printfMsgExit ${EXIT_USAGE} "${errMsg_pf_ExactlyOneArgument_1}" $#
	sAbsArg=${1}
	shift
        # 1.2 #
	for i in ${!aVarsNotUsed_bakDest_absArg_sVarNam[*]}; do
	    sVarNam=${aVarsNotUsed_bakDest_absArg_sVarNam[${i}]}
	    if [ "${!sVarNam}" ]; then
		echoMsg "${aVarsNotUsed_bakDest_absArg_sErrMsg[${i}]}"
		bUsageError=1
	    fi
	done
	[ "${bUsageError}" ] && exit ${EXIT_USAGE}
        # 1.3 #
	case ${bakDest_eType} in
	    'bak-dir' | 'prj-dir')
	        # 1.3 #
	        # 1.3.1 #
		if isSimpbackBackupFilename "${sAbsArg}"; then
		    printfMsg "${errMsg_pf_RootDirIsBackup_1}" "${sAbsArg}"
		    exit ${EXIT_ERROR}
		fi
	        # 1.3.2 #
		if [ "${bakDest_bMustExist}" -a ! -d "${sAbsArg}" ]; then
		    printfMsg "${errMsg_pf_NotADirectory_1}" "${sAbsArg}"
		    exit ${EXIT_ERROR}
		fi
	        # 1.3.3 #
		if [ "${bakDest_bWritable}" -a ! -w "${sAbsArg}" ]; then
		    case ${bakDest_eType} in
			'bak-dir') printfMsg "${errMsg_pf_BakRootNotWritable_1}" "${sAbsArg}" ;;
			'prj-dir') printfMsg "${errMsg_pf_PrjRootNotWritable_1}" "${sAbsArg}" ;;
		    esac
		    exit ${EXIT_ERROR}
		fi
	        # 1.3.4 #
		case ${bakDest_eType} in
		    'bak-dir') dirBakRoot=${sAbsArg} ;;
		    'prj-dir') dirPrjDir=${sAbsArg} ;;
		esac
		;;
	    'prj-file')
	        # 1.4 #
	        # 1.4.2 #
		if [ "${bakDest_bMustExist}" -a ! -e "${sAbsArg}" ]; then
		    printfMsg "${errMsg_pf_FileNotExisting_1}" "${sAbsArg}"
		    exit ${EXIT_ERROR}
		fi
	        # 1.4.3 #
		if [ "${bakDest_bWritable}" -a ! -w "${sAbsArg}" ]; then
		    printfMsg "${errMsg_pf_BackupNotWritable_1}" "${sAbsArg}"
		    exit ${EXIT_ERROR}
		fi
	        # 1.4.4 #
		dirPrjDir=$(dirname "${sAbsArg}")
		filePrjBak=${sAbsArg}
		set_aBakInfo_filePrjBak_orExit "${sAbsArg}"
	    ;;
	esac
    else
	if [ "${bakDest_eType}" = 'bak-dir' ]; then
	    # 2 #
	    # 2.1 #
	    if [ $# != 0 ]; then
		echoMsg "${errMsg_s_NoArgumentExpected}"
		bUsageError=1
	    fi
	    # 2.2 #
	    for i in ${!aVarsNotUsed_bakDest_bakDir_sVarNam[*]}; do
		sVarNam=${aVarsNotUsed_bakDest_bakDir_sVarNam[${i}]}
		if [ "${!sVarNam}" ]; then
		    echoMsg "${aVarsNotUsed_bakDest_bakDir_sErrMsg[${i}]}"
		    bUsageError=1
		fi
	    done
	    # 2.3 #
	    [ "${bUsageError}" ] && exit ${EXIT_USAGE}
	    # 2.4 #
	    setBakRootFromClaOrEnv
	    # 2.5 #
	    if [ "${bakDest_bMustExist}" -a ! -d "${dirBakRoot}" ]; then
		printfMsg "${errMsg_pf_BakRootNotExisting_1}" "${dirBakRoot}"
		exit ${EXIT_ERROR}
	    fi
	    # 2.5 #
	    if [ "${bakDest_bWritable}" -a ! -w "${dirBakRoot}" ]; then
		printfMsg "${errMsg_pf_BakRootNotWritable_1}" "${dirBakRoot}"
		exit ${EXIT_ERROR}
	    fi
	else
	    # 3 #
	    # 3.1 #
	    case $# in
		0)
		    if [ ! "${SRC}" ]; then
			echoMsgExitUsage "${errMsg_s_SourceMissing}"
		    fi
		    ;;
		1)
		    if [ "${SRC}" ]; then
			echoMsgExitUsage "${errMsg_s_SourceDuplicate}"
		    fi
		    SRC=${1}
		    shift
		    ;;
		*)
		    echoMsgExitUsage "${sUsage}"
	    esac
	    # 3.2 #
	    tryDeriveMissingPrjInfo "${SRC}"
	    # 3.3 #
	    for i in ${!aMandatoryVars_bakDest_prjDir_envAndCla_sVarNam[*]}; do
		sVarNam=${aMandatoryVars_bakDest_prjDir_envAndCla_sVarNam[${i}]}
		if [ ! "${!sVarNam}" ]; then
		    echoMsg "${aMandatoryVars_bakDest_prjDir_envAndCla_sErrMsg[${i}]}"
		    bUsageError=1
		fi
	    done
	    [ "${bUsageError}" ] && exit ${EXIT_USAGE}
	    # 3.4 #
	    if [ "${srcUsage_wslValidTypes}" ] && \
		! containsWord "${srcUsage_wslValidTypes}" ${PRJTYPE} ]]; then
		printfMsg "${errMsg_pf_NotAllowedPrjType_1}" "${PRJTYPE}"
		exit ${EXIT_USAGE}
	    fi
	    # 3.5 #
	    checkValidNametypeForSourcetype "${PRJTYPE}" "${NAMETYPE}"
	    # 3.6 #
	    [ "${NAMETYPE}" != 'constant' ] && srcUsage_bRead=1
	    # 3.7 #
	    if [ "${srcUsage_bRead}" ]; then
		case ${PRJTYPE} in
		    'file')
			if [ ! -f "${SRC}" -o ! -r "${SRC}" ]; then
			    printfMsg "${errMsg_pf_NotAReadableFile_1}" "${SRC}"
			    exit ${EXIT_ERROR}
			fi
			;;
		    'directory')
			if [ ! -d "${SRC}" -o ! -r "${SRC}" ]; then
			    printfMsg "${errMsg_pf_NotAReadableDirectory_1}" "${SRC}"
			    exit ${EXIT_ERROR}
			fi
			;;
		esac
	    fi
	    # 3.8 #
	    setPrjNameAndDir
	    # 3.9  #
	    if [ "${bakDest_bMustExist}" -a ! -d "${dirPrjDir}" ]; then
		printfMsg "${errMsg_pf_PrjRootNotExisting_1}" "${dirPrjDir}"
		exit ${EXIT_ERROR}
	    fi
	    # 3.10#
	    if [ "${bakDest_bWritable}" -a ! -w "${dirPrjDir}" ]; then
		printfMsg "${errMsg_pf_PrjRootNotWritable_1}" "${dirPrjDir}"
		exit ${EXIT_ERROR}
	    fi
	fi
    fi
    unset bUsageError i

    ### C ###

    if [ "${bakDest_filePrjBak_bPostprocPrjDir}" ]; then
	# 1 #
	bakDest_eType='prj-file'
	# 2 #
	if [ "${bakDest_bMustExist}" -a ! -d "${dirPrjDir}" ]; then
	    printfMsgExitErr "${errMsg_pf_PrjRootNotExisting_1}" "${dirPrjDir}"
	fi
	# 3 #
	if [ -d "${dirPrjDir}" ]; then
	    sBakInfo_filePrjBak=$(bakInfo_select "${dirPrjDir}" 'bak' \
	        "${bakDest_prjFile_eWhichBackups}")
	else
	    sBakInfo_filePrjBak=
	fi
	# 4 #
	if [ "${sBakInfo_filePrjBak}" ]; then
	    local IFS='/'
	    [[ "${sBakInfo_filePrjBak}" =~ (.)$ ]]
	    if [ "${BASH_REMATCH[1]}" = '/' ]; then
		sBakInfo_filePrjBak="${sBakInfo_filePrjBak}/"
	    fi
	    aBakInfo_filePrjBak=(${sBakInfo_filePrjBak})
	    filePrjBak="${dirPrjDir}/${aBakInfo_filePrjBak[${bakInfo_idx_bn}]}"
	else
	    unset aBakInfo_filePrjBak
	    unset filePrjBak
	fi
	# 5 #

	if [ "${bakDest_bMustExist}" ]; then
	    # 1 #
	    if [ ! "${dirPrjDir}" ]; then
		printfMsgExitErr "${errMsg_pf_PrjRootNotExisting_1}" "${dirPrjDir}"
	    fi
	    # 2 #
	    if [ ! "${sBakInfo_filePrjBak}" ]; then
		echoMsgExitErr "${errMsg_s_NoSuchBackup}"
	    fi
	fi
    fi

    ### D ###

    GLOB_aRemainingArgs=("$@")
}

###############################################################################
#   Parses debug/test options.
#
# Argument: the command line arguments remaining after parsing the common and
#           backup arguments.
#
# Sets: GLOB_aRemainingArgs - command line arguments remaining after parsing
#       the debug arguments.
#
# 0. Initialize some test variables.
# 1. Parse test options.  Exit with EXIT_USAGE if we get an error while parsing.
# 2. Handle the options.  Shift away the '--' after the last option.
# 3. Run the test-command "test-dest-deriv".
#    1. Exit with an error message if wrong usage.
#    2. Set the bakDest options depending on the "sub-command".
#    3. Shift away the "sub-command" and run `deriveRootsAndBakDest'.
#    4. Print the result and exit.
# 4. Do setup things for some test-commands.
#    test-dest-deriv)
#      If the test-command is 'test-dest-deriv', the next
#      argument is the subtest.
#      1. Exit if wrong usage.
#      2. Set COMMAND to test-dest-deriv/${subtest} and shift away
#         the ${subtest} (which is ${1}).
#      3. Set values depending on COMMAND.
# 5. Set bakDest_bMustExist to True if [ test_bakDest_bMustExist ]
#    (corresponding to the -e test option).
# 6. Set `GLOB_aRemainingArgs' to the remaining arguments.
###############################################################################
function test_parseDebugCmdLine # ARGUMENT...
{
    # 0 #
    test_bakDest_bMustExist=
    # 1 #
    args=$(getopt ${swGetoptTest} -- "$@")
    [ $? != 0 ] && echoMsgExitUsage "${errMsg_s_test_usage}"
    # 2 #
    eval set -- "${args}"
    while [ "_$1" != '_--' ]; do
	case "$1" in
	    '--help')
		printfMsgExit 0 "${msgTestHelp}" ;;
	    '-c')
		if ! containsWord "${wslTestCommands}" "$2"; then
		    printfMsgExitUsage "${errMsg_pf_invalidTestCommand}" "$2"
		fi
		cmdTest=${2}
		shift ;;
	    '-d') test_DateNow=$(echo ${2} | ${SED} 's/_/ /g') ; shift ;;
	    '-e') test_bakDest_bMustExist=1 ;;
	esac
	shift
    done
    shift
    # 3 #
    if [ "${cmdTest}" = 'test-dest-deriv' ]; then
	# test-dest-deriv #
	# 1 #
	if [ $# -lt 1 ]; then
	    printfMsgExitUsage "${usageDescr_pf_Args_1}" 'test-dest-deriv'
	fi
	# 2 #
	case "${1}" in
	    'abs-arg/bak-dir/existing')
		bakDest_eType='bak-dir'
		bakDest_eSrc='abs-arg'
		bakDest_bMustExist=1
		;;
	    'abs-arg/bak-dir')
		bakDest_eType='bak-dir'
		bakDest_eSrc='abs-arg'
		bakDest_bMustExist=${test_bakDest_bMustExist}
		;;
	    'abs-arg/prj-dir/existing')
		bakDest_eType='prj-dir'
		bakDest_eSrc='abs-arg'
		bakDest_bMustExist=1
		;;
	    'abs-arg/prj-dir')
		# Uses Table 3 (c.2)
		bakDest_eType='prj-dir'
		bakDest_eSrc='abs-arg'
		unset    bakDest_prjFile_eWhichBackups
		bakDest_bMustExist=${test_bakDest_bMustExist}
		;;
	    'abs-arg/prj-file/existing')
		# Uses Table 3 (c.2)
		bakDest_eType='prj-file'
		bakDest_eSrc='abs-arg'
		unset    bakDest_prjFile_eWhichBackups
		bakDest_bMustExist=1
		;;
	    'abs-arg/prj-file')
		bakDest_eType='prj-file'
		bakDest_eSrc='abs-arg'
		bakDest_bMustExist=${test_bakDest_bMustExist}
		;;
	    'env-and-cla/bak-dir')
		bakDest_eType='bak-dir'
		bakDest_eSrc='env-and-cla'
		bakDest_bMustExist=${test_bakDest_bMustExist}
		;;
	    'env-and-cla/prj-dir/program')
		bakDest_eType='prj-dir'
		bakDest_eSrc='env-and-cla'
		bakDest_bMustExist=${test_bakDest_bMustExist}

		readonly srcUsage_wslValidTypes='program'
		srcUsage_bRead=
		;;
	    'env-and-cla/prj-dir/file')
		bakDest_eType='prj-dir'
		bakDest_eSrc='env-and-cla'
		bakDest_bMustExist=${test_bakDest_bMustExist}

		readonly srcUsage_wslValidTypes='file directory'
		srcUsage_bRead= # If we use NAMETYPE != constant, this will be changed to True.
		;;
	    *)
		printfMsgExit ${EXIT_INTERNAL} "${errMsg_pf_Internal_1}" "invalid test-dest-deriv sub-command  (${1})"
	esac
	# 3 #
	shift
	deriveRootsAndBakDest "$@"
	# 4 #
	case ${bakDest_eType} in
	    'bak-dir')  echo "${dirBakRoot}" ;;
	    'prj-dir')  echo "${dirPrjDir}" ;;
	    'prj-file') echo "${filePrjBak}" ;;
	esac
	exit 0
    fi
    # 5 #
    if [  "${test_bakDest_bMustExist}" ]; then
	bakDest_bMustExist=1
    fi
    # 6 #
    GLOB_aRemainingArgs=("$@")
}

###############################################################################
#   Execute some test-commands that should not use the normal parsing of
# command line arguments.
#
#   If any of these test-commands are run, they also exit the program.
#
#  2. Execute the test-command 'print-free-dt-part'.
#     1. Exit with error message if exactly one argument is NOT given
#        which is a readable directory.
#     2. Set sDtPart to the date-time-part of the backupname.
#        If test_DateNow is given, then that datetime should be used
#        instead of the current datetime.
#     3. Run getAndLockFreshBackupNameForCurrTime, print the variables and exit.
#  3. Execute the test-command 'gen-target-name'.
#     1. Exit if wrong usage.
#     2. Set the datetime to use. Either it should be the current datetime
#        or the date given a test CL-option.
#     3. Execute the test and exit.  If a tag is given, it should be passed
#        to getAndLockFreshBackupNameForDtPart.
#  4. Execute the test-command 'print-prjname-tail'.
#     1. Check usage.  If NAMETYPE is not 'constant' we need a file as the
#        single argument.
#     2. Run setPrjNameTail.
#        1. Run with absolute name of file argument if NAMETYPE !=
#        'constant', ...
#        2. ... otherwise, run without argument.
#     3. Print `sPrjNameTail' and exit.
# 5. Execute test-command 'bak-info-select'.
#    1. Exit with error message if exactly one argument is NOT given
#       which is a readable directory.
#    3. Run `bakInfo_select' and exit.
# 6. Execute test-command 'doRemoveProject'.
###############################################################################
function test_doMaybeExecuteTestAndExit_preRootBakDestParse # ARGUMENT...
{
    # 2 #

    if [ "${cmdTest}" = 'print-free-dt-part' ]; then
        # .1 #
	if [ $# != 1 -o ! -d "$1" -o ! -r "$1" ]; then
	    printfMsgExitUsage "${usageDescr_pf_prjRoot_1}" 'print-free-dt-part'
	fi
        # .2 #
	if [ "${test_DateNow}" ]; then
	    sDtPart=$(date --date="${test_DateNow}" +"${format_date_DtPart}")
	else
	    sDtPart=$(date +"${format_date_DtPart}")
	fi
        # .3 #
	getFreeDtPartForDatetime "${1}" "${sDtPart}"
	exit 0
    fi

    # 3 #

    if [ "${cmdTest}" = 'gen-target-name' ]; then
        # .1 #
	if [ \( $# != 1 -a $# != 2 \) -o ! -d "$1" -o ! -r "$1" ]; then
	    echo "gen-target-name: PROJECT-DIRECTORY [TAG]"
	fi
        # .2 #
	if [ "${test_DateNow}" ]; then
	    sDtPart=$(date --date="${test_DateNow}" +"${format_date_DtPart}")
	else
	    sDtPart=$(date +"${format_date_DtPart}")
	fi
        # .3 #
	if [ $# = 2 ]; then
	    getAndLockFreshBackupNameForDtPart "${1}" "${sDtPart}" "${2}"
	else
	    getAndLockFreshBackupNameForDtPart "${1}" "${sDtPart}"
	fi
	echo "${TARGET_BN_HEAD}"
	echo "${TARGET_BN_WoEXT}"
	echo "${TARGET_BN_LOCK}"
	echo "${TARGET_WoEXT}"
	echo "${TARGET_fileLock}"
	exit 0
    fi

    # 4 #

    if [ "${cmdTest}" = 'print-prjname-tail' ]; then
        # .1 #
	if [ "${NAMETYPE}" != 'constant' -a $# != 1 ]; then
	    echoMsgExitErr "${errMsg_s_printPrjNameTail_FileMissing}"
	fi
        # .2 #
	if [ "${NAMETYPE}" != 'constant' ]; then
        	# 2.1 #
	    [ -f "$1" ] || printfMsgExitErr "${errMsg_pf_NotAFile_1}" "${1}"
	    sAbsSrc=$(abspath "$1")
	    setPrjNameTail "${sAbsSrc}"
	else
            # 2.2 #
	    setPrjNameTail
	fi
        # .4 #
	echo "${sPrjNameTail}"
	exit 0
    fi

    # 5 #

    if [ "${cmdTest}" = 'bak-info-select' ]; then
        # .1 #
	if [ $# != 4 -o ! -d "$4" -o ! -r "$4" ]; then
	    echoMsgExitUsage "${usageDescr_s_bakInfoSelect}"
	fi
        # .2 #
	bakInfo_select "${4}" "${1}" "${2}" "${3}"
	exit 0
    fi

    # 6 #
    if [ "${cmdTest}" = 'doRemoveProject' ]; then
        # .1 #
	if [ $# != 1 -a $# != 2 ]; then
	    echoMsgExitUsage "${usageDescr_s_doRemoveProject}"
	fi
        # .2 #
	doRemoveProject "${@}"
	exit 0
    fi
}

function test_doMaybeExecuteTestAndExit_preRootBakDest
{
    if [ "${cmdTest}" = 'print-rsync-options' ]; then
	run_rsync '' ''
	exit 0
    fi
}

###############################################################################
#   Execute those test-commands that use the normal parsing of command line
# arguments.
#
#   Exists the program if any test is executed.
#
# 1. If test-command is test-dest-deriv (=> [COMMAND =^ '^test-dest-deriv']),
#    print the destintion and exit.
# 2. Execute test-command 'print-prjname'.
# 3. Execute test-command 'print-roots'.
# 4. Execute test-command 'print-source'.
###############################################################################
function test_doMaybeExecuteTestAndExit_postRootBakDestParse # CLA...
{
    # 1 #

    case "${cmdTest}" in
	'print-prjname')
	    # 2 #
	    echo "${sPrjName}"
	    exit 0 ;;
	'print-source')
	    # 4 #
	    echo "${SRC}"
	    exit 0 ;;
	'print-derived-options')
	    # 5 #
	    echo "${COMMAND}"
	    echo "${PRJTYPE}"
	    echo -n "${NAMETYPE}:"
	    case ${NAMETYPE} in
		'suffix')    echo "${CLO_NAME_sPrefix}" ;;
		'constant')  echo "${CLO_NAME_sConstant}" ;;
		*)           echo '' ;;
	    esac
	    exit 0
	    ;;
	'dest-deriv-prj-file')
	    if [ ${bakDest_eType} = 'prj-file' ]; then
		echo "${dirPrjDir}"
		echo "${filePrjBak}"
		IFS='/'
		echo "${aBakInfo_filePrjBak[*]}"
	    else
		echo "${dirPrjDir}"
	    fi
	    exit 0
	    ;;
    esac
}

###############################################################################
# - main -
###############################################################################

###############################################################################
# 0. Initialize backup options.
#
# A. Read CLA's. Execute those test commands which only accesses the CLAs.
#    1. If no arguments at all, show usage and exit.
#    2. Parse common and backup option with `getopts'.
#       2. Shift away the '--'.
#
# B. If CLO_bDebug, parse test options.
#    Pass the remaining command line arguments and receive the remaining
#    ones in `GLOB_aRemainingArgs'.  Set these to the current arguments.
#
# C. Execute some test-commands that should not use the normal parsing of
#    command line arguments.
#    If any of these test-commands are run, they also exit the program.
#
# D. Set COMMAND and parse command-options.
#
# F. Set root directories and the backup destination depending on COMMAND.
#
# G. Execute those test-commands that use the normal parsing of command line
#    arguments.
#
# H. Execute non-backup commands and exit.
#    clean)
#       Two cases: With or without the option CLO_bRecursive.
#       Use either "prj-dir" or "bak-dir".
#    print-file-inside-backup)
#       10. Exit with usage-error if there is not exactly one command line
#           argument.  Otherwise, set file to it.
#       20. Exit with error if SRC is not a directory.
#       30. Exit with error if the CLA is not an existing file.
#       40. Set fileInsideBak to the file inside the backup.
#           Exit with error if the CLA is not a file under SRC.
#           The case when SRC is '/' must be treated specially, since this is
#           the only case when the realpath of SRC ends with a slash.
#           At the same time, this case is extreme, and will probably never
#           happen: if SRC is /, then the backup - which must be located under
#           /, is included in the source.
#       50. Print the result and exit.
#    tag)
#       We have dirPrjDir, bakInfo_filePrjBak, filePrjBak
#       0. Check that the tag only contains "valid" characters.
#       1. Quit if the tag is already in use by a different backup than the one
#          we are tagging.  If it is used by the same backup we are done, so we
#          just need to print the backup and exit.
#       2. Construct the new one ("into" the array RENAME_TAG_aBakInfo).
#       3. Rename the file using `mv'.
#       4. Present the backup.
#       5. Exit
#    untag)
#       We have dirPrjDir, bakInfo_filePrjBak, filePrjBak
#       1. Quit if the backup doesn't have a tag.  Then just present the backup
#          and we are done.
#       2. Construct the new one ("into" the array RENAME_TAG_aBakInfo).
#       3. Rename the file using `mv'.
#       4. Present the backup.
#       5. Exit
#   
#
# I. When we are here we know that we are doing a backup (plain, add or sync).
#    Check options and the source. Also set the source and the project root
#    directory to the "absolute path" of themselves.
#    Make sure that .copyback-exclude is used, if it should.
#    1. Check CL options.
#       1. OUTPUTEXT: can only be used with PRJTYPE="program" and cannot be
#          the same as extension for lock files.
#       2. CLO_bak_bTar: can only be used with PRJTYPE='directory'.
#       3. ADD: Only directories can be added to.
#       4. If a tag has been given, check that it is valid.  Exit if it isn't.
#    2. If the project directory does not exist, it needs to be created.
#       Exit if we can't create it.
#    3. User the abspath of some paths: the project directory and
#       the source (`SRC') if it is a file or directory.
#    4. If the source is a file or directory: Check that the source is not a
#       prefix of the project directory, and vice versa.
#    5. Make sure that .copyback-exclude is used, if it should.
#       If the project is a directory project and the source directory contains
#       a copyback exclude file, set rsync options for using this file.
#       Add an option to ` rsync_swVariable'.
#
# J. Execute the backup, depending on `CLO_bak_eUpdate'.
#    1. Execute the command.
#       We should create a new backup if we are not updating, or if we are
#       updating but there was no backup to update.
#    2. If the exit code is zero, print the name of the backup.  Otherwise,
#       exit with `EXIT_ERROR'.
###############################################################################

### 0 #########################################################################

bak_sAssignTag=

### A #########################################################################

args=$(getopt ${swGetopt_gen_bak} -- "$@")

[ $? != 0 ] && echo "${sUsage}" >&2 && exit ${EXIT_USAGE}

eval set -- "$args"

# 1 #

[ $# = 0 ] && echo "${sUsage}" >&2 && exit ${EXIT_USAGE}

# 2 #

while [ "_$1" != '_--' ]; do
    case "$1" in
	'--root')                         CLO_dirBakRoot="$2"        ; shift ;;
	'--gr'  | '--root-global')        CLO_dirGlobalRoot=${2}     ; shift ;;
	'--grs' | '--root-global-suffix') CLO_sGlobalRootSuffix=${2} ; shift ;;

	'--print-filename'       | '--prfn')  eBakPresFormat='filename'  ;;
	'--print-filename-extra' | '--prfne') eBakPresFormat='filename-extra' ;;
	'--print-formatted'      | '--prft')  eBakPresFormat='formatted' ;;

	'--debug')                        CLO_bDebug=1 ;;

	# GNU Standard options
	'-V' | '--version' )    echo ${VERSION} ; exit 0 ;;
	'--help')               echo "${sHelp}" ; exit 0 ;;

	# BACKUP-OPTIONS
	*)                      parseCmdOpts_nShift=1
                                parseCmdOptions_callback_backup "$@"
	                        let --parseCmdOpts_nShift
	                        shift ${parseCmdOpts_nShift} ;;
    esac
    shift
done
# 2.2 #
shift

### B #########################################################################

if [ "${CLO_bDebug}" ]; then
    test_parseDebugCmdLine "$@"
    set -- "${GLOB_aRemainingArgs[@]}"
fi

### C #########################################################################

if [ "${cmdTest}" ]; then
    test_doMaybeExecuteTestAndExit_preRootBakDestParse "$@"
fi

### D #########################################################################

parseCommand "$@"
set -- "${GLOB_aRemainingArgs[@]}"

### E #########################################################################

if [ "${cmdTest}" ]; then
    test_doMaybeExecuteTestAndExit_preRootBakDest "$@"
fi

### F #########################################################################

deriveRootsAndBakDest "$@"
set -- "${GLOB_aRemainingArgs[@]}"

### G #########################################################################

test_doMaybeExecuteTestAndExit_postRootBakDestParse "$@"

### H #########################################################################
case ${COMMAND} in
    'list')
	doListBackups "${dirPrjDir}"
	exit
	;;
    'find')
	if [[ ${bakDest_eType} = 'bak-dir' ]]; then
	    doFindProjectDirs "${dirBakRoot}"
	else
	    doFindProjectDirs "${dirPrjDir}"
	fi
	exit
	;;
    'remove-project')
	if [ -n "${dirBakRoot}" ]; then
	    doRemoveProject "${dirPrjDir}" "${dirBakRoot}"
	else
	    doRemoveProject "${dirPrjDir}"
	fi
	exit
	;;
    'lock')
	case "${bakDest_prjFile_eWhichBackups}" in
	    'all') cmdLockAll "${dirPrjDir}"  ;;
	    *)     cmdLockBackup "${dirPrjDir}" "${aBakInfo_filePrjBak[@]}" ;;
	esac
	exit
	;;
    'unlock')
	case "${bakDest_prjFile_eWhichBackups}" in
	    'all') cmdUnlockAll "${dirPrjDir}" ;;
	    *)     doUnlockBackup "${dirPrjDir}" "${aBakInfo_filePrjBak[@]}" ;;
	esac
	exit
	;;
    'clean')
	if [ "${CLO_bRecursive}" ]; then
	    doCleanDirsRecursively "${dirBakRoot}" "${CLO_nonBak_bForce}"
	else
	    doCleanDir "${dirPrjDir}" "${CLO_nonBak_bForce}"
	fi
	exit
	;;
    'print-backup-root-directory')
	echo "${dirBakRoot}"
	exit
	;;
    'print-project-name')
	echo "${sPrjName}"
	exit
	;;
    'print-project-directory')
	echo "${dirPrjDir}"
	exit
	;;
    'print-backup-file')
	abspath "${filePrjBak}"
	exit
	;;
    'print-file-inside-backup')
	file="${printFileInsideBackup_sFile}"
	## 20 ##
	if [ ! -d "${SRC}" ]; then
	    echoMsgExitErr "The source must be a directory: ${SRC}."
	fi
	## 30 ##
	if [ ! -f "${file}" ]; then
	    echoMsgExitErr "The argument must be an existing file: ${file}."
	fi
	## 40 ##
	SRC=$(abspath "${SRC}") # TODO abspath (var realpath förr)?
	file=$(abspath "${file}") # TODO abspath (var realpath förr)?
	if [ "${SRC}" = '/' ]; then
	    fileInsideBak="${filePrjBak}${file}"
	else
	    pathUnderSRC="${file#${SRC}}"
	    if [ "_${pathUnderSRC:0:1}" != '_/' ]; then
		echoMsgExitErr "The argument must be a file under the source ${SRC}."
	    fi
	    fileInsideBak="${filePrjBak}${pathUnderSRC}"
	fi
	echo "${fileInsideBak}"
	exit
	;;
    'tag')
	# 0 #
	if [[ ! ${tag_sTag} =~ ^${tag_ereTag}$ ]]; then
	    printfMsg "${errMsg_pf_InvalidTag_1}" "${tag_sTag}"
	    exit ${EXIT_ERROR}
	fi
	# 1 #
	sBakInfo_existing=$(bakInfo_select "${dirPrjDir}" 'bak' "tag/${tag_sTag}")
	if [ "${sBakInfo_existing}" ]; then
	    old_IFS=${IFS}
	    IFS='/'
	    declare -a aBakInfo_existing
	    aBakInfo_existing=(${sBakInfo_existing})
	    IFS=${old_IFS}
	    if [   "${aBakInfo_existing[${bakInfo_idx_bn}]}" = \
		 "${aBakInfo_filePrjBak[${bakInfo_idx_bn}]}" ]; then
		presentBackup "${aBakInfo_filePrjBak[@]}"
		exit 0
	    else
		printfMsg "${errMsg_pf_tagAlreadyInUse}" "${tag_sTag}"
		exit ${EXIT_ERROR}
	    fi
	fi
	# 2 #
        bakInfo_rename_tag --tag "${tag_sTag}" "${aBakInfo_filePrjBak[@]}"
	filePrjBak_new="${dirPrjDir}/${RENAME_TAG_aBakInfo[${bakInfo_idx_bn}]}"
	# 3 #
	if ! mv "${filePrjBak}" "${filePrjBak_new}"; then
	    # TODO errmsg: error moving
	    exit ${EXIT_ERROR}
	fi
	# 4 #
	presentBackup "${RENAME_TAG_aBakInfo[@]}"
	# 5 #
	exit 0
	;;
    'untag')
	# 1 #
	if [ ! "${aBakInfo_filePrjBak[${bakInfo_idx_tag}]}" ]; then
	    presentBackup "${aBakInfo_filePrjBak[@]}"
	    exit 0
	fi
	# 2 #
        bakInfo_rename_tag "${aBakInfo_filePrjBak[@]}"
	filePrjBak_new="${dirPrjDir}/${RENAME_TAG_aBakInfo[${bakInfo_idx_bn}]}"
	# 3 #
	if ! mv "${filePrjBak}" "${filePrjBak_new}"; then
	    # TODO errmsg: error moving
	    exit ${EXIT_ERROR}
	fi
	# 4 #
	presentBackup "${RENAME_TAG_aBakInfo[@]}"
	# 5 #
	exit 0
	;;
esac

### I #########################################################################

# 1 #

# .1 #
if [ "${OUTPUTEXT}" ]; then
    if [ "${PRJTYPE}" != 'program' ] ; then
	printfMsgExitErr "${errMsg_pf_Opt_CanOnlyForPrjType_Program_1}" "${optname_sExt}"
    fi
    if [ "${OUTPUTEXT}" = "${LOCKFILE_EXT}" ] ; then
	echoMsgExitErr "${errMsg_s_Opt_InvalidOutputExt}"
    fi
fi
# .2 #
if [ "${CLO_bak_bTar}" -a "${PRJTYPE}" != 'directory' ] ; then
    printfMsgExitErr "${errMsg_pf_Opt_CanOnlyForPrjType_Dir_1}" "${optname_sTar}"
fi
# .3 #
if [ "${CLO_bak_bNoDelete}" -a "${PRJTYPE}" != 'directory' ]; then
    printfMsgExitErr "${errMsg_pf_Opt_CanOnlyForPrjType_Dir_1}" optname_sAdd
fi
# .4 #
if [ "${bak_sAssignTag}" ]; then
    if [[ ! ${bak_sAssignTag} =~ ^${tag_ereTag}$ ]]; then
	printfMsg "${errMsg_pf_InvalidTag_1}" "${bak_sAssignTag}"
	exit ${EXIT_ERROR}
    fi
fi

# 2 #

if [ ! -e "${dirPrjDir}" ]; then
    if ! mkdir --parents "${dirPrjDir}"; then
	printfMsg "${errMsg_pf_CantCreatePrjRoot_1}" "${dirPrjDir}"
	exit ${EXIT_ERROR}
    fi
fi

# 3 #

dirPrjDir=$(abspath "${dirPrjDir}")
if [ "${PRJTYPE}" != 'program' ]; then
    SRC=$(abspath "${SRC}")
fi

# 4 #

if [ "${PRJTYPE}" != 'program' ] ; then
    nLenSrc=${#SRC}
    nLenRoot=${#dirPrjRoot}

    if [ "${SRC}" = "${dirPrjDir::${nLenSrc}}" ]; then
	printfMsg "${errMsg_pf_SrcPrefixOfPrjRoot_2}" "${SRC}" "${dirPrjDir}"
	exit ${EXIT_ERROR}
    fi

    if [ "${dirPrjDir}" = "${SRC::${nLenRoot}}" ]; then
	printfMsg "${errMsg_pf_PrjRootPrefixOfSrc_2}" "${dirPrjDir}" "${SRC}"
	exit ${EXIT_ERROR}
    fi
fi

# 5 #

if [ "${PRJTYPE}" = 'directory' ] ; then
    if [ -f "${SRC}/${sStandardExcludeFile}" ]; then
	rsync_swVariable="${rsync_swVariable} --exclude-from='${SRC}/${sStandardExcludeFile}'"
    fi
fi

### J #########################################################################

# 1 #
if [ ! "${CLO_bak_eUpdate}" -o ! "${filePrjBak}" ]; then
    [ "${bak_sAssignTag}" ] \
	&& doCreateNewBackup "${bak_sAssignTag}" \
	|| doCreateNewBackup
else
    [ "${bak_sAssignTag}" ] \
	&& doSyncExistingBackup "${bak_sAssignTag}"  \
	|| doSyncExistingBackup
fi
# 2 #
[ $? = 0 ] && echo "${TARGET}" || exit ${EXIT_ERROR}
