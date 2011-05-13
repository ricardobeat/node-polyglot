express    = require 'express'
jqtpl      = require 'jqtpl'
i18n       = require 'express-voyage'

# --------------------------- # Application settings

app = express.createServer()
console.log new Date().toTimeString()

app.configure ->
	app.set 'root', __dirname
	app.set 'view engine', 'html'
	app.register '.html', jqtpl.express

	app.use express.methodOverride()
	app.use express.bodyParser()
	app.use express.cookieParser()
	app.use express.session
	    secret: 'sauce'
	app.use i18n({ debug: true })
	app.use app.router
					
	app.dynamicHelpers
		session: (req, res) ->
			return req.session
	
	app.helpers
		__: i18n.__
		n: i18n.plural
		languages: i18n.languages

app.configure 'development', ->
	i18n.updateStrings()
	app.use express.errorHandler
		dumpExceptions: true
		showStack: true
		
# --------------------------- # Default pages

# Home
app.get '/', (req, res) ->
	res.render 'index'
	
# --------------------------- # Switch languages

app.get '/lang/:lang', (req, res) ->
	i18n.setLanguage(req.session, req.params.lang)
	res.redirect req.headers.referer || '/'

app.listen(3000)