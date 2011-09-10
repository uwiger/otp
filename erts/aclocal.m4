dnl
dnl %CopyrightBegin%
dnl
dnl Copyright Ericsson AB 1998-2011. All Rights Reserved.
dnl
dnl The contents of this file are subject to the Erlang Public License,
dnl Version 1.1, (the "License"); you may not use this file except in
dnl compliance with the License. You should have received a copy of the
dnl Erlang Public License along with this software. If not, it can be
dnl retrieved online at http://www.erlang.org/.
dnl
dnl Software distributed under the License is distributed on an "AS IS"
dnl basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
dnl the License for the specific language governing rights and limitations
dnl under the License.
dnl
dnl %CopyrightEnd%
dnl

dnl
dnl aclocal.m4
dnl
dnl Local macros used in configure.in. The Local Macros which
dnl could/should be part of autoconf are prefixed LM_, macros specific
dnl to the Erlang system are prefixed ERL_.
dnl

AC_DEFUN(LM_PRECIOUS_VARS,
[

dnl ERL_TOP
AC_ARG_VAR(ERL_TOP, [Erlang/OTP top source directory])

dnl Tools
AC_ARG_VAR(CC, [C compiler])
AC_ARG_VAR(CFLAGS, [C compiler flags])
AC_ARG_VAR(STATIC_CFLAGS, [C compiler static flags])
AC_ARG_VAR(CFLAG_RUNTIME_LIBRARY_PATH, [runtime library path linker flag passed via C compiler])
AC_ARG_VAR(CPP, [C/C++ preprocessor])
AC_ARG_VAR(CPPFLAGS, [C/C++ preprocessor flags])
AC_ARG_VAR(CXX, [C++ compiler])
AC_ARG_VAR(CXXFLAGS, [C++ compiler flags])
AC_ARG_VAR(LD, [linker (is often overridden by configure)])
AC_ARG_VAR(LDFLAGS, [linker flags (can be risky to set since LD may be overriden by configure)])
AC_ARG_VAR(LIBS, [libraries])
AC_ARG_VAR(DED_LD, [linker for Dynamic Erlang Drivers (set all DED_LD* variables or none)])
AC_ARG_VAR(DED_LDFLAGS, [linker flags for Dynamic Erlang Drivers (set all DED_LD* variables or none)])
AC_ARG_VAR(DED_LD_FLAG_RUNTIME_LIBRARY_PATH, [runtime library path linker flag for Dynamic Erlang Drivers (set all DED_LD* variables or none)])
AC_ARG_VAR(LFS_CFLAGS, [large file support C compiler flags (set all LFS_* variables or none)])
AC_ARG_VAR(LFS_LDFLAGS, [large file support linker flags (set all LFS_* variables or none)])
AC_ARG_VAR(LFS_LIBS, [large file support libraries (set all LFS_* variables or none)])
AC_ARG_VAR(RANLIB, [ranlib])
AC_ARG_VAR(AR, [ar])
AC_ARG_VAR(GETCONF, [getconf])

dnl Cross system root
AC_ARG_VAR(erl_xcomp_sysroot, [Absolute cross system root path (only used when cross compiling)])
AC_ARG_VAR(erl_xcomp_isysroot, [Absolute cross system root include path (only used when cross compiling)])

dnl Cross compilation variables
AC_ARG_VAR(erl_xcomp_bigendian, [big endian system: yes|no (only used when cross compiling)])
AC_ARG_VAR(erl_xcomp_linux_clock_gettime_correction, [clock_gettime() can be used for time correction: yes|no (only used when cross compiling)])
AC_ARG_VAR(erl_xcomp_linux_nptl, [have Native POSIX Thread Library: yes|no (only used when cross compiling)])
AC_ARG_VAR(erl_xcomp_linux_usable_sigusrx, [SIGUSR1 and SIGUSR2 can be used: yes|no (only used when cross compiling)])
AC_ARG_VAR(erl_xcomp_linux_usable_sigaltstack, [have working sigaltstack(): yes|no (only used when cross compiling)])
AC_ARG_VAR(erl_xcomp_poll, [have working poll(): yes|no (only used when cross compiling)])
AC_ARG_VAR(erl_xcomp_kqueue, [have working kqueue(): yes|no (only used when cross compiling)])
AC_ARG_VAR(erl_xcomp_putenv_copy, [putenv() stores key-value copy: yes|no (only used when cross compiling)])
AC_ARG_VAR(erl_xcomp_reliable_fpe, [have reliable floating point exceptions: yes|no (only used when cross compiling)])
AC_ARG_VAR(erl_xcomp_getaddrinfo, [have working getaddrinfo() for both IPv4 and IPv6: yes|no (only used when cross compiling)])
AC_ARG_VAR(erl_xcomp_gethrvtime_procfs_ioctl, [have working gethrvtime() which can be used with procfs ioctl(): yes|no (only used when cross compiling)])
AC_ARG_VAR(erl_xcomp_clock_gettime_cpu_time, [clock_gettime() can be used for retrieving process CPU time: yes|no (only used when cross compiling)])
AC_ARG_VAR(erl_xcomp_after_morecore_hook, [__after_morecore_hook can track malloc()s core memory usage: yes|no (only used when cross compiling)])
AC_ARG_VAR(erl_xcomp_dlsym_brk_wrappers, [dlsym(RTLD_NEXT, _) brk wrappers can track malloc()s core memory usage: yes|no (only used when cross compiling)])

])

AC_DEFUN(ERL_XCOMP_SYSROOT_INIT,
[
erl_xcomp_without_sysroot=no
if test "$cross_compiling" = "yes"; then
    test "$erl_xcomp_sysroot" != "" || erl_xcomp_without_sysroot=yes
    test "$erl_xcomp_isysroot" != "" || erl_xcomp_isysroot="$erl_xcomp_sysroot"
else
    erl_xcomp_sysroot=
    erl_xcomp_isysroot=
fi
])

