(function() {
  var JSONStore, fs, path, _,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  path = require('path');

  fs = require('fs');

  _ = require('./util');

  require('colors');

  JSONStore = (function() {

    function JSONStore(i18n) {
      if (!(this instanceof JSONStore)) {
        return new JSONStore;
      }
      this.path = path.join(process.cwd(), i18n.options.path);
      this["default"] = i18n.options["default"];
      this.languages = i18n.languages;
    }

    JSONStore.prototype.update = function(strings) {
      var _this = this;
      return this.load(function(err, stored) {
        if (stored == null) {
          stored = {};
        }
        _.extend(strings, stored);
        return _this.save(strings, function(err, language) {
          return _.debug(("Updated " + language + " strings").blue);
        });
      });
    };

    JSONStore.prototype.save = function(strings, callback) {
      var data, language, _results,
        _this = this;
      _results = [];
      for (language in strings) {
        data = strings[language];
        _results.push((function(language) {
          var file;
          file = path.join(_this.path, "" + language + ".json");
          return fs.writeFile(file, JSON.stringify(data, null, 4), 'utf8', function(err) {
            return callback(err, language);
          });
        })(language));
      }
      return _results;
    };

    JSONStore.prototype.load = function(callback) {
      var file, files, locale, strings, _i, _len;
      strings = {};
      if (!fs.existsSync(this.path)) {
        _.debug(("Path '" + this.path + "' doesn't exist").red);
        return;
      }
      files = fs.readdirSync(this.path).map(function(f) {
        return path.basename(f, '.json');
      }).filter(_.isValidLocale);
      for (_i = 0, _len = files.length; _i < _len; _i++) {
        locale = files[_i];
        if (!(locale !== this["default"])) {
          continue;
        }
        if (__indexOf.call(this.languages, locale) < 0) {
          this.languages.push(locale);
        }
        file = path.join(this.path, "" + locale + ".json");
        try {
          strings[locale] = JSON.parse(fs.readFileSync(file).toString());
          _.debug(("Loaded " + locale + ".json").blue);
        } catch (e) {
          strings[locale] = {};
          _.debug(("Failed to load file " + locale + ".json").red);
        }
      }
      return callback(null, strings);
    };

    return JSONStore;

  })();

  module.exports = {
    json: JSONStore
  };

}).call(this);
