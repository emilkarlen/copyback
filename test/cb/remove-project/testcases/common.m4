m4_define(`M4_TESTS_ROOT',`../..')
m4_include(../M4_TESTS_ROOT/common-directories.m4)

m4_include(../M4_COMMON_M4/exit-codes.m4)

# Macro for commands that uses stuff in lib-tools.bash.
m4_define(`M4_WITH_LIBTOOLS',`source ${SIMPTEST_HOME}/M4_COMMON_BIN/lib-tools.bash; $1')

# Macros for paths that are used in these tests.
m4_define(`M4_BakRoot',`bak')
m4_define(`M4_SrcRoot',`src')
m4_define(`M4_PrjName',`a/b/c/target')
m4_define(`M4_PrjNameSrcDir',`M4_SrcRoot/M4_PrjName')

# The options to printBackupName and printBackupLockName in
# lib-tools.bash.
m4_define(`M4_BAKOPTS',`-t 20101211_1230')

# setup command that creates the project directory
m4_define(`M4_SETUP_SRC',`
setup.run.cmdline:mkdir --parents M4_PrjNameSrcDir
setup.run.cmdline:touch           M4_PrjNameSrcDir/file.txt
')

# copyback options that specify the backup root directory.
m4_define(`M4_optsRoot',`--root M4_BakRoot')

# copyback options that specify the naming scheme.
m4_define(`M4_optsPrjName',`--suffix M4_SrcRoot')

# Sets up the source and creates a backup.
# Argument: additional backup options.
m4_define(`M4_SETUP_SRC_AND_BACKUP',`
M4_SETUP_SRC
setup.run.cmdline/prepend-home:M4_SRC_BIN/copyback M4_optsRoot backup $1 M4_optsPrjName M4_PrjNameSrcDir
')

# copyback command that prints the project directory.
m4_define(`M4_printPrjDir',`${SIMPTEST_HOME}/M4_SRC_BIN/copyback M4_optsRoot M4_optsPrjName pd M4_PrjNameSrcDir')
