docker run --log-driver=syslog --log-opt syslog-facility=mail --detach \
 -v /ebsextra/keys:/ssl:rw \
 -v /efs/root/vmail:/vmail \
 -p 465:465 -p 993:993 pcifarelli/mailservice:latest
