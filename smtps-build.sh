#!/bin/bash

x=`type docker 2> /dev/null`
if [ "x$x" = "x" ]; then
   echo "docker not installed"
else
   docker build --build-arg SERVICE=postfix -t mailservice-smtps .
fi
