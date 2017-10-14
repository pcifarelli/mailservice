#docker run --log-driver=syslog --log-opt syslog-facility=mail --detach \
docker run --log-driver=awslogs --log-opt awslogs-region=us-east-1 --log-opt awslogs-group=emailfetch --detach \
 -v /efs/root/vmail:/vmail \
 -p 465:465 -p 993:993 pcifarelli/mailservice:latest
