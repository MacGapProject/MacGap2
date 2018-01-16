#!/bin/bash

NAME="$HOME/.bstack/BrowserStackLocal"
IDENTIFIER="com.browserstack.local"
LOGFILE="/tmp/bstack-local-app.log"

mkdir $HOME/.bstack 2>> $LOGFILE
PWD=`pwd`
cp $PWD/BrowserStackLocal.app/Contents/Resources/public/BrowserStackLocal $NAME 2>> $LOGFILE

LAUNCH_DAEMON_PLIST="$HOME/Library/LaunchAgents/$IDENTIFIER.plist"

echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>Label</key>
<string>'$IDENTIFIER'</string>
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
sleep 1
/bin/launchctl load "$LAUNCH_DAEMON_PLIST" 2>> $LOGFILE

STATUS=`/bin/launchctl list | /usr/bin/grep $IDENTIFIER | /usr/bin/awk '{print $3}'`
echo $STATUS >> $LOGFILE

if [ "$STATUS" = "$IDENTIFIER" ]
then
echo "App Setup Successful, Local is Running!"
exit 0
else
echo "SomeThing Went Wrong, Please try Again"
exit 1
fi

