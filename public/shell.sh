#!/bin/bash

NAME="$HOME/.bstack/BrowserStackLocal"
IDENTIFIER="com.browserstack.local"

mkdir $HOME/.bstack
PWD=`pwd`
cp $PWD/BrowserStackLocal.app/Contents/Resources/public/BrowserStackLocal $NAME

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
</plist>' > "$LAUNCH_DAEMON_PLIST"

/bin/launchctl unload "$LAUNCH_DAEMON_PLIST"
sleep 1
/bin/launchctl load "$LAUNCH_DAEMON_PLIST"

STATUS=`/bin/launchctl list | /usr/bin/grep $IDENTIFIER | /usr/bin/awk '{print $3}'`

if [ "$STATUS" = "$IDENTIFIER" ]
then
echo "App Setup Successful, Local is Running!"
exit 0
else
echo "SomeThing Went Wrong, Please try Again"
exit 1
fi

