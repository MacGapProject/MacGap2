This rewrite focuses primarily on making the API much cleaner, easier to use, as well as more powerful than the current implementation. The current api is very verbose and since it uses the WebScriptObject, is limited in terms of what arguments and data can be passed back and forth between contexts, and each command/plugin currently implements it's own way of managing this handoff of data. The new api uses a centralized approach with a specific structure so that commands only need to worry about what data they are receiving and sending, and what events they want to trigger. The command delegate and command queue, paired with the window controller, manage the actual data handoff, parsing and validation, and simply pass a command object to the plugin class to use. The command object contains all of the data sent from JS, (excluding the actual callbacks since those are kept in a queue on the JS side, only a referenced "callbackID" is passed to obj-c so the plugin can tell the command delegate which callback to fire when it's done processing the command).

## A breakdown of the structure and changes:

**Config.json** - This is the starting point for initial configuration of the app, it's similar to how node-webkit and atom-shell work. You define your app parameters and they are configured on startup. This avoids having to wait until the window is loaded to adjust the window position or set dimensions, etc via js. This is also where you configure what plugins should be available to the app. Currently, the format for registering a plugin is {"Plugin Name" : "Class Name"}, this may or may not be changed. Since the classnames have no prefixes currently it looks a little awkward but if outside plugins are added this may come in handy.

**Macgap.js** - This is the user facing API. This script is injected into the web view on startup and is available as a global window object. Registered modules can be required directly if need be by using 'var mycommand = macgap.require('macgap/pluginname');', just like a node module. Plugins are defined and required either by the macgap object or by the developer themselves. While the entire api is exposed, only plugins that have been enabled in config.json will accept commands from the js side. For non essential api commands, or commands that aren't likely to be used by every application, it's best to structure the plugin js to work like an independent instantiated object. Take dock badges for example, while they are defined in the macgap namespace, there really isn't a need to add them to the Macgap object and instantiated them. Instead we could just interact like this:

    var Badge = macgap.require('macgap/badge');

    var myBadge = new Badge();
    //or
    var myBadge = new Badge('string');
    //or
    var myBadge = new Badge({ param : value });

OR if we wanted to keep it encapsulated within the macgap object, we could just do this:

    var myBadge = new macgap.badge();
    //or
    var myBadge = new macgap.badge({…});
etc..

Ideally, plugins should be structured so that setters/actions are the only thing talking to Obj-c, properties of objects should be obtained upon instantiation or through events sent by Obj-c. For example, lets take the window object, this is likely to be one of the only objects that would be instantiated by macgap on startup and exist throughout the app's lifecycle. So, the js object could have properties like height, width, x, y etc that are populated when the object is instantiated, the user could then just interact with the object like so:

     var appWindow = macgap.window;

     var xPos = appWindow.x;
     var yPos = appWindow.y;

The plugin would then send events to the window object with updated params anytime the window is moved/resized/hidden etc.


**CommandQueue** - this class receives all commands from the js object via the WebViewDelegate class. It then grabs the actual params/data from the js side and stages those commands into a queue. It then loops through the queue, validates that the plugin is allowed via the CommandDelegate and if so, calls the appropriate selector in the Plugin class.

**CommandDelegate** - this class handles communication back from Plugins to the js side, sending back a PluginResult object.

Plugins send results back to js via the CommandDelegate like so:

      PluginResult* result = [PluginResult resultWithStatus:CommandStatus_OK messageAsDictionary: paramsToSendBack ];
      [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];





## Executing commands from js

All actions/commands sent from the js side, use the exec() function. It's syntax is as follows:

     exec(SuccessCallback, ErrorCallback, "PluginClass", "method", [ args ]);

The success and error callbacks are not actually sent to obj-c, they are stored on the js side and only a 'callbackId' is sent to the plugins. The plugins use this id when sending back information so that the js side knows what callbacks to trigger. If no success or error callbacks are needed, null should be passed for both. The Plugin class and method are both required, but the params/arguments to send are optional. If used, all arguments must wrapped in an array, like so:

      exec(null, null, "Plugin", "method", ['string', 2, { key: value}]);


