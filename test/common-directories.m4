m4_dnl Definition of directory variables used for testing.
m4_dnl
m4_dnl XXX: Maybe this file should be named sb-common.m4, or something
m4_dnl      and not just contain directory variables, but also common
m4_dnl      testcase "commands".  The env.unset commands at the bottom
m4_dnl      are such commands.
m4_dnl
m4_dnl USAGE
m4_dnl -----------------------------------------------------------------------
m4_dnl   Define `M4_TESTS_ROOT' to the root tests directory relative
m4_dnl the testcases home directory.
m4_dnl Then include this file, which usually will reside in ../M4_TESTS_ROOT
m4_dnl since the m4 preprocessing is done with the testcases directory
m4_dnl as the current directory.
m4_dnl

m4_define(`M4_PROJECT_ROOT',`../M4_TESTS_ROOT')
m4_define(`M4_SRC_BIN',`M4_PROJECT_ROOT/src')
m4_define(`M4_COMMON_DIR',`M4_TESTS_ROOT/common')
m4_define(`M4_COMMON_BIN',`M4_COMMON_DIR/scripts')
m4_define(`M4_COMMON_M4',`M4_COMMON_DIR/m4')
m4_define(`M4_COMMON_DATA',`M4_COMMON_DIR/data')

# Unset the variables used by a maybe installed copyback
env.unset:COPYBACK_ROOT
env.unset:COPYBACK_ROOT_GLOBAL
