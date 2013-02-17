var http    = require('http')
  , express = require('express')
  , hbs     = require('hbs')
  , i18n    = require('../')

// Application settings
// ---------------------

var app    = express()
  , server = http.createServer(app)

hbs.registerHelper("equals", function (a, b, options) {
  return a == b ? options.fn(this) : options.inverse(this)
})

// Register handlebar translation method
hbs.registerHelper("_", i18n.translate)

app.configure(function(){
  app.set('root', __dirname)
  app.set('view engine', 'html')
  app.engine('html', hbs.__express)

  app.use(express.cookieParser())
  app.use(express.cookieSession({ secret: 'trolololol' }))

  app.use(i18n({ debug: true }))
  app.locals(i18n.locals)

  app.use(app.router)
  app.use(express.static(__dirname + "/public"))
})

app.configure('development', function(){
  app.use(i18n.updateStrings)
  app.use(express.errorHandler({
      dumpExceptions: true
    , showStack: true
  }))
})
    
// Routes
// -------

app.get('/', function (req, res) {
  res.render('index')
})
  
// Set language
app.get('/lang/:lang', function (req, res) {
  i18n.setLanguage(req.session, req.params.lang)
  res.redirect(req.headers.referer || '/')
})

server.listen(4567)
console.log("Server listening @ 4567")
