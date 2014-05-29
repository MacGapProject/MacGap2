

# Notes



## API Usage


### Menus
	//add main menu item to a menu - everything but label is optional
	var myMenu = macgap.Menu.addItem({label: 'My Label', index: 1 });

	//add item to newly created menu
	myMenu.addItem({label: 'My Label', keys: 'cmd+t', callback: function() { ... } });

	//add submenu to myMenu
	var sub = myMenu.addSubmenu('My Title');
    //add items
    sub.addItem({ ... });

    
more to follow
	

### StatusBar

	 //create simple status item
     macgap.StatusItem.create({image:"path/to/image", alternateImage: "path/to/altimage"});
     
     //create status item with click callback
     macgap.StatusItem.create({image:"path/to/image", alternateImage: "path/to/altimage", onClick: function() { ... } });

	 //Create and add a menu to the statusbar. Note that adding a menu to a status item disables any onClick events
	 // Setting the second 'type' parameter in the create method to 'statusbar' keeps MacGap from automatically adding sub-menus to the menu items you create (this is because the status items don't have a supermenu like the main menu)
	 var menu  = macgap.Menu.create('My Menu', 'statusbar'); 

	 // add items to the menu
	 menu.addItem('My Menu Item', '', 0, function() { alert('I was clicked!'); });
	 menu.addItem('Another Menu Item', '', 1, function() { ... });

	 //add the menu to the status item
	 macgap.StatusItem.menu = menu;


