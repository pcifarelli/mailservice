
AM_CXXFLAGS = -O2 -g -DUSE_IMPORT_EXPORT -D_GNU_SOURCE -std=c++11
AM_LDFLAGS = 

bin_PROGRAMS = mailserviceentrypoint
noinst_PROGRAMS = entrypoint$(EXEEXT)

mailserviceentrypoint_SOURCES = mailserviceentrypoint.cpp

entrypoint$(EXEEXT):	$(bin_PROGRAMS)
	cp $(bin_PROGRAMS) ../bin

