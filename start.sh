#!/bin/sh
PATH="/path/to/your/board/files"
cd $PATH
if [ -s /tmp/gay.pid ]; then
    kill $(cat /tmp/gay.pid)
fi
sleep 1
# use -s and -u -g if you want to use unix sockets
/usr/bin/spawn-fcgi -a 127.0.0.1 -p 9912 -P /tmp/gay.pid ./wakaba.pl
