define("macgap", function(require, exports, module) {
var MacGap = {
    define:define,
    require:require,
	version: '2.0',
	callbackId: Math.floor(Math.random() * 2000000000),
    callbacks:  {},
    callbackStatus: {
        NO_RESULT: 0,
        OK: 1,
        CLASS_NOT_FOUND_EXCEPTION: 2,
        ILLEGAL_ACCESS_EXCEPTION: 3,
        INSTANTIATION_EXCEPTION: 4,
        MALFORMED_URL_EXCEPTION: 5,
        IO_EXCEPTION: 6,
        INVALID_ACTION: 7,
        JSON_EXCEPTION: 8,
        ERROR: 9
    },

    callbackFromNative: function(callbackId, success, status, args, keepCallback) {
        var callback = macgap.callbacks[callbackId];
        if (callback) {
            if (success && status == macgap.callbackStatus.OK) {
                callback.success && callback.success.apply(null, args);
            } else if (!success) {
                callback.fail && callback.fail.apply(null, args);
            }

            // Clear callback if not expecting any more results
            if (!keepCallback) {
                delete macgap.callbacks[callbackId];
            }
        }
    }

};

module.exports = MacGap;
});

