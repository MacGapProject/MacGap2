var macgap = require('macgap');
var win = require('macgap/window');
macgap.window = new win();
macgap.menu = require('macgap/menu');
macgap.menuItem = require('macgap/menuitem');

window.macgap = macgap;

})();