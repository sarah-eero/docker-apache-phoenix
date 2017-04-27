#!/bin/bash


: ${HADOOP_PREFIX:=/usr/local/hadoop}
: ${ZOO_HOME:=/usr/local/zookeeper}
: ${HBASE_HOME:=/usr/local/hbase}
: ${PHOENIX_HOME:=/usr/local/phoenix}

if [[ $1 == "-stop" ]]; then
	$HADOOP_PREFIX/sbin/stop-dfs.sh
	$HADOOP_PREFIX/sbin/stop-yarn.sh
	$ZOO_HOME/bin/zkServer.sh stop
	$HBASE_HOME/bin/stop-hbase.sh
	$PHOENIX_HOME/bin/queryserver.py stop
else
	rm /tmp/*.pid

	$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

	# installing libraries if any - (resource urls added comma separated to the ACP system variable)
	cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

	sed s/HOSTNAME/$HOSTNAME/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml

	service sshd start

	$HADOOP_PREFIX/sbin/start-dfs.sh
	$HADOOP_PREFIX/sbin/start-yarn.sh
	$ZOO_HOME/bin/zkServer.sh start
	$HBASE_HOME/bin/start-hbase.sh

	if [[ $1 == "-d" ]]; then
	  while true; do sleep 1000; done
	fi

	if [[ $1 == "-bash" ]]; then
	  /bin/bash
	fi

	if [[ $1 == "-sqlline" ]]; then
	  $PHOENIX_HOME/bin/sqlline-thin.py localhost
	fi

	if [[ $1 == "-qs" ]]; then
	  echo "Starting queryserver"
	  $PHOENIX_HOME/bin/queryserver.py
	fi
fi
