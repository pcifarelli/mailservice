#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([mailservice], [0.1], [paul.cifarelli@thomsonreuters.com])
AC_CONFIG_SRCDIR([src/mailserviceentrypoint.cpp])
#AC_CONFIG_MACRO_DIRS([m4])
AM_INIT_AUTOMAKE
AC_CONFIG_HEADERS(config.h)

AM_INIT_AUTOMAKE([subdir-objects])

# --enable-docker		build docker from amazonlinux (default) (Dockerfile=Dockerfile.amazonlinux)
# --enable-docker=amazonlinux	build docker from amazonlinux (Dockerfile=Dockerfile.amazonlinux)
# --enable-docker=ubuntu	build docker from ubuntu (Dockerfile=Dockerfile.ubuntu)
#
AC_ARG_ENABLE([docker],
[ --enable-docker		Build docker image],
[case "${enableval}" in
  yes) docker=true ;;
  no)  docker=false ;;
  *) AC_MSG_ERROR([bad value ${enableval} for --enable-docker]) ;;
esac], [docker=false])
AM_CONDITIONAL([DOCKER], [test x$docker = xtrue])

# Checks for programs.
AC_PROG_CC
AC_PROG_CXX

# Checks for libraries.

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

# Output
AC_OUTPUT(Makefile src/Makefile)
