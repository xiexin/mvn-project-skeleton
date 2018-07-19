#!/bin/bash

PID=`ps ax | grep -i 'abc.def' | grep java | grep -v grep | awk '{print $1}'`
if [ "x$PID" != "x" ]; then
    echo "main instance is running."
    exit 0
fi

while [ $# -gt 0 ]; do
  COMMAND=$1
  case $COMMAND in
    --config-dir)
      shift
      CONFIG_DIR=$1
      shift
      ;;
    --daemon)
      DAEMON_MODE="true"
      shift
      ;;
    --import)
      shift
      IMPORT_JOB="true"
      OPTS=$1
      shift
      ;;
    *)
      break
      ;;
  esac
done

if [ -z "$OPTS" ]; then
  OPTS=""
fi

base_dir=$(dirname $0)/..

if [ "x$CONFIG_DIR" = "x" ]; then
    CONFIG_DIR=$base_dir/config/
fi

# create logs directory
if [ "x$LOG_DIR" = "x" ]; then
    LOG_DIR="$base_dir/logs"
fi

if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR"
fi

# memory options
if [ -z "$HEAP_OPTS" ]; then
    HEAP_OPTS="-Xmx2G -Xms2G"
fi

# which java to use
if [ -z "$JAVA_HOME" ]; then
  JAVA="java"
else
  JAVA="$JAVA_HOME/bin/java"
fi

# JVM performance options
if [ -z "$JVM_PERFORMANCE_OPTS" ]; then
  JVM_PERFORMANCE_OPTS="-server -XX:+UseG1GC -XX:MaxGCPauseMillis=20"
fi

# JVM log options
if [ -z "$JVM_LOGS_OPTS" ]; then
  JVM_LOGS_OPTS="-verbose:gc -Xloggc:../logs/gc.log -XX:+PrintGCDetails"
fi

# classpath addition for release
for file in $base_dir/lib/*.jar;
do
  CLASSPATH=$CLASSPATH:$file
done

if [ "x$IMPORT_JOB" = "xtrue" ]; then
  nohup $JAVA $JVM_LOGS_OPTS $HEAP_OPTS $JVM_PERFORMANCE_OPTS -cp $CLASSPATH io.xx.dhyana.etl.HistoryQuoteDataImporter $OPTS 2>&1 < /dev/null &
elif [ "x$DAEMON_MODE" = "xtrue" ]; then
  nohup $JAVA $JVM_LOGS_OPTS $HEAP_OPTS $JVM_PERFORMANCE_OPTS -cp $CLASSPATH -DconfigDir=$CONFIG_DIR abc.def.Main $OPTS 2>&1 < /dev/null &
else
  exec $JAVA $JVM_LOGS_OPTS $HEAP_OPTS $JVM_PERFORMANCE_OPTS -cp $CLASSPATH -DconfigDir=$CONFIG_DIR abc.def.Main $OPTS &
fi

