AUTOMAKE_OPTIONS = foreign
ACLOCAL_AMFLAGS = -I m4

SUBDIRS = src

if DOCKER

EXEDEPS = src/mailserviceentrypoint
DEPS = $(EXEDEPS)

noinst_PROGRAMS = smtpsdocker$(EXEEXT) imapsdocker$(EXEEXT)

imapsdocker$(EXEEXT):  $(DEPS)
	/bin/bash ./imaps-build.sh
	touch imapsdocker$(EXEEXT)

smtpsdocker$(EXEEXT):  $(DEPS)
	/bin/bash ./smtps-build.sh
	touch smtpsdocker$(EXEEXT)

clean-local:
	rm -f smtpsdocker$(EXEEXT)
	rm -f imapsdocker$(EXEEXT)

endif
