# Must be included AFTER `common.m4'!

# Uses: M4_COMMON_BIN

###############################################################################
# DEFINES
# * M4_CheckNewBackupName_env_set
# * M4_CheckNewBackupName_check
#
# These are used to check that the name of the created backup is correct.
# This is done as described in the Test Plan.
#
# USAGE
#  First use `'M4_CheckNewBackupName_env_set' to set needed environment
# variables.  Then use `M4_CheckNewBackupName_check' to do the acutal checking.
# `M4_CheckNewBackupName_check' takes as argument the options to pass to
# `stdin-is-backupname'.
###############################################################################

m4_define(`M4_cmdDtNow',`date --rfc-3339=seconds')

m4_define(`M4_CheckNewBackupName_env_set',`
env.set:DATETIME_BEFORE:$(M4_cmdDtNow)
env.set/mkabspath:PGM_s_i_b:M4_COMMON_BIN/stdin-is-backupname')

m4_define(`M4_CheckNewBackupName_check',`
check.run.interpret.source:bash:cat ${SIMPTEST_STDOUT_REPLACED} | ${PGM_s_i_b} "${DATETIME_BEFORE}" "$(M4_cmdDtNow)" $1')
