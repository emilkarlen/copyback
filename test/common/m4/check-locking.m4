m4_dnl
m4_dnl Checks for locking of backups.
m4_dnl

# Checks that the backup, who's name is given as an argument,
# has a corresponding lock-file.
# backup-is-locked is used to check the existence of the lockfile.
# Argument 1: name of backup.
m4_define(`M4_CHECK_BACKUP_IS_LOCKED',`
check.run.cmdline/prepend-home:M4_COMMON_BIN/backup-is-locked $1')

# As above but the backkup's name is the only content printed to stdout.
m4_define(`M4_CHECK_BACKUP_IS_LOCKED_STDOUT',`
check.run.cmdline/prepend-home:M4_COMMON_BIN/backup-is-locked $(cat ${SIMPTEST_STDOUT})')

# Check that the given directory contains one locked backup.
# The basename of the backup is given as an argument.
# Argument 1 : directory
# Argument 2 : (complete) name of backup in that directory
#
#   Check that the directory contains exactly two files - the backup and the
# lockfile.
#   Check that the backup has a corresponding lockfile.
#
m4_define(`M4_CHECK_ONE_LOCKED_BACKUP',`
check.run.cmdline:test $(ls $1 | wc -l) == 2
check.run.cmdline/prepend-home:M4_COMMON_BIN/backup-is-locked $2')

m4_define(`M4_CHECK_NUM_LOCK_FILES_IN_DIR',`
check.run.cmdline:test $(ls $1/*.lock | wc -l) == $2')
