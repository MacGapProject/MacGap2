define("macgap/window", function(require, exports, module) {
       
      
      var utils = require('macgap/utils');
      var exec = require('macgap/exec');
      var events = require('macgap/event');

      function Window() {
            var initialized = false;
      }
      
      utils.extend(Window, events);

      var proto = Window.prototype;
           
      
      proto.move = function() {};
      proto.resizeTo  = function(width, height) {
            if(!width || !height) {
                  throw TypeError('resizeTo() requires both width and height parameters');
            }
            if(typeof width !== 'number' || typeof height !== 'number') {
                  throw TypeError('resizeTo() width and height parameters must be numeric');
            }

            exec(null, null, "Window", 'resize', [width, height]);
      };
      proto.minimize         = function minimize() {
            exec(null, null, "Window", 'minimize');
      };
      proto.maximize         = function maximize() {
            exec(null, null, "Window", 'maximize');
      };
      proto.isMaximized = function isMaximized() { 
            return mg.window.isMaximized(); 
      };
      proto.getX = function getX() {
          
            return mg.window.getX();
      };
      proto.getY = function getY() {
            var sb = function(data) {
                  console.log(data);
                  return data;
            };
            exec(sb, null, "Window", "getY");
      };
      proto.reload = function reload() {

      };
      proto.toggleFullscreen = function toggleFullscreen() {

      };

      proto.title = function title(title) {
            if(title && typeof title === 'string') {
                  exec(null, null, "Window", "title", [title]);
            }
      };
     
      
      
      proto._fire = function(info) {
            var event = info.event;
            var data = info.data;
    
            macgap.window.trigger(event, [data]); 
      };

      proto.onListenerChange = function() {
            
            if(!this.initialized) {
                  console.log('listenerchange');
                var self = this;
                 this.initialized = true;
                exec(self._fire, null, "Window", "addEvents");   

            }
            
      }
       // move: function() {
       
       // },
       // resize: function() {
       
       // },
       // minimize: function() {
       //      exec(null, null, "Window", 'minimize');
       // },
       // maximize: function() {
       //      exec(null, null, "Window", 'maximize');
       // },
       // isMaximized: function() {
       
       // },
       // getX: function() {
       
       // },
       // getY: function() {
       
       // },
       // reload: function() {
       
       // },
       // toggleFullscreen: function() {
       
       // },
       // title: function(title) {
       //  if(title) {
       //      exec(null, null, "Window", "title", [title]);
       //  }
       // }
    
       
       module.exports = Window;
       
});