AC_DEFUN(LM_CHECK_GETCONF,
[
if test "$cross_compiling" != "yes"; then
    AC_CHECK_PROG([GETCONF], [getconf], [getconf], [false])
else
    dnl First check if we got a `<HOST>-getconf' in $PATH
    host_getconf="$host_alias-getconf"
    AC_CHECK_PROG([GETCONF], [$host_getconf], [$host_getconf], [false])
    if test "$GETCONF" = "false" && test "$erl_xcomp_sysroot" != ""; then
	dnl We should perhaps give up if we have'nt found it by now, but at
	dnl least in one Tilera MDE `getconf' under sysroot is a bourne
	dnl shell script which we can use. We try to find `<HOST>-getconf'
    	dnl or `getconf' under sysconf, but only under sysconf since
	dnl `getconf' in $PATH is almost guaranteed to be for the build
	dnl machine.
	GETCONF=
	prfx="$erl_xcomp_sysroot"
        AC_PATH_TOOL([GETCONF], [getconf], [false],
	             ["$prfx/usr/bin:$prfx/bin:$prfx/usr/local/bin"])
    fi
fi
])

dnl ----------------------------------------------------------------------
dnl
dnl LM_FIND_EMU_CC
dnl
dnl
dnl Tries fairly hard to find a C compiler that can handle jump tables.
dnl Defines the @EMU_CC@ variable for the makefiles and 
dnl inserts NO_JUMP_TABLE in the header if one cannot be found...
dnl

AC_DEFUN(LM_FIND_EMU_CC,
	[AC_CACHE_CHECK(for a compiler that handles jumptables,
			ac_cv_prog_emu_cc,
			[
AC_TRY_COMPILE([],[
    __label__ lbl1;
    __label__ lbl2;
    int x = magic();
    static void *jtab[2];

    jtab[0] = &&lbl1;
    jtab[1] = &&lbl2;
    goto *jtab[x];
lbl1:
    return 1;
lbl2:
    return 2;
],ac_cv_prog_emu_cc=$CC,ac_cv_prog_emu_cc=no)

if test $ac_cv_prog_emu_cc = no; then
	for ac_progname in emu_cc.sh gcc; do
  		IFS="${IFS= 	}"; ac_save_ifs="$IFS"; IFS=":"
  		ac_dummy="$PATH"
  		for ac_dir in $ac_dummy; do
    			test -z "$ac_dir" && ac_dir=.
    			if test -f $ac_dir/$ac_progname; then
      				ac_cv_prog_emu_cc=$ac_dir/$ac_progname
      				break
    			fi
  		done
  		IFS="$ac_save_ifs"
		if test $ac_cv_prog_emu_cc != no; then
			break
		fi
	done
fi

if test $ac_cv_prog_emu_cc != no; then
	save_CC=$CC
	save_CFLAGS=$CFLAGS
	save_CPPFLAGS=$CPPFLAGS
	CC=$ac_cv_prog_emu_cc
	CFLAGS=""
	CPPFLAGS=""
	AC_TRY_COMPILE([],[
    	__label__ lbl1;
    	__label__ lbl2;
    	int x = magic();
    	static void *jtab[2];

    	jtab[0] = &&lbl1;
    	jtab[1] = &&lbl2;
    	goto *jtab[x];
	lbl1:
    	return 1;
	lbl2:
    	return 2;
	],ac_cv_prog_emu_cc=$CC,ac_cv_prog_emu_cc=no)
	CC=$save_CC
	CFLAGS=$save_CFLAGS
	CPPFLAGS=$save_CPPFLAGS
fi
])
if test $ac_cv_prog_emu_cc = no; then
	AC_DEFINE(NO_JUMP_TABLE,[],[Defined if no found C compiler can handle jump tables])
	EMU_CC=$CC
else
	EMU_CC=$ac_cv_prog_emu_cc
fi
AC_SUBST(EMU_CC)
])		
			


dnl ----------------------------------------------------------------------
dnl
dnl LM_PROG_INSTALL_DIR
dnl
dnl This macro may be used by any OTP application.
dnl
dnl Figure out how to create directories with parents.
dnl (In my opinion INSTALL_DIR is a bad name, MKSUBDIRS or something is better)
dnl
dnl We prefer 'install -d', but use 'mkdir -p' if it exists.
dnl If none of these methods works, we give up.
dnl


AC_DEFUN(LM_PROG_INSTALL_DIR,
[AC_CACHE_CHECK(how to create a directory including parents,
ac_cv_prog_mkdir_p,
[
temp_name_base=config.$$
temp_name=$temp_name_base/x/y/z
$INSTALL -d $temp_name >/dev/null 2>&1
ac_cv_prog_mkdir_p=none
if test -d $temp_name; then
        ac_cv_prog_mkdir_p="$INSTALL -d"
else
        mkdir -p $temp_name >/dev/null 2>&1
        if test -d $temp_name; then
                ac_cv_prog_mkdir_p="mkdir -p"
        fi
fi
rm -fr $temp_name_base           
])

case "${ac_cv_prog_mkdir_p}" in
  none) AC_MSG_ERROR(don't know how create directories with parents) ;;
  *)    INSTALL_DIR="$ac_cv_prog_mkdir_p" AC_SUBST(INSTALL_DIR)     ;;
esac
])


dnl ----------------------------------------------------------------------
dnl
dnl LM_PROG_PERL5
dnl
dnl Try to find perl version 5. If found set PERL to the absolute path
dnl of the program, if not found set PERL to false.
dnl
dnl On some systems /usr/bin/perl is perl 4 and e.g.
dnl /usr/local/bin/perl is perl 5. We try to handle this case by
dnl putting a couple of 
dnl Tries to handle the case that there are two programs called perl
dnl in the path and one of them is perl 5 and the other isn't. 
dnl
AC_DEFUN(LM_PROG_PERL5,
[AC_PATH_PROGS(PERL, perl5 perl, false,
   /usr/local/bin:/opt/local/bin:/usr/local/gnu/bin:${PATH})
changequote(, )dnl
dnl[ That bracket is needed to balance the right bracket below
if test "$PERL" = "false" || $PERL -e 'exit ($] >= 5)'; then
changequote([, ])dnl
  ac_cv_path_PERL=false
  PERL=false
dnl  AC_MSG_WARN(perl version 5 not found)
fi
])dnl


dnl ----------------------------------------------------------------------
dnl
dnl LM_DECL_SO_BSDCOMPAT
dnl
dnl Check if the system has the SO_BSDCOMPAT flag on sockets (linux) 
dnl
AC_DEFUN(LM_DECL_SO_BSDCOMPAT,
[AC_CACHE_CHECK([for SO_BSDCOMPAT declaration], ac_cv_decl_so_bsdcompat,
AC_TRY_COMPILE([#include <sys/socket.h>], [int i = SO_BSDCOMPAT;],
               ac_cv_decl_so_bsdcompat=yes,
               ac_cv_decl_so_bsdcompat=no))

case "${ac_cv_decl_so_bsdcompat}" in
  "yes" ) AC_DEFINE(HAVE_SO_BSDCOMPAT,[],
		[Define if you have SO_BSDCOMPAT flag on sockets]) ;;
  * ) ;;
esac
])


dnl ----------------------------------------------------------------------
dnl
dnl LM_DECL_INADDR_LOOPBACK
dnl
dnl Try to find declaration of INADDR_LOOPBACK, if nowhere provide a default
dnl

AC_DEFUN(LM_DECL_INADDR_LOOPBACK,
[AC_CACHE_CHECK([for INADDR_LOOPBACK in netinet/in.h],
 ac_cv_decl_inaddr_loopback,
[AC_TRY_COMPILE([#include <sys/types.h>
#include <netinet/in.h>], [int i = INADDR_LOOPBACK;],
ac_cv_decl_inaddr_loopback=yes, ac_cv_decl_inaddr_loopback=no)
])

if test ${ac_cv_decl_inaddr_loopback} = no; then
  AC_CACHE_CHECK([for INADDR_LOOPBACK in rpc/types.h],
                   ac_cv_decl_inaddr_loopback_rpc,
                   AC_TRY_COMPILE([#include <rpc/types.h>],
                                   [int i = INADDR_LOOPBACK;],
                                   ac_cv_decl_inaddr_loopback_rpc=yes,
                                   ac_cv_decl_inaddr_loopback_rpc=no))

   case "${ac_cv_decl_inaddr_loopback_rpc}" in
     "yes" )
        AC_DEFINE(DEF_INADDR_LOOPBACK_IN_RPC_TYPES_H,[],
		[Define if you need to include rpc/types.h to get INADDR_LOOPBACK defined]) ;;
      * )
  	AC_CACHE_CHECK([for INADDR_LOOPBACK in winsock2.h],
                   ac_cv_decl_inaddr_loopback_winsock2,
                   AC_TRY_COMPILE([#define WIN32_LEAN_AND_MEAN
				   #include <winsock2.h>],
                                   [int i = INADDR_LOOPBACK;],
                                   ac_cv_decl_inaddr_loopback_winsock2=yes,
                                   ac_cv_decl_inaddr_loopback_winsock2=no))
	case "${ac_cv_decl_inaddr_loopback_winsock2}" in
     		"yes" )
			AC_DEFINE(DEF_INADDR_LOOPBACK_IN_WINSOCK2_H,[],
				[Define if you need to include winsock2.h to get INADDR_LOOPBACK defined]) ;;
		* )
			# couldn't find it anywhere
        		AC_DEFINE(HAVE_NO_INADDR_LOOPBACK,[],
				[Define if you don't have a definition of INADDR_LOOPBACK]) ;;
	esac;;
   esac
fi
])


dnl ----------------------------------------------------------------------
dnl
dnl LM_STRUCT_SOCKADDR_SA_LEN
dnl
dnl Check if the sockaddr structure has the field sa_len
dnl

AC_DEFUN(LM_STRUCT_SOCKADDR_SA_LEN,
[AC_CACHE_CHECK([whether struct sockaddr has sa_len field],
                ac_cv_struct_sockaddr_sa_len,
AC_TRY_COMPILE([#include <sys/types.h>
#include <sys/socket.h>], [struct sockaddr s; s.sa_len = 10;],
  ac_cv_struct_sockaddr_sa_len=yes, ac_cv_struct_sockaddr_sa_len=no))

dnl FIXME convbreak
case ${ac_cv_struct_sockaddr_sa_len} in
  "no" ) AC_DEFINE(NO_SA_LEN,[1],[Define if you dont have salen]) ;;
  *) ;;
esac
])

dnl ----------------------------------------------------------------------
dnl
dnl LM_STRUCT_EXCEPTION
dnl
dnl Check to see whether the system supports the matherr function
dnl and its associated type "struct exception".
dnl

AC_DEFUN(LM_STRUCT_EXCEPTION,
[AC_CACHE_CHECK([for struct exception (and matherr function)],
 ac_cv_struct_exception,
AC_TRY_COMPILE([#include <math.h>],
  [struct exception x; x.type = DOMAIN; x.type = SING;],
  ac_cv_struct_exception=yes, ac_cv_struct_exception=no))

case "${ac_cv_struct_exception}" in
  "yes" ) AC_DEFINE(USE_MATHERR,[1],[Define if you have matherr() function and struct exception type]) ;;
  *  ) ;;
esac
])


dnl ----------------------------------------------------------------------
dnl
dnl LM_SYS_IPV6
dnl
dnl Check for ipv6 support and what the in6_addr structure is called.
dnl (early linux used in_addr6 insted of in6_addr)
dnl

AC_DEFUN(LM_SYS_IPV6,
[AC_MSG_CHECKING(for IP version 6 support)
AC_CACHE_VAL(ac_cv_sys_ipv6_support,
[ok_so_far=yes
 AC_TRY_COMPILE([#include <sys/types.h>
#ifdef __WIN32__
#include <winsock2.h>
#include <ws2tcpip.h>
#else
#include <netinet/in.h>
#endif],
   [struct in6_addr a6; struct sockaddr_in6 s6;], ok_so_far=yes, ok_so_far=no)

if test $ok_so_far = yes; then
  ac_cv_sys_ipv6_support=yes
else
  AC_TRY_COMPILE([#include <sys/types.h>
#ifdef __WIN32__
#include <winsock2.h>
#include <ws2tcpip.h>
#else
#include <netinet/in.h>
#endif],
    [struct in_addr6 a6; struct sockaddr_in6 s6;],
    ac_cv_sys_ipv6_support=in_addr6, ac_cv_sys_ipv6_support=no)
fi
])dnl

dnl
dnl Have to use old style AC_DEFINE due to BC with old autoconf.
dnl

case ${ac_cv_sys_ipv6_support} in
  yes)
    AC_MSG_RESULT(yes)
    AC_DEFINE(HAVE_IN6,[1],[Define if ipv6 is present])
    ;;
  in_addr6)
    AC_MSG_RESULT([yes (but I am redefining in_addr6 to in6_addr)])
    AC_DEFINE(HAVE_IN6,[1],[Define if ipv6 is present])
    AC_DEFINE(HAVE_IN_ADDR6_STRUCT,[],[Early linux used in_addr6 instead of in6_addr, define if you have this])
    ;;
  *)
    AC_MSG_RESULT(no)
    ;;
esac
])


dnl ----------------------------------------------------------------------
dnl
dnl LM_SYS_MULTICAST
dnl
dnl Check for multicast support. Only checks for multicast options in
dnl setsockopt(), no check is performed that multicasting actually works.
dnl If options are found defines HAVE_MULTICAST_SUPPORT
dnl

AC_DEFUN(LM_SYS_MULTICAST,
[AC_CACHE_CHECK([for multicast support], ac_cv_sys_multicast_support,
[AC_EGREP_CPP(yes,
[#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#if defined(IP_MULTICAST_TTL) && defined(IP_MULTICAST_LOOP) && defined(IP_MULTICAST_IF) && defined(IP_ADD_MEMBERSHIP) && defined(IP_DROP_MEMBERSHIP)
yes
#endif
], ac_cv_sys_multicast_support=yes, ac_cv_sys_multicast_support=no)])
if test $ac_cv_sys_multicast_support = yes; then
  AC_DEFINE(HAVE_MULTICAST_SUPPORT,[1],
	[Define if setsockopt() accepts multicast options])
fi
])dnl


dnl ----------------------------------------------------------------------
dnl
dnl LM_DECL_SYS_ERRLIST
dnl
dnl Define SYS_ERRLIST_DECLARED if the variable sys_errlist is declared
dnl in a system header file, stdio.h or errno.h.
dnl

AC_DEFUN(LM_DECL_SYS_ERRLIST,
[AC_CACHE_CHECK([for sys_errlist declaration in stdio.h or errno.h],
  ac_cv_decl_sys_errlist,
[AC_TRY_COMPILE([#include <stdio.h>
#include <errno.h>], [char *msg = *(sys_errlist + 1);],
  ac_cv_decl_sys_errlist=yes, ac_cv_decl_sys_errlist=no)])
if test $ac_cv_decl_sys_errlist = yes; then
  AC_DEFINE(SYS_ERRLIST_DECLARED,[],
	[define if the variable sys_errlist is declared in a system header file])
fi
])


dnl ----------------------------------------------------------------------
dnl
dnl LM_CHECK_FUNC_DECL( funname, declaration [, extra includes 
dnl                     [, action-if-found [, action-if-not-found]]] )
dnl
dnl Checks if the declaration "declaration" of "funname" conflicts
dnl with the header files idea of how the function should be
dnl declared. It is useful on systems which lack prototypes and you
dnl need to provide your own (e.g. when you want to take the address
dnl of a function). The 4'th argument is expanded if conflicting, 
dnl the 5'th argument otherwise
dnl
dnl

AC_DEFUN(LM_CHECK_FUNC_DECL,
[AC_MSG_CHECKING([for conflicting declaration of $1])
AC_CACHE_VAL(ac_cv_func_decl_$1,
[AC_TRY_COMPILE([#include <stdio.h>
$3],[$2
char *c = (char *)$1;
], eval "ac_cv_func_decl_$1=no", eval "ac_cv_func_decl_$1=yes")])
if eval "test \"`echo '$ac_cv_func_decl_'$1`\" = yes"; then
  AC_MSG_RESULT(yes)
  ifelse([$4], , :, [$4])
else
  AC_MSG_RESULT(no)
ifelse([$5], , , [$5
])dnl
fi
])


dnl ----------------------------------------------------------------------
dnl
dnl LM_CHECK_THR_LIB
dnl
dnl This macro may be used by any OTP application.
dnl
dnl LM_CHECK_THR_LIB sets THR_LIBS, THR_DEFS, and THR_LIB_NAME. It also
dnl checks for some pthread headers which will appear in DEFS or config.h.
dnl

AC_DEFUN(LM_CHECK_THR_LIB,
[

NEED_NPTL_PTHREAD_H=no

dnl win32?
AC_MSG_CHECKING([for native win32 threads])
if test "X$host_os" = "Xwin32"; then
    AC_MSG_RESULT(yes)
    THR_DEFS="-DWIN32_THREADS"
    THR_LIBS=
    THR_LIB_NAME=win32_threads
    THR_LIB_TYPE=win32_threads
else
    AC_MSG_RESULT(no)
    THR_DEFS=
    THR_LIBS=
    THR_LIB_NAME=
    THR_LIB_TYPE=posix_unknown

dnl Try to find POSIX threads

dnl The usual pthread lib...
    AC_CHECK_LIB(pthread, pthread_create, THR_LIBS="-lpthread")

dnl FreeBSD has pthreads in special c library, c_r...
    if test "x$THR_LIBS" = "x"; then
	AC_CHECK_LIB(c_r, pthread_create, THR_LIBS="-lc_r")
    fi

dnl On ofs1 the '-pthread' switch should be used
    if test "x$THR_LIBS" = "x"; then
	AC_MSG_CHECKING([if the '-pthread' switch can be used])
	saved_cflags=$CFLAGS
	CFLAGS="$CFLAGS -pthread"
	AC_TRY_LINK([#include <pthread.h>],
		    pthread_create((void*)0,(void*)0,(void*)0,(void*)0);,
		    [THR_DEFS="-pthread"
		     THR_LIBS="-pthread"])
	CFLAGS=$saved_cflags
	if test "x$THR_LIBS" != "x"; then
	    AC_MSG_RESULT(yes)
	else
	    AC_MSG_RESULT(no)
	fi
    fi

    if test "x$THR_LIBS" != "x"; then
	THR_DEFS="$THR_DEFS -D_THREAD_SAFE -D_REENTRANT -DPOSIX_THREADS"
	THR_LIB_NAME=pthread
	case $host_os in
	    solaris*)
		THR_DEFS="$THR_DEFS -D_POSIX_PTHREAD_SEMANTICS" ;;
	    linux*)
		THR_DEFS="$THR_DEFS -D_POSIX_THREAD_SAFE_FUNCTIONS"

		LM_CHECK_GETCONF
		AC_MSG_CHECKING(for Native POSIX Thread Library)
		libpthr_vsn=`$GETCONF GNU_LIBPTHREAD_VERSION 2>/dev/null`
		if test $? -eq 0; then
		    case "$libpthr_vsn" in
			*nptl*|*NPTL*) nptl=yes;;
			*) nptl=no;;
		    esac
		elif test "$cross_compiling" = "yes"; then
		    case "$erl_xcomp_linux_nptl" in
			"") nptl=cross;;
			yes|no) nptl=$erl_xcomp_linux_nptl;;
			*) AC_MSG_ERROR([Bad erl_xcomp_linux_nptl value: $erl_xcomp_linux_nptl]);;
		    esac
		else
		    nptl=no
		fi
		AC_MSG_RESULT($nptl)
		if test $nptl = cross; then
		    nptl=yes
		    AC_MSG_WARN([result yes guessed because of cross compilation])
		fi
		if test $nptl = yes; then
		    THR_LIB_TYPE=posix_nptl
		    need_nptl_incldir=no
		    AC_CHECK_HEADER(nptl/pthread.h,
				    [need_nptl_incldir=yes
				     NEED_NPTL_PTHREAD_H=yes])
		    if test $need_nptl_incldir = yes; then
			# Ahh...
			nptl_path="$C_INCLUDE_PATH:$CPATH"
			if test X$cross_compiling != Xyes; then
			    nptl_path="$nptl_path:/usr/local/include:/usr/include"
			else
			    IROOT="$erl_xcomp_isysroot"
			    test "$IROOT" != "" || IROOT="$erl_xcomp_sysroot"
			    test "$IROOT" != "" || AC_MSG_ERROR([Don't know where to search for includes! Please set erl_xcomp_isysroot])
			    nptl_path="$nptl_path:$IROOT/usr/local/include:$IROOT/usr/include"
			fi
			nptl_ws_path=
			save_ifs="$IFS"; IFS=":"
			for dir in $nptl_path; do
			    if test "x$dir" != "x"; then
				nptl_ws_path="$nptl_ws_path $dir"
			    fi
			done
			IFS=$save_ifs
			nptl_incldir=
			for dir in $nptl_ws_path; do
		            AC_CHECK_HEADER($dir/nptl/pthread.h,
					    nptl_incldir=$dir/nptl)
			    if test "x$nptl_incldir" != "x"; then
				THR_DEFS="$THR_DEFS -isystem $nptl_incldir"
				break
			    fi
			done
			if test "x$nptl_incldir" = "x"; then
			    AC_MSG_ERROR(Failed to locate nptl system include directory)
			fi
		    fi
		fi
		;;
	    *) ;;
	esac

	dnl We sometimes need THR_DEFS in order to find certain headers
	dnl (at least for pthread.h on osf1).
	saved_cppflags=$CPPFLAGS
	CPPFLAGS="$CPPFLAGS $THR_DEFS"

	dnl
	dnl Check for headers
	dnl

	AC_CHECK_HEADER(pthread.h,
			AC_DEFINE(HAVE_PTHREAD_H, 1, \
[Define if you have the <pthread.h> header file.]))

	dnl Some Linuxes have <pthread/mit/pthread.h> instead of <pthread.h>
	AC_CHECK_HEADER(pthread/mit/pthread.h, \
			AC_DEFINE(HAVE_MIT_PTHREAD_H, 1, \
[Define if the pthread.h header file is in pthread/mit directory.]))

	dnl restore CPPFLAGS
	CPPFLAGS=$saved_cppflags

    fi
fi

])

AC_DEFUN(ERL_INTERNAL_LIBS,
[

ERTS_INTERNAL_X_LIBS=

AC_CHECK_LIB(kstat, kstat_open,
[AC_DEFINE(HAVE_KSTAT, 1, [Define if you have kstat])
ERTS_INTERNAL_X_LIBS="$ERTS_INTERNAL_X_LIBS -lkstat"])

AC_SUBST(ERTS_INTERNAL_X_LIBS)

])

dnl ----------------------------------------------------------------------
dnl
dnl ERL_FIND_ETHR_LIB
dnl
dnl NOTE! This macro may be changed at any time! Should *only* be used by
dnl       ERTS!
dnl
dnl Find a thread library to use. Sets ETHR_LIBS to libraries to link
dnl with, ETHR_X_LIBS to extra libraries to link with (same as ETHR_LIBS
dnl except that the ethread lib itself is not included), ETHR_DEFS to
dnl defines to compile with, ETHR_THR_LIB_BASE to the name of the
dnl thread library which the ethread library is based on, and ETHR_LIB_NAME
dnl to the name of the library where the ethread implementation is located.
dnl  ERL_FIND_ETHR_LIB currently searches for 'pthreads', and
dnl 'win32_threads'. If no thread library was found ETHR_LIBS, ETHR_X_LIBS,
dnl ETHR_DEFS, ETHR_THR_LIB_BASE, and ETHR_LIB_NAME are all set to the
dnl empty string.
dnl

AC_DEFUN(ERL_FIND_ETHR_LIB,
[

LM_CHECK_THR_LIB
ERL_INTERNAL_LIBS

ethr_have_native_atomics=no
ethr_have_native_spinlock=no
ETHR_THR_LIB_BASE="$THR_LIB_NAME"
ETHR_THR_LIB_BASE_TYPE="$THR_LIB_TYPE"
ETHR_DEFS="$THR_DEFS"
ETHR_X_LIBS="$THR_LIBS $ERTS_INTERNAL_X_LIBS"
ETHR_LIBS=
ETHR_LIB_NAME=

ethr_modified_default_stack_size=

dnl Name of lib where ethread implementation is located
ethr_lib_name=ethread

case "$THR_LIB_NAME" in

    win32_threads)
	ETHR_THR_LIB_BASE_DIR=win
	# * _WIN32_WINNT >= 0x0400 is needed for
	#   TryEnterCriticalSection
	# * _WIN32_WINNT >= 0x0403 is needed for
	#   InitializeCriticalSectionAndSpinCount
	# The ethread lib will refuse to build if _WIN32_WINNT < 0x0403.
	#
	# -D_WIN32_WINNT should have been defined in $CPPFLAGS; fetch it
	# and save it in ETHR_DEFS.
	found_win32_winnt=no
	for cppflag in $CPPFLAGS; do
	    case $cppflag in
		-DWINVER*)
		    ETHR_DEFS="$ETHR_DEFS $cppflag"
		    ;;
		-D_WIN32_WINNT*)
		    ETHR_DEFS="$ETHR_DEFS $cppflag"
		    found_win32_winnt=yes
		    ;;
		*)
		    ;;
	    esac
        done
        if test $found_win32_winnt = no; then
	    AC_MSG_ERROR([-D_WIN32_WINNT missing in CPPFLAGS])
        fi

	AC_DEFINE(ETHR_WIN32_THREADS, 1, [Define if you have win32 threads])

	have_ilckd=no
	AC_MSG_CHECKING([for _InterlockedCompareExchange64()])
	AC_TRY_LINK([
			#define WIN32_LEAN_AND_MEAN
			#include <windows.h>
		    ],
		    [
			volatile __int64 *var;
			_InterlockedCompareExchange64(var, (__int64) 1, (__int64) 0);
			return 0;
		    ],
		    have_ilckd=yes)
	AC_MSG_RESULT([$have_ilckd])
	test $have_ilckd = yes && AC_DEFINE(ETHR_HAVE__INTERLOCKEDCOMPAREEXCHANGE64, 1, [Define if you have _InterlockedCompareExchange64()])

	AC_CHECK_SIZEOF(void *)
	case "$ac_cv_sizeof_void_p-$have_ilckd" in
	    8-no)
		ethr_have_native_atomics=no
	  	ethr_have_native_spinlock=no;;
	    *)
		ethr_have_native_atomics=yes
	  	ethr_have_native_spinlock=yes;;
	esac

	have_ilckd=no
	AC_MSG_CHECKING([for _InterlockedDecrement64()])
	AC_TRY_LINK([
			#define WIN32_LEAN_AND_MEAN
			#include <windows.h>
		    ],
		    [
			volatile __int64 *var;
			_InterlockedDecrement64(var);
			return 0;
		    ],
		    have_ilckd=yes)
	AC_MSG_RESULT([$have_ilckd])
	test $have_ilckd = yes && AC_DEFINE(ETHR_HAVE__INTERLOCKEDDECREMENT64, 1, [Define if you have _InterlockedDecrement64()])

	have_ilckd=no
	AC_MSG_CHECKING([for _InterlockedIncrement64()])
	AC_TRY_LINK([
			#define WIN32_LEAN_AND_MEAN
			#include <windows.h>
		    ],
		    [
			volatile __int64 *var;
			_InterlockedIncrement64(var);
			return 0;
		    ],
		    have_ilckd=yes)
	AC_MSG_RESULT([$have_ilckd])
	test $have_ilckd = yes && AC_DEFINE(ETHR_HAVE__INTERLOCKEDINCREMENT64, 1, [Define if you have _InterlockedIncrement64()])

	have_ilckd=no
	AC_MSG_CHECKING([for _InterlockedExchangeAdd64()])
	AC_TRY_LINK([
			#define WIN32_LEAN_AND_MEAN
			#include <windows.h>
		    ],
		    [
			volatile __int64 *var;
			_InterlockedExchangeAdd64(var, (__int64) 1);
			return 0;
		    ],
		    have_ilckd=yes)
	AC_MSG_RESULT([$have_ilckd])
	test $have_ilckd = yes && AC_DEFINE(ETHR_HAVE__INTERLOCKEDEXCHANGEADD64, 1, [Define if you have _InterlockedExchangeAdd64()])

	have_ilckd=no
	AC_MSG_CHECKING([for _InterlockedExchange64()])
	AC_TRY_LINK([
			#define WIN32_LEAN_AND_MEAN
			#include <windows.h>
		    ],
		    [
			volatile __int64 *var;
			_InterlockedExchange64(var, (__int64) 1);
			return 0;
		    ],
		    have_ilckd=yes)
	AC_MSG_RESULT([$have_ilckd])
	test $have_ilckd = yes && AC_DEFINE(ETHR_HAVE__INTERLOCKEDEXCHANGE64, 1, [Define if you have _InterlockedExchange64()])

	have_ilckd=no
	AC_MSG_CHECKING([for _InterlockedAnd64()])
	AC_TRY_LINK([
			#define WIN32_LEAN_AND_MEAN
			#include <windows.h>
		    ],
		    [
			volatile __int64 *var;
			_InterlockedAnd64(var, (__int64) 1);
			return 0;
		    ],
		    have_ilckd=yes)
	AC_MSG_RESULT([$have_ilckd])
	test $have_ilckd = yes && AC_DEFINE(ETHR_HAVE__INTERLOCKEDAND64, 1, [Define if you have _InterlockedAnd64()])

	have_ilckd=no
	AC_MSG_CHECKING([for _InterlockedOr64()])
	AC_TRY_LINK([
			#define WIN32_LEAN_AND_MEAN
			#include <windows.h>
		    ],
		    [
			volatile __int64 *var;
			_InterlockedOr64(var, (__int64) 1);
			return 0;
		    ],
		    have_ilckd=yes)
	AC_MSG_RESULT([$have_ilckd])
	test $have_ilckd = yes && AC_DEFINE(ETHR_HAVE__INTERLOCKEDOR64, 1, [Define if you have _InterlockedOr64()])

	;;

    pthread)
	ETHR_THR_LIB_BASE_DIR=pthread
    	AC_DEFINE(ETHR_PTHREADS, 1, [Define if you have pthreads])
	case $host_os in
	    openbsd*)
		# The default stack size is insufficient for our needs
		# on OpenBSD. We increase it to 256 kilo words.
		ethr_modified_default_stack_size=256;;
	    linux*)
		ETHR_DEFS="$ETHR_DEFS -D_GNU_SOURCE"

		if test	X$cross_compiling = Xyes; then
		    case X$erl_xcomp_linux_usable_sigusrx in
			X) usable_sigusrx=cross;;
			Xyes|Xno) usable_sigusrx=$erl_xcomp_linux_usable_sigusrx;;
			*) AC_MSG_ERROR([Bad erl_xcomp_linux_usable_sigusrx value: $erl_xcomp_linux_usable_sigusrx]);;
		    esac
		    case X$erl_xcomp_linux_usable_sigaltstack in
			X) usable_sigaltstack=cross;;
			Xyes|Xno) usable_sigaltstack=$erl_xcomp_linux_usable_sigaltstack;;
			*) AC_MSG_ERROR([Bad erl_xcomp_linux_usable_sigaltstack value: $erl_xcomp_linux_usable_sigaltstack]);;
		    esac
		else
		    # FIXME: Test for actual problems instead of kernel versions
		    linux_kernel_vsn_=`uname -r`
		    case $linux_kernel_vsn_ in
			[[0-1]].*|2.[[0-1]]|2.[[0-1]].*)
			    usable_sigusrx=no
			    usable_sigaltstack=no;;
			2.[[2-3]]|2.[[2-3]].*)
			    usable_sigusrx=yes
			    usable_sigaltstack=no;;
		    	*)
			    usable_sigusrx=yes
			    usable_sigaltstack=yes;;
		    esac
		fi

		AC_MSG_CHECKING(if SIGUSR1 and SIGUSR2 can be used)
		AC_MSG_RESULT($usable_sigusrx)
		if test $usable_sigusrx = cross; then
		    usable_sigusrx=yes
		    AC_MSG_WARN([result yes guessed because of cross compilation])
		fi
		if test $usable_sigusrx = no; then
		    ETHR_DEFS="$ETHR_DEFS -DETHR_UNUSABLE_SIGUSRX"
		fi

		AC_MSG_CHECKING(if sigaltstack can be used)
		AC_MSG_RESULT($usable_sigaltstack)
		if test $usable_sigaltstack = cross; then
		    usable_sigaltstack=yes
		    AC_MSG_WARN([result yes guessed because of cross compilation])
		fi
		if test $usable_sigaltstack = no; then
		    ETHR_DEFS="$ETHR_DEFS -DETHR_UNUSABLE_SIGALTSTACK"
		fi
		;;
	    *) ;;
	esac

	dnl We sometimes need ETHR_DEFS in order to find certain headers
	dnl (at least for pthread.h on osf1).
	saved_cppflags="$CPPFLAGS"
	CPPFLAGS="$CPPFLAGS $ETHR_DEFS"

	dnl We need the thread library in order to find some functions
	saved_libs="$LIBS"
	LIBS="$LIBS $ETHR_X_LIBS"

	dnl
	dnl Check for headers
	dnl

	AC_CHECK_HEADER(pthread.h, \
			AC_DEFINE(ETHR_HAVE_PTHREAD_H, 1, \
[Define if you have the <pthread.h> header file.]))

	dnl Some Linuxes have <pthread/mit/pthread.h> instead of <pthread.h>
	AC_CHECK_HEADER(pthread/mit/pthread.h, \
			AC_DEFINE(ETHR_HAVE_MIT_PTHREAD_H, 1, \
[Define if the pthread.h header file is in pthread/mit directory.]))

	if test $NEED_NPTL_PTHREAD_H = yes; then
	    AC_DEFINE(ETHR_NEED_NPTL_PTHREAD_H, 1, \
[Define if you need the <nptl/pthread.h> header file.])
	fi

	AC_CHECK_HEADER(sched.h, \
			AC_DEFINE(ETHR_HAVE_SCHED_H, 1, \
[Define if you have the <sched.h> header file.]))

	AC_CHECK_HEADER(sys/time.h, \
			AC_DEFINE(ETHR_HAVE_SYS_TIME_H, 1, \
[Define if you have the <sys/time.h> header file.]))

	AC_TRY_COMPILE([#include <time.h>
			#include <sys/time.h>], 
			[struct timeval *tv; return 0;],
			AC_DEFINE(ETHR_TIME_WITH_SYS_TIME, 1, \
[Define if you can safely include both <sys/time.h> and <time.h>.]))


	dnl
	dnl Check for functions
	dnl

	AC_CHECK_FUNC(pthread_spin_lock, \
			[ethr_have_native_spinlock=yes \
			 AC_DEFINE(ETHR_HAVE_PTHREAD_SPIN_LOCK, 1, \
[Define if you have the pthread_spin_lock function.])])

	have_sched_yield=no
	have_librt_sched_yield=no
	AC_CHECK_FUNC(sched_yield, [have_sched_yield=yes])
	if test $have_sched_yield = no; then
	    AC_CHECK_LIB(rt, sched_yield,
			 [have_librt_sched_yield=yes
			  ETHR_X_LIBS="$ETHR_X_LIBS -lrt"])
	fi
	if test $have_sched_yield = yes || test $have_librt_sched_yield = yes; then
	    AC_DEFINE(ETHR_HAVE_SCHED_YIELD, 1, [Define if you have the sched_yield() function.])
	    AC_MSG_CHECKING([whether sched_yield() returns an int])
	    sched_yield_ret_int=no
	    AC_TRY_COMPILE([
				#ifdef ETHR_HAVE_SCHED_H
				#include <sched.h>
				#endif
			   ],
			   [int sched_yield();],
			   [sched_yield_ret_int=yes])
	    AC_MSG_RESULT([$sched_yield_ret_int])
	    if test $sched_yield_ret_int = yes; then
		AC_DEFINE(ETHR_SCHED_YIELD_RET_INT, 1, [Define if sched_yield() returns an int.])
	    fi
	fi

	have_pthread_yield=no
	AC_CHECK_FUNC(pthread_yield, [have_pthread_yield=yes])
	if test $have_pthread_yield = yes; then
	    AC_DEFINE(ETHR_HAVE_PTHREAD_YIELD, 1, [Define if you have the pthread_yield() function.])
	    AC_MSG_CHECKING([whether pthread_yield() returns an int])
	    pthread_yield_ret_int=no
	    AC_TRY_COMPILE([
				#if defined(ETHR_NEED_NPTL_PTHREAD_H)
				#include <nptl/pthread.h>
				#elif defined(ETHR_HAVE_MIT_PTHREAD_H)
				#include <pthread/mit/pthread.h>
				#elif defined(ETHR_HAVE_PTHREAD_H)
				#include <pthread.h>
				#endif
			   ],
			   [int pthread_yield();],
			   [pthread_yield_ret_int=yes])
	    AC_MSG_RESULT([$pthread_yield_ret_int])
	    if test $pthread_yield_ret_int = yes; then
		AC_DEFINE(ETHR_PTHREAD_YIELD_RET_INT, 1, [Define if pthread_yield() returns an int.])
	    fi
	fi

	have_pthread_rwlock_init=no
	AC_CHECK_FUNC(pthread_rwlock_init, [have_pthread_rwlock_init=yes])
	if test $have_pthread_rwlock_init = yes; then

	    ethr_have_pthread_rwlockattr_setkind_np=no
	    AC_CHECK_FUNC(pthread_rwlockattr_setkind_np,
			  [ethr_have_pthread_rwlockattr_setkind_np=yes])

	    if test $ethr_have_pthread_rwlockattr_setkind_np = yes; then
		AC_DEFINE(ETHR_HAVE_PTHREAD_RWLOCKATTR_SETKIND_NP, 1, \
[Define if you have the pthread_rwlockattr_setkind_np() function.])

		AC_MSG_CHECKING([for PTHREAD_RWLOCK_PREFER_WRITER_NONRECURSIVE_NP])
		ethr_pthread_rwlock_writer_nonrecursive_initializer_np=no
		AC_TRY_LINK([
				#if defined(ETHR_NEED_NPTL_PTHREAD_H)
				#include <nptl/pthread.h>
				#elif defined(ETHR_HAVE_MIT_PTHREAD_H)
				#include <pthread/mit/pthread.h>
				#elif defined(ETHR_HAVE_PTHREAD_H)
				#include <pthread.h>
				#endif
			    ],
			    [
				pthread_rwlockattr_t *attr;
				return pthread_rwlockattr_setkind_np(attr,
				    PTHREAD_RWLOCK_PREFER_WRITER_NONRECURSIVE_NP);
			    ],
			    [ethr_pthread_rwlock_writer_nonrecursive_initializer_np=yes])
		AC_MSG_RESULT([$ethr_pthread_rwlock_writer_nonrecursive_initializer_np])
		if test $ethr_pthread_rwlock_writer_nonrecursive_initializer_np = yes; then
		    AC_DEFINE(ETHR_HAVE_PTHREAD_RWLOCK_PREFER_WRITER_NONRECURSIVE_NP, 1, \
[Define if you have the PTHREAD_RWLOCK_PREFER_WRITER_NONRECURSIVE_NP rwlock attribute.])
		fi
	    fi
	fi

	if test "$force_pthread_rwlocks" = "yes"; then

	    AC_DEFINE(ETHR_FORCE_PTHREAD_RWLOCK, 1, \
[Define if you want to force usage of pthread rwlocks])

	    if test $have_pthread_rwlock_init = yes; then
		AC_MSG_WARN([Forced usage of pthread rwlocks. Note that this implementation may suffer from starvation issues.])
	    else
		AC_MSG_ERROR([User forced usage of pthread rwlock, but no such implementation was found])
	    fi
	fi

	AC_CHECK_FUNC(pthread_attr_setguardsize, \
			AC_DEFINE(ETHR_HAVE_PTHREAD_ATTR_SETGUARDSIZE, 1, \
[Define if you have the pthread_attr_setguardsize function.]))

	linux_futex=no
	AC_MSG_CHECKING([for Linux futexes])
	AC_TRY_LINK([
			#include <sys/syscall.h>
			#include <unistd.h>
			#include <linux/futex.h>
			#include <sys/time.h>
		    ],
		    [
			int i = 1;
			syscall(__NR_futex, (void *) &i, FUTEX_WAKE, 1,
				(void*)0,(void*)0, 0);
			syscall(__NR_futex, (void *) &i, FUTEX_WAIT, 0,
				(void*)0,(void*)0, 0);
			return 0;
		    ],
		    linux_futex=yes)
	AC_MSG_RESULT([$linux_futex])
	test $linux_futex = yes && AC_DEFINE(ETHR_HAVE_LINUX_FUTEX, 1, [Define if you have a linux futex implementation.])

	AC_MSG_CHECKING([for GCC atomic operations])
	ethr_have_gcc_atomic_ops=no
	AC_TRY_LINK([],
		    [
			long res;
			volatile long val;
			res = __sync_val_compare_and_swap(&val, (long) 1, (long) 0);
			res = __sync_add_and_fetch(&val, (long) 1);
			res = __sync_sub_and_fetch(&val, (long) 1);
			res = __sync_fetch_and_and(&val, (long) 1);
			res = __sync_fetch_and_or(&val, (long) 1);
		    ],
		    [ethr_have_native_atomics=yes
		     ethr_have_gcc_atomic_ops=yes])
	AC_MSG_RESULT([$ethr_have_gcc_atomic_ops])
	test $ethr_have_gcc_atomic_ops = yes && AC_DEFINE(ETHR_HAVE_GCC_ATOMIC_OPS, 1, [Define if you have gcc atomic operations])

	case "$host_cpu" in
	  sun4u | sparc64 | sun4v)
		ethr_have_native_atomics=yes;; 
	  i86pc | i*86 | x86_64 | amd64)
		ethr_have_native_atomics=yes;;
	  macppc | ppc | "Power Macintosh")
		ethr_have_native_atomics=yes;;
	  tile)
		ethr_have_native_atomics=yes;;
	  *)
		;;
	esac

	AC_MSG_CHECKING([for a usable libatomic_ops implementation])
	case "x$with_libatomic_ops" in
	    xno | xyes | x)
		libatomic_ops_include=
		;;
	    *)
		if test -d "${with_libatomic_ops}/include"; then
		    libatomic_ops_include="-I$with_libatomic_ops/include"
		    CPPFLAGS="$CPPFLAGS $libatomic_ops_include"
		else
		    AC_MSG_ERROR([libatomic_ops include directory $with_libatomic_ops/include not found])
		fi;;
	esac
	ethr_have_libatomic_ops=no
	AC_TRY_LINK([#include "atomic_ops.h"],
		    [
			volatile AO_t x;
			AO_t y;
			int z;

			AO_nop_full();
			AO_store(&x, (AO_t) 0);
			z = AO_load(&x);
			z = AO_compare_and_swap_full(&x, (AO_t) 0, (AO_t) 1);
		    ],
		    [ethr_have_native_atomics=yes
		     ethr_have_libatomic_ops=yes])
	AC_MSG_RESULT([$ethr_have_libatomic_ops])
	if test $ethr_have_libatomic_ops = yes; then
	    AC_CHECK_SIZEOF(AO_t, ,
			    [
				#include <stdio.h>
				#include "atomic_ops.h"
			    ])
	    AC_DEFINE_UNQUOTED(ETHR_SIZEOF_AO_T, $ac_cv_sizeof_AO_t, [Define to the size of AO_t if libatomic_ops is used])

	    AC_DEFINE(ETHR_HAVE_LIBATOMIC_OPS, 1, [Define if you have libatomic_ops atomic operations])
	    if test "x$with_libatomic_ops" != "xno" && test "x$with_libatomic_ops" != "x"; then
		AC_DEFINE(ETHR_PREFER_LIBATOMIC_OPS_NATIVE_IMPLS, 1, [Define if you prefer libatomic_ops native ethread implementations])
	    fi
	    ETHR_DEFS="$ETHR_DEFS $libatomic_ops_include"
	elif test "x$with_libatomic_ops" != "xno" && test "x$with_libatomic_ops" != "x"; then
	    AC_MSG_ERROR([No usable libatomic_ops implementation found])
	fi

	dnl Restore LIBS
	LIBS=$saved_libs
	dnl restore CPPFLAGS
	CPPFLAGS=$saved_cppflags

	;;
    *)
	;;
esac

AC_MSG_CHECKING([whether default stack size should be modified])
if test "x$ethr_modified_default_stack_size" != "x"; then
	AC_DEFINE_UNQUOTED(ETHR_MODIFIED_DEFAULT_STACK_SIZE, $ethr_modified_default_stack_size, [Define if you want to modify the default stack size])
	AC_MSG_RESULT([yes; to $ethr_modified_default_stack_size kilo words])
else
	AC_MSG_RESULT([no])
fi

if test "x$ETHR_THR_LIB_BASE" != "x"; then
	ETHR_DEFS="-DUSE_THREADS $ETHR_DEFS"
	ETHR_LIBS="-l$ethr_lib_name -lerts_internal_r $ETHR_X_LIBS"
	ETHR_LIB_NAME=$ethr_lib_name
fi

AC_CHECK_SIZEOF(void *)
AC_DEFINE_UNQUOTED(ETHR_SIZEOF_PTR, $ac_cv_sizeof_void_p, [Define to the size of pointers])

AC_CHECK_SIZEOF(int)
AC_DEFINE_UNQUOTED(ETHR_SIZEOF_INT, $ac_cv_sizeof_int, [Define to the size of int])
AC_CHECK_SIZEOF(long)
AC_DEFINE_UNQUOTED(ETHR_SIZEOF_LONG, $ac_cv_sizeof_long, [Define to the size of long])
AC_CHECK_SIZEOF(long long)
AC_DEFINE_UNQUOTED(ETHR_SIZEOF_LONG_LONG, $ac_cv_sizeof_long_long, [Define to the size of long long])
AC_CHECK_SIZEOF(__int64)
AC_DEFINE_UNQUOTED(ETHR_SIZEOF___INT64, $ac_cv_sizeof___int64, [Define to the size of __int64])


case X$erl_xcomp_bigendian in
    X) ;;
    Xyes|Xno) ac_cv_c_bigendian=$erl_xcomp_bigendian;;
    *) AC_MSG_ERROR([Bad erl_xcomp_bigendian value: $erl_xcomp_bigendian]);;
esac

AC_C_BIGENDIAN

if test "$ac_cv_c_bigendian" = "yes"; then
    AC_DEFINE(ETHR_BIGENDIAN, 1, [Define if bigendian])
fi

AC_ARG_ENABLE(native-ethr-impls,
	      AS_HELP_STRING([--disable-native-ethr-impls],
                             [disable native ethread implementations]),
[ case "$enableval" in
    no) disable_native_ethr_impls=yes ;;
    *)  disable_native_ethr_impls=no ;;
  esac ], disable_native_ethr_impls=no)

test "X$disable_native_ethr_impls" = "Xyes" &&
  AC_DEFINE(ETHR_DISABLE_NATIVE_IMPLS, 1, [Define if you want to disable native ethread implementations])

AC_ARG_ENABLE(prefer-gcc-native-ethr-impls,
	      AS_HELP_STRING([--enable-prefer-gcc-native-ethr-impls],
			     [prefer gcc native ethread implementations]),
[ case "$enableval" in
    yes) enable_prefer_gcc_native_ethr_impls=yes ;;
    *)  enable_prefer_gcc_native_ethr_impls=no ;;
  esac ], enable_prefer_gcc_native_ethr_impls=no)

test $enable_prefer_gcc_native_ethr_impls = yes &&
  AC_DEFINE(ETHR_PREFER_GCC_NATIVE_IMPLS, 1, [Define if you prefer gcc native ethread implementations])

AC_ARG_WITH(libatomic_ops,
	    AS_HELP_STRING([--with-libatomic_ops=PATH],
			   [specify and prefer usage of libatomic_ops in the ethread library]))

AC_ARG_ENABLE(ethread-pre-pentium4-compatibility,
	      AS_HELP_STRING([--enable-ethread-pre-pentium4-compatibility],
			     [enable compatibility with x86 processors before pentium 4 (back to 486) in the ethread library]),
[
  case "$enable_ethread_pre_pentium4_compatibility" in
    yes|no) ;;
    *) enable_ethread_pre_pentium4_compatibility=check;;
  esac
],
[enable_ethread_pre_pentium4_compatibility=check])

test "$cross_compiling" != "yes" || enable_ethread_pre_pentium4_compatibility=no

case "$enable_ethread_pre_pentium4_compatibility-$host_cpu" in
  check-i86pc | check-i*86)
    AC_MSG_CHECKING([whether pre pentium 4 compatibility should forced])
    AC_RUN_IFELSE([
#if defined(__GNUC__)
#  if defined(ETHR_PREFER_LIBATOMIC_OPS_NATIVE_IMPLS)
#    define CHECK_LIBATOMIC_OPS__
#  else
#    define CHECK_GCC_ASM__
#  endif
#elif defined(ETHR_HAVE_LIBATOMIC_OPS)
#  define CHECK_LIBATOMIC_OPS__
#endif
#if defined(CHECK_LIBATOMIC_OPS__)
#include "atomic_ops.h"
#endif
int main(void)
{
#if defined(CHECK_GCC_ASM__)
    __asm__ __volatile__("mfence" : : : "memory");
#elif defined(CHECK_LIBATOMIC_OPS__)
    AO_nop_full();
#endif
    return 0;
}
	],
	[enable_ethread_pre_pentium4_compatibility=no],
	[enable_ethread_pre_pentium4_compatibility=yes],
	[enable_ethread_pre_pentium4_compatibility=no])
    AC_MSG_RESULT([$enable_ethread_pre_pentium4_compatibility]);;
  *)
    ;;
esac

test $enable_ethread_pre_pentium4_compatibility = yes &&
  AC_DEFINE(ETHR_PRE_PENTIUM4_COMPAT, 1, [Define if you want compatibilty with x86 processors before pentium4.])

AC_DEFINE(ETHR_HAVE_ETHREAD_DEFINES, 1, \
[Define if you have all ethread defines])

AC_SUBST(ETHR_X_LIBS)
AC_SUBST(ETHR_LIBS)
AC_SUBST(ETHR_LIB_NAME)
AC_SUBST(ETHR_DEFS)
AC_SUBST(ETHR_THR_LIB_BASE)
AC_SUBST(ETHR_THR_LIB_BASE_DIR)

])



dnl ----------------------------------------------------------------------
dnl
dnl ERL_TIME_CORRECTION
dnl
dnl In the presence of a high resolution realtime timer Erlang can adapt
dnl its view of time relative to this timer. On solaris such a timer is
dnl available with the syscall gethrtime(). On other OS's a fallback
dnl solution using times() is implemented. (However on e.g. FreeBSD times()
dnl is implemented using gettimeofday so it doesn't make much sense to
dnl use it there...) On second thought, it seems to be safer to do it the
dnl other way around. I.e. only use times() on OS's where we know it will
dnl work...
dnl

AC_DEFUN(ERL_TIME_CORRECTION,
[if test x$ac_cv_func_gethrtime = x; then
  AC_CHECK_FUNC(gethrtime)
fi
if test x$clock_gettime_correction = xunknown; then
	AC_TRY_COMPILE([#include <time.h>],
			[struct timespec ts;
     			 long long result;
			 clock_gettime(CLOCK_MONOTONIC,&ts);
                         result = ((long long) ts.tv_sec) * 1000000000LL + 
			 ((long long) ts.tv_nsec);],
			clock_gettime_compiles=yes,
			clock_gettime_compiles=no)
else
	clock_gettime_compiles=no
fi
			

AC_CACHE_CHECK([how to correct for time adjustments], erl_cv_time_correction,
[
case $clock_gettime_correction in
    yes)
	erl_cv_time_correction=clock_gettime;;	
    no|unknown)
	case $ac_cv_func_gethrtime in
  	    yes)
    		erl_cv_time_correction=hrtime ;;
  	    no)
    		case $host_os in
        	    linux*)
			case $clock_gettime_correction in
			    unknown)
				if test x$clock_gettime_compiles = xyes; then
				    if test X$cross_compiling != Xyes; then
				    	linux_kernel_vsn_=`uname -r`
				    	case $linux_kernel_vsn_ in
					    [[0-1]].*|2.[[0-5]]|2.[[0-5]].*)
					    	erl_cv_time_correction=times ;;
					    *)
					    	erl_cv_time_correction=clock_gettime;;
				    	esac
				    else
					case X$erl_xcomp_linux_clock_gettime_correction in
					    X)
						erl_cv_time_correction=cross;;
					    Xyes|Xno)
						if test $erl_xcomp_linux_clock_gettime_correction = yes; then
						    erl_cv_time_correction=clock_gettime
						else
					    	    erl_cv_time_correction=times
						fi;;
					    *)
						AC_MSG_ERROR([Bad erl_xcomp_linux_clock_gettime_correction value: $erl_xcomp_linux_clock_gettime_correction]);;
					esac
				    fi
				else
				    erl_cv_time_correction=times
				fi
				;;
			     *)				
        			erl_cv_time_correction=times ;;
			esac
			;;
            	    *)
        		erl_cv_time_correction=none ;;
    		esac
    		;;
	esac
	;;
esac
])

xrtlib=""
case $erl_cv_time_correction in
  times)
    AC_DEFINE(CORRECT_USING_TIMES,[],
	[Define if you do not have a high-res. timer & want to use times() instead])
    ;;
  clock_gettime|cross)
    if test $erl_cv_time_correction = cross; then
	erl_cv_time_correction=clock_gettime
	AC_MSG_WARN([result clock_gettime guessed because of cross compilation])
    fi
    xrtlib="-lrt"
    AC_DEFINE(GETHRTIME_WITH_CLOCK_GETTIME,[1],
	[Define if you want to use clock_gettime to simulate gethrtime])
    ;;
esac
dnl
dnl Check if gethrvtime is working, and if to use procfs ioctl
dnl or (yet to be written) write to the procfs ctl file.
dnl

AC_MSG_CHECKING([if gethrvtime works and how to use it])
AC_TRY_RUN([
/* gethrvtime procfs ioctl test */
/* These need to be undef:ed to not break activation of
 * micro level process accounting on /proc/self 
 */
#ifdef _LARGEFILE_SOURCE
#  undef _LARGEFILE_SOURCE
#endif
#ifdef _FILE_OFFSET_BITS
#  undef _FILE_OFFSET_BITS
#endif
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/signal.h>
#include <sys/fault.h>
#include <sys/syscall.h>
#include <sys/procfs.h>
#include <fcntl.h>

int main() {
    long msacct = PR_MSACCT;
    int fd;
    long long start, stop;
    int i;
    pid_t pid = getpid();
    char proc_self[30] = "/proc/";

    sprintf(proc_self+strlen(proc_self), "%lu", (unsigned long) pid);
    if ( (fd = open(proc_self, O_WRONLY)) == -1)
	exit(1);
    if (ioctl(fd, PIOCSET, &msacct) < 0)
	exit(2);
    if (close(fd) < 0)
	exit(3);
    start = gethrvtime();
    for (i = 0; i < 100; i++)
	stop = gethrvtime();
    if (start == 0)
	exit(4);
    if (start == stop)
	exit(5);
    exit(0); return 0;
}
],
erl_gethrvtime=procfs_ioctl,
erl_gethrvtime=false,
[
case X$erl_xcomp_gethrvtime_procfs_ioctl in
    X)
	erl_gethrvtime=cross;;
    Xyes|Xno)
	if test $erl_xcomp_gethrvtime_procfs_ioctl = yes; then
	    erl_gethrvtime=procfs_ioctl
	else
	    erl_gethrvtime=false
	fi;;
    *)
	AC_MSG_ERROR([Bad erl_xcomp_gethrvtime_procfs_ioctl value: $erl_xcomp_gethrvtime_procfs_ioctl]);;
esac
])

case $erl_gethrvtime in
  procfs_ioctl)
	AC_DEFINE(HAVE_GETHRVTIME_PROCFS_IOCTL,[1],
		[define if gethrvtime() works and uses ioctl() to /proc/self])
	AC_MSG_RESULT(uses ioctl to procfs)
	;;
  *)
	if test $erl_gethrvtime = cross; then
	    erl_gethrvtime=false
	    AC_MSG_RESULT(cross)
	    AC_MSG_WARN([result 'not working' guessed because of cross compilation])
	else
	    AC_MSG_RESULT(not working)
	fi

	dnl
	dnl Check if clock_gettime (linux) is working
	dnl

	AC_MSG_CHECKING([if clock_gettime can be used to get process CPU time])
	save_libs=$LIBS
	LIBS="-lrt"
	AC_TRY_RUN([
	#include <stdlib.h>
	#include <unistd.h>
	#include <string.h>
	#include <stdio.h>
	#include <time.h>
	int main() {
	    long long start, stop;
	    int i;
	    struct timespec tp;

	    if (clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &tp) < 0)
	      exit(1);
	    start = ((long long)tp.tv_sec * 1000000000LL) + (long long)tp.tv_nsec;
	    for (i = 0; i < 100; i++)
	      clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &tp);
	    stop = ((long long)tp.tv_sec * 1000000000LL) + (long long)tp.tv_nsec;
	    if (start == 0)
	      exit(4);
	    if (start == stop)
	      exit(5);
	    exit(0); return 0;
	  }
	],
	erl_clock_gettime=yes,
	erl_clock_gettime=no,
	[
	case X$erl_xcomp_clock_gettime_cpu_time in
	    X) erl_clock_gettime=cross;;
	    Xyes|Xno) erl_clock_gettime=$erl_xcomp_clock_gettime_cpu_time;;
	    *) AC_MSG_ERROR([Bad erl_xcomp_clock_gettime_cpu_time value: $erl_xcomp_clock_gettime_cpu_time]);;
	esac
	])
	LIBS=$save_libs
	case $host_os in
		linux*)
			AC_MSG_RESULT([no; not stable])
			LIBRT=$xrtlib
			;;
		*)
			AC_MSG_RESULT($erl_clock_gettime)
			case $erl_clock_gettime in
	  			yes)
					AC_DEFINE(HAVE_CLOCK_GETTIME,[],
						  [define if clock_gettime() works for getting process time])
					LIBRT=-lrt
					;;
	  			cross)
					erl_clock_gettime=no
					AC_MSG_WARN([result no guessed because of cross compilation])
					LIBRT=$xrtlib
					;;
	  			*)
					LIBRT=$xrtlib
					;;
			esac
			;;
	esac
	AC_SUBST(LIBRT)
	;;
esac
])dnl

dnl ERL_TRY_LINK_JAVA(CLASSES, FUNCTION-BODY
dnl                   [ACTION_IF_FOUND [, ACTION-IF-NOT-FOUND]])
dnl Freely inspired by AC_TRY_LINK. (Maybe better to create a 
dnl AC_LANG_JAVA instead...)
AC_DEFUN(ERL_TRY_LINK_JAVA,
[java_link='$JAVAC conftest.java 1>&AC_FD_CC'
changequote(�, �)dnl
cat > conftest.java <<EOF
�$1�
class conftest { public static void main(String[] args) {
   �$2�
   ; return; }}
EOF
changequote([, ])dnl
if AC_TRY_EVAL(java_link) && test -s conftest.class; then
   ifelse([$3], , :, [rm -rf conftest*
   $3])
else
   echo "configure: failed program was:" 1>&AC_FD_CC
   cat conftest.java 1>&AC_FD_CC
   echo "configure: PATH was $PATH" 1>&AC_FD_CC
ifelse([$4], , , [  rm -rf conftest*
  $4
])dnl
fi
rm -f conftest*])
#define UNSAFE_MASK  0xc0000000 /* Mask for bits that must be constant */


