#docker run --log-driver=awslogs --log-opt awslogs-region=us-east-1 --log-opt awslogs-group=emailfetch \
docker run --log-driver=syslog --log-opt syslog-facility=mail \
 --name mailservice_imaps \
 --detach \
 -v /efs/root/vmail:/vmail \
 -p 993:993 pcifarelli/mailservice-imaps:latest
docker run --log-driver=syslog --log-opt syslog-facility=mail \
 --name mailservice_smtps \
 --link mailservice_imaps \
 --detach \
 -v /efs/root/vmail:/vmail \
 -p 465:465 pcifarelli/mailservice-smtps:latest
