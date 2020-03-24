#!/bin/sh

set -e

# Extract the base64 encoded config data and write this to the KUBECONFIG
echo "$KUBE_CONFIG_DATA" | base64 --decode > /tmp/config
export KUBECONFIG=/tmp/config

#reload script

GW1=`kubectl get pods -n $NAMESPACE |grep nginx|awk '{print $1}'| head -1 |cut -d " " -f1`
GW2=`kubectl get pods -n $NAMESPACE |grep nginx|awk '{print $1}'| tail -1 |cut -d " " -f1`
OK1=$(kubectl exec $GW1 -n $NAMESPACE -- /usr/sbin/nginx -t )
if [ $? = 0 ]; then
   kubectl exec $GW1 -n $NAMESPACE -- /usr/sbin/nginx -s reload
else
   echo config not working
   exit 1
fi
OK2=$(kubectl exec $GW2 -n $NAMESPACE -- /usr/sbin/nginx -t)
if [ $? = 0 ]; then
   kubectl exec $GW2 -n $NAMESPACE -- /usr/sbin/nginx -s reload
else
   echo config not working
   exit 1
fi

