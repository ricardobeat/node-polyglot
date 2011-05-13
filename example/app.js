(function() {
  var app, express, i18n, jqtpl;
  express = require('express');
  jqtpl = require('jqtpl');
  i18n = require('express-voyage');
  app = express.createServer();
  console.log(new Date().toTimeString());
  app.configure(function() {
    app.set('root', __dirname);
    app.set('view engine', 'html');
    app.register('.html', jqtpl.express);
    app.use(express.methodOverride());
    app.use(express.bodyParser());
    app.use(express.cookieParser());
    app.use(express.session({
      secret: 'sauce'
    }));
    app.use(i18n({
      debug: true
    }));
    app.use(app.router);
    app.dynamicHelpers({
      session: function(req, res) {
        return req.session;
      }
    });
    return app.helpers({
      __: i18n.__,
      n: i18n.plural,
      languages: i18n.languages
    });
  });
  app.configure('development', function() {
    i18n.updateStrings();
    return app.use(express.errorHandler({
      dumpExceptions: true,
      showStack: true
    }));
  });
  app.get('/', function(req, res) {
    return res.render('index');
  });
  app.get('/lang/:lang', function(req, res) {
    i18n.setLanguage(req.session, req.params.lang);
    return res.redirect(req.headers.referer || '/');
  });
  app.listen(3000);
}).call(this);
