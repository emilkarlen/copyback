m4_define(`M4_TESTS_ROOT',`../..')
m4_include(../M4_TESTS_ROOT/common-directories.m4)

m4_include(../M4_COMMON_M4/exit-codes.m4)

m4_define(`M4_SETUP_TESTDATA',`
setup.run.cmdline:mkdir bak-root
setup.run.cmdline:cp -rdp ${SIMPTEST_HOME}/M4_COMMON_DATA/bak-info bak-root/a_name
setup.run.cmdline:touch a_name
')

# Run copyback print-backup-file.
# Argument: The print-backup-file options that locates the backup,
# (for example '--date 20070510-143502')
m4_define(`M4_TEST_RUN_PBF_WITH',`test.run.cmdline/prepend-home:M4_SRC_BIN/copyback --root bak-root --pnh --basename print-backup-file $1 a_name')

# Performs check for successfull execution.
# Argument: the file (relative home) that should match stdout (after
# replacement of simptest environment variables).
m4_define(`M4_CHECK_SUCCESS_AND_FILE',`
check.prepare.replace-SIMPTEST-envvars/stdout
check.exitcode:0
check.stdout.file.eq/replaced:$1')
