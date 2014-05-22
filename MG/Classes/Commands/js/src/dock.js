define("macgap/dock", function(require, exports, module) {
       
       
       var utils = require('macgap/utils');
       var exec = require('macgap/exec');
       var events = require('macgap/event');
       
       function Dock() {
        var initialized = false;
       }
       
       utils.extend(Dock, events);
       
       var proto = Dock.prototype;
       
       
       proto.badge = function getBadge() {
         return mg.dock.badge();
       };

       proto.setBadge = function setBadge(badge) {
         if (badge && typeof badge === 'string') {
           exec(null, null, "Dock", "setBadge", [badge]);
         }
       };
       
       module.exports = Dock;
});
