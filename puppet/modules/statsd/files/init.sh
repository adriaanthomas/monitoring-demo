#!/bin/bash
#
# StatsD
#
# chkconfig: 3 50 50
# description: StatsD init.d
. /etc/rc.d/init.d/functions

prog=statsd
STATSDDIR=/opt/statsd
statsd="node $STATSDDIR/stats.js"
LOG=/var/log/statsd.log
ERRLOG=/var/log/statsderr.log
CONFFILE=${STATSDDIR}/local.js
pidfile=/var/run/statsd.pid
lockfile=/var/lock/subsys/statsd
RETVAL=0
STOP_TIMEOUT=${STOP_TIMEOUT-10}

start() {
	echo -n $"Starting $prog: "
	cd ${STATSDDIR}

	# See if it's already running. Look *only* at the pid file.
	if [ -f ${pidfile} ]; then
		failure "PID file exists for statsd"
		RETVAL=1
	else
		# Run as process
		${statsd} ${CONFFILE} >> ${LOG} 2>> ${ERRLOG} &
		RETVAL=$?
	
		# Store PID
		echo $! > ${pidfile}

		# Success
		[ $RETVAL = 0 ] && success "statsd started"
	fi

	echo
	return $RETVAL
}

stop() {
	echo -n $"Stopping $prog: "
	killproc -p ${pidfile}
	RETVAL=$?
	echo
	[ $RETVAL = 0 ] && rm -f ${pidfile}
}

# See how we were called.
case "$1" in
  start)
	start
	;;
  stop)
	stop
	;;
  status)
	status -p ${pidfile} ${prog}
	RETVAL=$?
	;;
  restart)
	stop
	start
	;;
  condrestart)
	if [ -f ${pidfile} ] ; then
		stop
		start
	fi
	;;
  *)
	echo $"Usage: $prog {start|stop|restart|condrestart|status}"
	exit 1
esac

exit $RETVAL
