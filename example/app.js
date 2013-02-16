// Generated by CoffeeScript 1.4.0
(function() {
  var app, express, hbs, http, i18n, server;

  http = require('http');

  express = require('express');

  hbs = require('hbs');

  i18n = require('../i18n');

  app = express();

  server = http.createServer(app);

  hbs.registerHelper("equals", function(a, b, options) {
    if (a === b) {
      return options.fn(this);
    } else {
      return options.inverse(this);
    }
  });

  hbs.registerHelper("_", i18n.translate);

  app.configure(function() {
    app.set('root', __dirname);
    app.set('view engine', 'html');
    app.engine('html', hbs.__express);
    app.use(express.cookieParser());
    app.use(express.cookieSession({
      secret: 'trolololol'
    }));
    app.use(i18n({
      debug: true
    }));
    app.locals(i18n.locals);
    app.use(app.router);
    return app.use(express["static"]("" + __dirname + "/public"));
  });

  app.configure('development', function() {
    app.use(i18n.updateStrings);
    return app.use(express.errorHandler({
      dumpExceptions: true,
      showStack: true
    }));
  });

  app.get('/', function(req, res) {
    return res.render('index');
  });

  app.get('/clear', function(req, res) {
    req.session = null;
    return res.redirect('/');
  });

  app.get('/lang/:lang', function(req, res) {
    i18n.setLanguage(req.session, req.params.lang);
    return res.redirect(req.headers.referer || '/');
  });

  server.listen(4567);

  console.log("Server listening @ 4567");

}).call(this);
