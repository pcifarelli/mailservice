FROM amazonlinux

ARG SERVICE=all
# set the working directory
RUN mkdir /container
RUN mkdir /container/bin
RUN yum update -y && yum install -y postfix rsyslog busybox bash cyrus-sasl cyrus-sasl-lib cyrus-sasl-plain dovecot ca-certificates openldap-clients python27 python27-pip
WORKDIR /container

# copy the current directory contents to the working directory
COPY bin/setup.sh /container/bin
ADD postfix/cfg/sasl /etc/postfix/sasl
ADD postfix/cfg/certs /etc/postfix/certs
COPY postfix/cfg/drop.cidr /etc/postfix
COPY postfix/cfg/identitycheck.pcre /etc/postfix
COPY postfix/cfg/main.cf /etc/postfix
COPY postfix/cfg/master.cf /etc/postfix
COPY postfix/cfg/ldap_virtual_aliases.cf /etc/postfix
COPY postfix/cfg/ldap_virtual_recipients.cf /etc/postfix
COPY postfix/cfg/virtual_domains /etc/postfix
RUN mkdir -p /etc/sysconfig
COPY postfix/cfg/network /etc/sysconfig
COPY rsyslog/cfg/rsyslog.conf /etc
COPY bin/mailserviceentrypoint /container/bin
COPY bin/postfix.sh /container/bin
RUN chmod +x /container/bin/postfix.sh
COPY bin/rsyslog.sh /container/bin
RUN chmod +x /container/bin/rsyslog.sh
RUN mkdir -p /etc/sysconfig/
COPY saslauthd/cfg/saslauthd /etc/sysconfig/
COPY saslauthd/cfg/saslauthd.conf /etc
RUN groupadd sasl
RUN chown root:sasl /etc/saslauthd.conf
RUN chmod 640 /etc/saslauthd.conf
RUN groupmems --add postfix --group sasl
COPY bin/saslauthd.sh /container/bin
RUN chmod +x /container/bin/saslauthd.sh
COPY bin/dovecot.sh /container/bin
RUN chmod +x /container/bin/dovecot.sh
RUN postmap hash:/etc/postfix/ldap_virtual_aliases.cf
RUN postmap hash:/etc/postfix/virtual_domains
COPY dovecot/cfg/conf.d/10-auth.conf /etc/dovecot/conf.d/
COPY dovecot/cfg/conf.d/10-logging.conf /etc/dovecot/conf.d/
COPY dovecot/cfg/conf.d/10-mail.conf /etc/dovecot/conf.d/
COPY dovecot/cfg/conf.d/10-master.conf /etc/dovecot/conf.d/
COPY dovecot/cfg/conf.d/10-ssl.conf /etc/dovecot/conf.d/
COPY dovecot/cfg/conf.d/15-public-mailboxes.conf /etc/dovecot/conf.d/
COPY dovecot/cfg/dovecot.conf /etc/dovecot/
COPY dovecot/cfg/dovecot-ldap.conf.ext /etc/dovecot
RUN groupadd -g 5000 vmail
RUN useradd -u 5000 -g 5000 -d /vmail vmail
RUN update-ca-trust enable
RUN update-ca-trust extract
RUN rmdir /etc/openldap/certs
RUN ln -s /etc/pki/nssdb/ /etc/openldap/certs
RUN ln -s /etc/pki/nssdb/ /etc/openldap/cacerts
COPY openldap/ldap.conf /etc/openldap

# setup certs
ENV AWS_DEFAULT_REGION us-east-1

# "all" - start all programs
# "postfix" - run only postfix and saslauthd
# "dovecot" - run only dovecot
ENV CMDS $SERVICE
RUN mkdir -p /ssl
ADD public_certs/ /ssl/certs

RUN mkdir -p /ssl/private
COPY private/*.encrypted /ssl/private
COPY bin/load_key.py /container/bin

VOLUME ["/vmail"]
VOLUME ["/var/run"]
EXPOSE 465
EXPOSE 993

#------------------------------------------------------------------------

# set the LD_LIBRARY_PATH
ENV PATH ${PATH}:/bin
# these if you are not on an EC2 instance
#ENV AWS_ACCESS_KEY_ID <access key id>
#ENV AWS_SECRET_ACCESS_KEY <secret key>

# install packages required by the AWS C++ SDK
#RUN yum update -y && yum install -y libcurl-devel openssl-devel libuuid-devel zlib-devel
# install these for debug purposes
#RUN yum install -y busybox
#RUN yum install -y net-tools
#RUN yum install -y iputils
#RUN yum install -y python27-pip
RUN pip install --upgrade pip
RUN pip install --upgrade setuptools
RUN pip install awscli --upgrade --user
RUN pip install boto3

# need to map /ebsextra/keys -> /ssl
ENTRYPOINT ["/container/bin/mailserviceentrypoint"]
