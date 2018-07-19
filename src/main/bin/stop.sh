#!/bin/bash
ps ax | grep -i 'abc.def' | grep java | grep -v grep | awk '{print $1}' | xargs kill -SIGTERM