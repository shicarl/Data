#!/bin/bash
#
# mysqlN	This shell script takes care of starting and stopping
#		the MySQL subsystem (mysqld).
#
# chkconfig: - 64 36
# description:	MySQL database server.
# processname: mysqld

# Source function library.
. /etc/rc.d/init.d/functions

# Source networking configuration.
. /etc/sysconfig/network

# Attention! Modify here!
prog="MySQL"
number=${N}
defaults_file="/etc/my${N}.cnf"
socketfile="/tmp/mysql${N}.sock"
mypidfile="/db/data${N}/${HOST}_${N}db.pid"
mysql_bin_path="/usr/local/mysql/bin"

start(){
	# Pass all the options by defaults-file
	${mysql_bin_path}/mysqld_safe   --defaults-file="$defaults_file" --user=mysql  --mysqld=numa_mysql_startup.sh --open-files-limit=102400 >/dev/null 2>&1 &
	ret=$?
	# Spin for a maximum of N seconds waiting for the server to come up.
	# Rather than assuming we know a valid username, accept an "access
	# denied" response as meaning the server is functioning.
	if [ $ret -eq 0 ]; then
	    STARTTIMEOUT=30
	    while [ $STARTTIMEOUT -gt 0 ]; do
		RESPONSE=`${mysql_bin_path}/mysqladmin --socket="$socketfile" --user=UNKNOWN_MYSQL_USER ping 2>&1` && break
		echo "$RESPONSE" | grep -q "Access denied for user" && break
		sleep 1
		let STARTTIMEOUT=${STARTTIMEOUT}-1
	    done
	    if [ $STARTTIMEOUT -eq 0 ]; then
                    echo "Timeout error occurred trying to start MySQL Daemon."
                    action $"Starting $prog: " /bin/false
                    ret=1
            else
                    action $"Starting $prog: " /bin/true
            fi
	else
    	    action $"Starting $prog: " /bin/false
	fi
	return $ret
}

stop(){
        MYSQLPID=`cat "$mypidfile"  2>/dev/null `
        if [ -n "$MYSQLPID" ]; then
            /bin/kill "$MYSQLPID" >/dev/null 2>&1
            ret=$?
            if [ $ret -eq 0 ]; then
                STOPTIMEOUT=60
                while [ $STOPTIMEOUT -gt 0 ]; do
                    /bin/kill -0 "$MYSQLPID" >/dev/null 2>&1 || break
                    sleep 1
                    let STOPTIMEOUT=${STOPTIMEOUT}-1
                done
                if [ $STOPTIMEOUT -eq 0 ]; then
                    echo "Timeout error occurred trying to stop MySQL Daemon."
                    ret=1
                    action $"Stopping $prog: " /bin/false
                else
                    action $"Stopping $prog: " /bin/true
                fi
            else
                action $"Stopping $prog: " /bin/false
            fi
        else
            ret=1
            action $"Stopping $prog: " /bin/false
        fi
        return $ret
}
 
restart(){
    stop
    start
}

status(){
    if [ -f "${mypidfile}" ]
    then 
        pid=`cat ${mypidfile}`
        num=`echo $(pidof mysqld) | grep "${pid}" | wc -l`
        if [ "${num}x" = "1x" ]
        then 
            echo "Server ${number} is running,pid:${pid}"
        else
            echo "Server ${number} stopped, but pidfile exists."
        fi
    else
        echo "Server ${number} stopped."
    fi
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
    status
    ;;
  restart)
    restart
    ;;
  *)
    echo $"Usage: $0 {start|stop|status|restart}"
    exit 1
esac

exit $?
