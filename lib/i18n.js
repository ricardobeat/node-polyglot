(function() {
  var fs, i18n, path, store, _,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  path = require('path');

  fs = require('fs');

  _ = require('./util');

  store = require('./store');

  i18n = function(options) {
    i18n.options = options = _.extend({
      "default": 'en',
      path: '/lang',
      debug: false,
      store: 'json'
    }, options);
    _.toggleDebug(options.debug);
    i18n.store = new store[options.store](i18n);
    i18n.languages.push(options["default"]);
    i18n.loadLanguageFiles();
    return function(req, res, next) {
      var _ref;
      if (req.path === '/favicon.ico') {
        return next();
      }
      if (((_ref = req.session) != null ? _ref.lang : void 0) == null) {
        i18n.setLanguage(req.session, i18n.getLocale(req));
        _.debug("Language set to " + req.session.lang);
      }
      res.locals({
        locale: req.session.locale,
        lang: req.session.lang
      });
      return next();
    };
  };

  i18n.languages = [];

  i18n.strings = {};

  i18n.locals = {
    __: i18n.translate,
    _n: i18n.plural,
    languages: i18n.languages
  };

  i18n.plural = function(str, zero, one, more) {
    var word, _ref;
    if (typeof more !== 'string') {
      _ref = [zero, one, one], one = _ref[0], more = _ref[1], zero = _ref[2];
    }
    word = (function() {
      switch (true) {
        case str === 0:
          return zero;
        case str === 1:
          return one;
        case str > 1:
          return more;
      }
    })();
    return i18n.translate.call(this, word).replace(/%s/g, str);
  };

  i18n.translate = function(str) {
    var localStrings, _ref;
    if (!isNaN(str) && arguments.length > 2) {
      return i18n.plural.apply(this, arguments);
    }
    if (localStrings = i18n.strings[this.lang]) {
      if ((_ref = localStrings[str]) == null) {
        localStrings[str] = '';
      }
      return localStrings[str] || str;
    } else {
      return str || '';
    }
  };

  i18n.setLanguage = function(session, locale) {
    var lang;
    lang = locale.split('-')[0];
    if (session != null) {
      session.lang = (function() {
        switch (true) {
          case __indexOf.call(i18n.languages, locale) >= 0:
            return locale;
          case __indexOf.call(i18n.languages, lang) >= 0:
            return lang;
          default:
            return i18n.options["default"];
        }
      })();
    }
    return _.debug("Language set to " + (session != null ? session.lang : void 0));
  };

  i18n.loadLanguageFiles = function() {
    var _this = this;
    return this.store.load(function(err, strings) {
      return _.extend(_this.strings, strings);
    });
  };

  i18n.getLocale = function(req) {
    var lang, locale, _i, _len, _ref;
    _ref = req.acceptedLanguages;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      lang = _ref[_i];
      if (i18n.languages[locale] != null) {
        locale = lang;
      }
    }
    return (locale || i18n.options["default"]).toLowerCase();
  };

  i18n.updateStrings = function(req, res, next) {
    i18n.store.update(i18n.strings);
    return next();
  };

  module.exports = i18n;

}).call(this);
