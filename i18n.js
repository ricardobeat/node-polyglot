(function() {
  var collectStrings, debug, devStrings, fs, i18n, n_replace, path,
    __hasProp = Object.prototype.hasOwnProperty;

  path = require('path');

  fs = require('fs');

  devStrings = {};

  debug = function(str) {
    return i18n.options.debug && console.log("[i18n] " + str);
  };

  i18n = function(opts) {
    var country, data, file, files, key, lang, options, val, _i, _len, _ref;
    options = i18n.options = {
      "default": 'en',
      path: '/lang',
      views: '/views',
      debug: false
    };
    for (key in opts) {
      if (!__hasProp.call(opts, key)) continue;
      val = opts[key];
      options[key] = val;
    }
    i18n.languages.push(options["default"]);
    if (path.existsSync(process.cwd() + options.path)) {
      files = fs.readdirSync(process.cwd() + options.path).filter(function(file) {
        return /\w{2}(-\w\w)?\.json$/.test(file);
      });
      for (_i = 0, _len = files.length; _i < _len; _i++) {
        file = files[_i];
        _ref = file.match(/^(\w{2})(-\w\w)?/), country = _ref[0], lang = _ref[1];
        try {
          data = JSON.parse(fs.readFileSync(process.cwd() + options.path + '/' + file, 'utf8'));
          lang = lang.toLowerCase();
          i18n.strings[lang] = data;
          if (lang !== country) i18n.strings[country.toLowerCase()] = data;
          i18n.languages.push(lang);
          debug("loaded " + file);
        } catch (e) {
          debug("failed to load language file " + file);
        }
      }
    } else {
      debug("path " + options.path + " doesn't exist");
    }
    return function(req, res, next) {
      var acceptHeader, lang, languages, _j, _len2, _ref2;
      if (((_ref2 = req.session) != null ? _ref2.lang : void 0) != null) {
        return next();
      }
      acceptHeader = req.header('Accept-Language');
      if (acceptHeader) {
        languages = acceptHeader.split(/,|;/g).filter(function(v) {
          return /^\w{2}(-\w\w)?$/.test(v);
        });
      }
      if (languages == null) languages = [];
      debug("accepted languages: " + languages.join(', '));
      if (languages.length < 1) {
        languages.push(i18n.options["default"]);
        debug("empty Accept-Language header, reverting to default");
      }
      for (_j = 0, _len2 = languages.length; _j < _len2; _j++) {
        lang = languages[_j];
        lang = lang.toLowerCase();
        if (i18n.languages[lang] && (req.session != null)) {
          req.session.lang = lang.toLowerCase();
          req.session.langbase = lang.toLowerCase().substring(0, 2);
        }
      }
      if ((req.session != null) && !(req.session.lang != null)) {
        req.session.lang = i18n.options["default"];
        req.session.langbase = i18n.options["default"];
      }
      debug("language set to " + lang);
      return next();
    };
  };

  i18n.languages = [];

  i18n.strings = {};

  i18n.translate = function(str) {
    var _ref, _ref2, _ref3, _ref4;
    return ((_ref = i18n.strings[(_ref2 = this.session) != null ? _ref2.lang : void 0]) != null ? _ref[str] : void 0) || ((_ref3 = i18n.strings[(_ref4 = this.session) != null ? _ref4.langbase : void 0]) != null ? _ref3[str] : void 0) || str;
  };

  n_replace = function(str, n) {
    return str.replace(/%s/g, n);
  };

  i18n.plural = function(zero, single, plural, _n) {
    var n;
    if (!(_n != null)) {
      _n = n = plural;
      if (n > 1) {
        n = 1;
      } else if (n < 2) {
        n = 0;
      }
    } else {
      n = _n;
      if (n > 2) {
        n = 2;
      } else if (n < 1) {
        n = 0;
      }
    }
    return n_replace(arguments[n], _n);
  };

  i18n.setLanguage = function(session, lang) {
    if (i18n.languages[lang]) {
      session.lang = lang;
      return session.langbase = lang.substring(0, 2);
    }
  };

  collectStrings = function(contents, fn) {
    var m, pattern, strings;
    pattern = new RegExp(RegExp("" + fn + "\\(([\"'])((?:(?!\\1)[^\\\\]|\\\\.)*)\\1\\)", "g"));
    strings = [];
    while (m = pattern.exec(contents)) {
      if (m[2] && m[2].length > 1) strings.push(m[2]);
    }
    return strings;
  };

  i18n.updateStrings = function(fn) {
    var contents, file, filePath, files, s, string, strings, translation, v, view, views, viewsPath, _i, _j, _k, _len, _len2, _len3, _ref, _results;
    if (fn == null) fn = '__';
    viewsPath = process.cwd() + i18n.options.views;
    if (!path.existsSync(viewsPath)) {
      debug("no views found in " + viewsPath);
      return;
    }
    views = fs.readdirSync(viewsPath).filter(function(file) {
      return /\w+\.(htm|html|ejs|tpl)$/.test(file);
    });
    for (_i = 0, _len = views.length; _i < _len; _i++) {
      view = views[_i];
      debug("collecting strings from " + view);
      contents = fs.readFileSync("" + viewsPath + "/" + view).toString();
      _ref = collectStrings(contents, fn);
      for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
        string = _ref[_j];
        devStrings[string] = 1;
      }
    }
    files = fs.readdirSync(process.cwd() + i18n.options.path).filter(function(file) {
      if (/^\w{2}([-_]\w\w)?\.json$/.test(file)) {
        debug("loading language file " + file);
        return true;
      } else {
        return false;
      }
    });
    _results = [];
    for (_k = 0, _len3 = files.length; _k < _len3; _k++) {
      file = files[_k];
      filePath = process.cwd() + i18n.options.path + '/' + file;
      try {
        contents = fs.readFileSync(filePath, 'utf8');
        strings = JSON.parse(contents);
        fs.writeFileSync(filePath + '.backup', contents, 'utf8');
      } catch (e) {
        strings = {};
      }
      for (s in devStrings) {
        v = devStrings[s];
        if (!(strings[s] != null)) strings[s] = "";
      }
      for (string in strings) {
        translation = strings[string];
        if (!devStrings[string]) delete strings[string];
      }
      fs.writeFileSync(filePath, JSON.stringify(strings, null, "\t"), 'utf8');
      _results.push(debug("updated strings in " + file));
    }
    return _results;
  };

  module.exports = i18n;

}).call(this);
