define("macgap/exec", function(require, exports, module) {
/**
 * Creates a gap bridge iframe used to notify the native code about queued
 * commands.
 */
var utils = require('macgap/utils'),
    base64 = require('macgap/base64'),
    execIframe,
    requestCount = 0,
    commandQueue = [], // Contains pending JS->Native messages.
    isInContextOfEvalJs = 0;

function createExecIframe() {
    var iframe = document.createElement("iframe");
    iframe.style.display = 'none';
    document.documentElement.appendChild(iframe);
    return iframe;
}


function Exec() {

    var callbackId = null,
        successCallback = arguments[0],
        failCallback = arguments[1], 
        service = arguments[2], 
        action = arguments[3], 
        actionArgs = arguments[4], 
        splitCommand;
   
    // If actionArgs is not provided, default to an empty array
    actionArgs = actionArgs || [];

    // Register the callbacks and add the callbackId to the positional
    // arguments if given.
    if (successCallback || failCallback) {
        callbackId = service + macgap.callbackId++;
        macgap.callbacks[callbackId] =
            {   
                success:successCallback, 
                fail:failCallback
            };
    }
 
    var command = [callbackId, service, action, actionArgs];

    // Stringify and queue the command. We stringify to command now to
    // effectively clone the command arguments in case they are mutated before
    // the command is executed.
    commandQueue.push(JSON.stringify(command));

    // If we're in the context of a stringByEvaluatingJavaScriptFromString call,
    // then the queue will be flushed when it returns; no need to send.
    // Also, if there is already a command in the queue, then we've already
    // poked the native side, so there is no reason to do so again.
    if (!isInContextOfEvalJs && commandQueue.length == 1) {
  
            sendToNative();
    }
}


function sendToNative() {
    if (!document.body) {
        setTimeout(sendToNative);
        return;
    }

    execIframe = execIframe || createExecIframe();

    if (!execIframe.contentWindow) {
      execIframe = createExecIframe();
    }
    execIframe.src = "mg://ready";
}



Exec.nativeFetchMessages = function() {
    // Each entry in commandQueue is a JSON string already.
    if (!commandQueue.length) {
        return '';
    }
    var json = '[' + commandQueue.join(',') + ']';
    commandQueue.length = 0;
    return json;
};

Exec.nativeCallback = function(callbackId, status, message, keepCallback) {
    return Exec.nativeEvalAndFetch(function() {
        var success = status === 0 || status === 1;
        var args = [];

       args.push(message); 
       macgap.callbackFromNative(callbackId, success, status, args, keepCallback);
    });
};

Exec.nativeEvalAndFetch = function(func) {
    // This shouldn't be nested, but better to be safe.
    isInContextOfEvalJs++;
    try {
        func();
        return Exec.nativeFetchMessages();
    } finally {
        isInContextOfEvalJs--;
    }
};

module.exports = Exec;
});
