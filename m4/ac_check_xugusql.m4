dnl ---------------------------------------------------------------------------
dnl Macro: AC_CHECK_XUGUSQL
dnl First check for custom XuguSQL paths in --with-xugusql-* options.
dnl If some paths are missing,  check if xugu_config exists. 
dnl ---------------------------------------------------------------------------

AC_DEFUN([AC_CHECK_XUGUSQL],[

# Check for custom includes path
if test [ -z "$ac_cv_xugusql_includes" ] 
then 
    AC_ARG_WITH([xugusql-includes], 
                AC_HELP_STRING([--with-xugusql-includes], [path to XuguSQL header files]),
                [ac_cv_xugusql_includes=$withval])
fi
if test [ -n "$ac_cv_xugusql_includes" ]
then
    AC_CACHE_CHECK([XuguSQL includes], [ac_cv_xugusql_includes], [ac_cv_xugusql_includes=""])
    XUGUSQL_CFLAGS="-I$ac_cv_xugusql_includes"
fi

# Check for custom library path

if test [ -z "$ac_cv_xugusql_libs" ]
then
    AC_ARG_WITH([xugusql-libs], 
                AC_HELP_STRING([--with-xugusql-libs], [path to XuguSQL libraries]),
                [ac_cv_xugusql_libs=$withval])
fi

if test [ -n "$ac_cv_xugusql_libs" ]
then
     AC_CACHE_CHECK([XuguSQL libraries], [ac_cv_xugusql_libs], [ac_cv_xugusql_libs=""])
     XUGUSQL_LIBS="-L$ac_cv_xugusql_libs -lxgci"
fi

# If some path is missing, try to autodetermine with xugusql_config
if test [ -z "$ac_cv_xugusql_includes" -o -z "$ac_cv_xugusql_libs" ]
then
    if test [ -z "$xuguconfig" ]
    then 
        AC_PATH_PROG(xuguconfig,xugu_config)
    fi
    if test [ -z "$xuguconfig" ]
    then
        AC_MSG_ERROR([xugu_config executable not found
********************************************************************************
ERROR: cannot find XuguSQL libraries. If you want to compile with XuguSQL support,
       you must either specify file locations explicitly using 
       --with-xugusql-includes and --with-xugusql-libs options, or make sure path to 
       xugu_config is listed in your PATH environment variable. If you want to 
       disable XuguSQL support, use --without-xugusql option.
********************************************************************************
])
    else
        if test [ -z "$ac_cv_xugusql_includes" ]
        then
            AC_MSG_CHECKING(XuguSQL C flags)
            XUGUSQL_CFLAGS="-I`${xuguconfig} --includedir`"
            AC_MSG_RESULT($XUGUSQL_CFLAGS)
        fi
        if test [ -z "$ac_cv_xugusql_libs" ]
        then
            AC_MSG_CHECKING(XuguSQL linker flags)
            XUGUSQL_LIBS="-L`${xuguconfig} --libdir` -lxgci"
            AC_MSG_RESULT($XUGUSQL_LIBS)
        fi
    fi
fi
])

