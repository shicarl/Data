#!/bin/sh
#By Carl: This file should place in dir of "mysqld"
#set -x

# Program Path
NUMACTL=`which numactl`
MYSQLD=/usr/local/mysql/bin/mysqld
PS=`which ps`
GREP=`which grep`
CUT=`which cut`
WC=`which wc`
EXPR=`which expr`

# Variables
CPU_BIND=(`$NUMACTL --show | $GREP nodebind | $CUT -d: -f2 `)   # CPU bins list
CPU_BIND_NUM=${#CPU_BIND[@]}    # How many CPU binds
MYSQLD_NUM=`$PS -elf | $GREP 'mysqld ' | $GREP -v grep | $WC -l`
MYSQLD_NUM=`$EXPR $MYSQLD_NUM + 1`
BIND_NO=`$EXPR $MYSQLD_NUM % $CPU_BIND_NUM ` # Calc Which CPU to Bind

# echo CMD
echo $(date +"%F %H:%M:%S")" $NUMACTL --cpunodebind=$BIND_NO --localalloc $MYSQLD" "$@"> /tmp/mysqld.$MYSQLD_NUM.$BIND_NO

# use exec to avoid having an extra shell around.
exec $NUMACTL --cpunodebind=$BIND_NO --localalloc $MYSQLD "$@"
