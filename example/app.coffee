http    = require 'http'
express = require 'express'
hbs     = require 'hbs'
i18n    = require '../'

# Application settings
# ---------------------

app    = express()
server = http.createServer(app)

hbs.registerHelper "equals", (a, b, options) ->
	return if a == b then options.fn(@) else options.inverse(@)

hbs.registerHelper "_", i18n.translate

app.configure ->
	app.set 'root', __dirname
	app.set 'view engine', 'html'
	app.engine 'html', hbs.__express

	app.use express.cookieParser()
	app.use express.cookieSession secret: 'trolololol'
	app.use i18n({ debug: true })
	app.locals i18n.locals
	app.use app.router
	app.use express.static "#{__dirname}/public"

app.configure 'development', ->
	app.use i18n.updateStrings
	app.use express.errorHandler
		dumpExceptions: true
		showStack: true
		
# Default pages
# --------------

# Home
app.get '/', (req, res) ->
	res.render 'index'

app.get '/clear', (req, res) ->
	req.session = null
	res.redirect '/'
	
# Switch languages
# -----------------

app.get '/lang/:lang', (req, res) ->
	i18n.setLanguage req.session, req.params.lang
	res.redirect req.headers.referer || '/'

server.listen 4567
console.log "Server listening @ 4567"
