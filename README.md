

# Notes



## Commands

All commands in the MacGap property are now capitalized except the base MacGap object, not sure if I should change this or not.


### MacGap

Properties | description
---------- | -----------
applicationPath |
resourcePath |
documentsPath |
libraryPath |
homePath |
tempPath |
idleTime |



Methods  | Arguments | description
-------- | --------- | ------------
activate | none |
terminate | none |
hide | none |
unhide | none |
beep | none |
bounce | none |
setUserAgent | string |


### MacGap.Window

Properties | description
---------- | -----------
x | current X coord
y | current Y corrd
isMaximized | 


Methods  | Arguments | description
-------- | --------- | ------------
move | (int) x, (int) y |
resize | (int) width, (int) height |
title | (string) title |
minimize | none |
maximize | none |
restore  | none |
toggleFullscreen | none |


### MacGap.Menu

Properties | description
---------- | -----------
menuItems | list of current menu's items
type | type of menu


Methods  | Arguments | description
-------- | --------- | ------------
addItem | (*object*) { label: "Title", keys: "cmd+g", index: 1, callback: function() { ... } } |
getItem | (*string*) Name OR (*int*) Index | 
addSeparator | none |
create | (string) title, (string) type | type is optional except for status bar menus, for those type must be 'statusbar'   



### MacGap.MenuItem

Properties | description
---------- | -----------
submenu | gets or sets menu items submenu



Methods  | Arguments | description
-------- | --------- | ------------
addSubmenu | (string) title | 
setKey | (string) keys | sets menu's accelerator keys
setLabel | (string) label | sets/changes menu item's label
remove | none |




### MacGap.StatusItem

Properties | description
---------- | -----------
menu | gets/sets the status items menu


Methods  | Arguments | description
-------- | --------- | ------------
createItem | (*object*) { image: "path/to/image", alternateImage: "path/to/alt/image", onClick: function() { ... } } |




### MacGap.Dialog

Methods  | Arguments | description
-------- | --------- | ------------
openDialog | (*object*) { files: true, multiple: true, directories: true, callback: function() {...} } | all params are optional and default to false
saveDialog | (*object*) { {title:"Sheet Title", prompt: "Button Text", message: "Sheet Message", filename: "myfile.txt", createDirs: true, allowedTypes: ['txt', 'doc', 'js'], callback: function(result) { console.log(result); }}} |

### MacGap.Task

Properties | description
---------- | -----------
isRunning | is task currently running, returns boolean
waitUntilExit | primarily used as a setter, see NSTask reference for what this is
arguments | set/get arguments to pass to task. Passed arguments need to be in the form of an array, i.e. task.arguments = ['arg1', 3, 'whatever'];
environment | set's the tasks environment, defaults to app's environment


Methods  | Arguments | description
-------- | --------- | ------------
create | (string) path, (func) callback | path argument is to the executable for the task
launch | none | launches task
terminate | none | kills currently running task



### MacGap.Defaults

Properties | description
---------- | -----------
defaults | get defined defaults as js object

Methods  | Arguments | description
-------- | --------- | ------------
set | (string) key, (any) value, (string) type | key and value are required, if type is omitted, the value is saved as a string.
get | (string) key, (string) type | type is optional, if not defined, will return the keys value as a string. Accepted types are: "string", "int", "bool", "float", "url", "object"



## API Usage


### Menus
	//add main menu item to a menu - everything but label is optional
	var myMenu = MacGap.Menu.addItem({label: 'My Label', index: 1 });

	//add item to newly created menu
	myMenu.addItem({label: 'My Label', keys: 'cmd+t', callback: function() { ... } });

	//add submenu to myMenu
	var sub = myMenu.addSubmenu('My Title');
    //add items
    sub.addItem({ ... });

    
more to follow
	

### StatusBar

	 //create simple status item
     MacGap.StatusItem.create({image:"path/to/image", alternateImage: "path/to/altimage"});
     
     //create status item with click callback
     MacGap.StatusItem.create({image:"path/to/image", alternateImage: "path/to/altimage", onClick: function() { ... } });

	 //Create and add a menu to the statusbar. Note that adding a menu to a status item disables any onClick events
	 // Setting the second 'type' parameter in the create method to 'statusbar' keeps MacGap from automatically adding sub-menus to the menu items you create (this is because the status items don't have a supermenu like the main menu)
	 var menu  = MacGap.Menu.create('My Menu', 'statusbar'); 

	 // add items to the menu
	 menu.addItem('My Menu Item', '', 0, function() { alert('I was clicked!'); });
	 menu.addItem('Another Menu Item', '', 1, function() { ... });

	 //add the menu to the status item
	 MacGap.StatusItem.menu = menu;


