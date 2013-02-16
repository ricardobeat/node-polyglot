(function() {
  var __slice = [].slice;

  module.exports = {
    extend: function() {
      var key, obj, source, sources, val, _i, _len;
      obj = arguments[0], sources = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      for (_i = 0, _len = sources.length; _i < _len; _i++) {
        source = sources[_i];
        for (key in source) {
          val = source[key];
          obj[key] = val;
        }
      }
      return obj;
    },
    parseJSON: function(obj) {
      var res;
      try {
        res = JSON.parse(obj.toString());
      } catch (e) {
        res = {};
      }
      return res;
    },
    isValidLocale: function(locale) {
      return /^\w\w(-\w\w)?$/.test(locale);
    }
  };

}).call(this);
