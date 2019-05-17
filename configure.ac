AC_INIT([copyback],[0.9],[Emil Karlen <emil@member.fsf.org>])
AC_CONFIG_AUX_DIR([auxiliary])
AM_INIT_AUTOMAKE([tar-ustar dist-bzip2])
AC_PROG_SED
AC_PROG_AWK
AC_PATH_PROGS(BASH, bash)

AC_ARG_VAR(TAGS, [Program that creates a TAGS file.])
AC_CHECK_PROG(TAGS,etags,etags)

dnl Exists if the given executable is not found in PATH.
dnl Arguments: (executable)
m4_define([MY_ERROR_IF_PGM_NOT_IN_PATH],[
AC_CHECK_PROG([my_bFound],[$1],[yes],)
AS_IF([test -z "$my_bFound"],
      [AC_MSG_ERROR([the program `$1' is needed, but not found in PATH.])])
])

MY_ERROR_IF_PGM_NOT_IN_PATH([awk])
MY_ERROR_IF_PGM_NOT_IN_PATH([cat])
MY_ERROR_IF_PGM_NOT_IN_PATH([chmod])
MY_ERROR_IF_PGM_NOT_IN_PATH([cut])
MY_ERROR_IF_PGM_NOT_IN_PATH([date])
MY_ERROR_IF_PGM_NOT_IN_PATH([diff])
MY_ERROR_IF_PGM_NOT_IN_PATH([find])
MY_ERROR_IF_PGM_NOT_IN_PATH([getopt])
MY_ERROR_IF_PGM_NOT_IN_PATH([gunzip])
MY_ERROR_IF_PGM_NOT_IN_PATH([gzip])
MY_ERROR_IF_PGM_NOT_IN_PATH([head])
MY_ERROR_IF_PGM_NOT_IN_PATH([ls])
MY_ERROR_IF_PGM_NOT_IN_PATH([mv])
MY_ERROR_IF_PGM_NOT_IN_PATH([realpath])
MY_ERROR_IF_PGM_NOT_IN_PATH([rm])
MY_ERROR_IF_PGM_NOT_IN_PATH([rsync])
MY_ERROR_IF_PGM_NOT_IN_PATH([sed])
MY_ERROR_IF_PGM_NOT_IN_PATH([tac])
MY_ERROR_IF_PGM_NOT_IN_PATH([tar])
MY_ERROR_IF_PGM_NOT_IN_PATH([touch])
MY_ERROR_IF_PGM_NOT_IN_PATH([tr])

AC_CONFIG_FILES([Makefile])
AC_CONFIG_FILES([src/Makefile])
AC_CONFIG_FILES([src/constants.sh])
AC_CONFIG_FILES([help/Makefile])
AC_CONFIG_FILES([bin/Makefile])
AC_CONFIG_FILES([test/common/scripts/Makefile])
AC_CONFIG_FILES([bin/run_tests], [chmod +x bin/run_tests])
AC_OUTPUT
