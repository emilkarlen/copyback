m4_define(`M4_TESTS_ROOT',`../../../../..')
m4_include(../M4_TESTS_ROOT/common-directories.m4)

m4_include(../M4_COMMON_DIR/m4/exit-codes.m4)

m4_define(`M4_REPLACE_USER_IN_STDOUT',`
check.prepare.run.cmdline:ex -s -c "%s;/$(id -nu);/_USER_;" -c x ${SIMPTEST_STDOUT}')
