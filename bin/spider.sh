#!/bin/bash

# sed -i 's/\r$//' filename
# 只需要在Master节点配置
USERS_FILE=/opt/spider/users   # 保存用户信息的文件位置
# PUBLIC_URL= http://log.tc.mybank.cn # 如果配置了nginx,需要配置此项
# master end ---------------------

# agent start --------------------
MASTER= #http://172.17.10.5:3000
# agent end ----------------------

PORT=3000
HOSTNAME=`hostname`
LOG_DIR=/opt/logs
IP=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v 172.17| grep -v inet6 | awk '{print $2}' | tr -d "addr:"`

DEBUG=false
CONTAINER_NAME=spider
OPTIONS=" -v "$LOG_DIR":/opt/logs:ro"
OPTIONS=$OPTIONS" -v /opt/applications:/opt/spider/applications:ro "
if [ $USERS_FILE ];then
  OPTIONS=$OPTIONS" -v "$USERS_FILE":/opt/spider/users "
fi
OPTIONS=$OPTIONS" -e PUBLIC_URL="$PUBLIC_URL" "
OPTIONS=$OPTIONS" -e DEBUG="$DEBUG" "
case "$1" in
    start)
        docker rm -f $name
        docker run -d -p $PORT:3000 -e PORT=$PORT -e HOSTNAME=$HOSTNAME -e IP=$IP -e MASTER=$MASTER --hostname=$HOSTNAME  $OPTIONS --name $CONTAINER_NAME spider /opt/spider/run.sh
        nohup docker logs -f $CONTAINER_NAME > ${CONTAINER_NAME}.log 2>&1 &
        tail -f ${CONTAINER_NAME}.log
        ;;

    stop)
        docker stop $CONTAINER_NAME
        echo stop success
        ;;

    restart)
        $0 stop
        sleep 2
        $0 start
        ;;

    *)
        echo "usage: $0 start|stop|restart"
        ;;

esac