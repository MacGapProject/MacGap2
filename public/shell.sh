#!/bin/bash

NAME="$HOME/.bstack/BrowserStackLocal"
IDENTIFIER="com.browserstack.local"
LOGFILE="/tmp/bstack-local-app.log"
BSTACK_COUNTER="/tmp/bstack-counter"

mkdir $HOME/.bstack 2>> $LOGFILE
PWD=`pwd`
echo $PWD >> $LOGFILE
## This is hard coded and will work only when we create DMG
cp /Volumes/BrowserStack/BrowserStackLocal.app/Contents/Resources/public/BrowserStackLocal $NAME 2>> $LOGFILE
# cp $PWD/BrowserStackLocal.app/Contents/Resources/public/BrowserStackLocal $NAME 2>> $LOGFILE
chmod +x $NAME 2>> $LOGFILE

LAUNCH_DAEMON_PLIST="$HOME/Library/LaunchAgents/$IDENTIFIER.plist"
echo $LAUNCH_DAEMON_PLIST >> $LOGFILE

echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>Label</key>
<string>'$IDENTIFIER'</string>
<key>KeepAlive</key>
<true/>
<key>ProgramArguments</key>
<array>
<string>'$NAME'</string>
<string>--app</string>
<string>--bs-host</string>
<string>fu.bsstag.com</string>
</array>
<key>RunAtLoad</key>
<true/>
</dict>
</plist>' > "$LAUNCH_DAEMON_PLIST" 2>> $LOGFILE

/bin/launchctl unload "$LAUNCH_DAEMON_PLIST" 2>> $LOGFILE
if [[ `cat $BSTACK_COUNTER` -gt 10 ]]
then
    echo "Cannot load binary please contact support"
    exit 1
fi
sleep 1
/bin/launchctl load "$LAUNCH_DAEMON_PLIST" 2>> $LOGFILE

STATUS=`/bin/launchctl list | /usr/bin/grep $IDENTIFIER | /usr/bin/awk '{print $3}'`
sleep 3
LOCAL_RUNNING=`ps -ef | grep 'BrowserStackLocal --app' | grep -v grep`
echo $STATUS >> $LOGFILE

if [ ! -z "$LOCAL_RUNNING" ] && [ "$STATUS" = "$IDENTIFIER" ]
then
    echo "App Setup Successful, Local is Running! Start live session from Firefox!"
    echo 0 > $BSTACK_COUNTER
    exit 0
else
    echo "Something went wrong! Trying again.."
    echo $((`cat $BSTACK_COUNTER`+1)) > $BSTACK_COUNTER
    error_log=`cat $LOGFILE | tail -10 | tr -d " \t\n\r"`
    utc_stamp=$(date -u +"%F %T.%3N UTC")
    read -d '' json_message <<EOF
{"data" : "Failed to start binary",
"error" : "$error_log",
"kind": "local-app-launch-failed",
"category" : "local",
"app_timestamp" : "$utc_stamp"}
EOF
    echo $json_message | nc -4u -w1 zombie.browserstack.com 8000
    exit 1
fi

