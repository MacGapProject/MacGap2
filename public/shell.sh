#!/bin/bash

NAME="$HOME/.bstack/BrowserStackLocal"
IDENTIFIER="com.browserstack.local"
LOGFILE="/tmp/bstack-local-app.log"
BSTACK_COUNTER="/tmp/bstack-counter"
echo 0 > $BSTACK_COUNTER

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
if [[ `cat $BSTACK_COUNTER` -gt 100 ]]
then
    echo "Cannot load binary please contact support"
    exit 1
fi
sleep 1
/bin/launchctl load "$LAUNCH_DAEMON_PLIST" 2>> $LOGFILE

STATUS=`/bin/launchctl list | /usr/bin/grep $IDENTIFIER | /usr/bin/awk '{print $3}'`
echo $STATUS >> $LOGFILE

if [ "$STATUS" = "$IDENTIFIER" ]
then
echo "App Setup Successful, Local is Running! Start live session from Firefox!"
rm $BSTACK_COUNTER
exit 0
else
echo "Something went wrong! Please trying again.."
echo
echo $((`cat $BSTACK_COUNTER`+1)) > $BSTACK_COUNTER
exit 1
fi

