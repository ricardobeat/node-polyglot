path   = require 'path'
fs     = require 'fs'

_     = require './util'
store = require './store'

# Polyglot
# ---------

i18n = (options) ->
		
	# Options
	i18n.options = options = _.extend {
		default: 'en'
		path: '/lang'
		debug: false
		store: 'json'
	}, options

	_.toggleDebug(options.debug)

	# Instantiate storage engine
	i18n.store = new store[options.store] i18n
	
	i18n.languages.push options.default
	i18n.loadLanguageFiles()

	return (req, res, next) ->

		return next() if req.path is '/favicon.ico'

		# User doesn't have a language setting yet		
		unless req.session?.lang?
			i18n.setLanguage req.session, i18n.getLocale req
			_.debug "Language set to #{req.session.lang}"
				
		# Register template locals
		res.locals
			locale : req.session.locale
			lang   : req.session.lang
		
		next()


# List of active languages.
i18n.languages = []

# In-memory translations. Updated and flushed to disk when using `i18n.updateStrings`.
i18n.strings = {}

# Default template locals. `lang` and `locale` are also set
# for each request (see middleware function).
i18n.locals = {
	__        : i18n.translate
	_n        : i18n.plural
	languages : i18n.languages
}


# i18n.plurals
# -------------
# Arguments can be `[n, singular, plural]` or `[n, zero, singular, plural]`.
# Is invoked by `i18n.translate` when given the correct arguments.

i18n.plural = (str, zero, one, more) ->
	if typeof more isnt 'string' then [one, more, zero] = [zero, one, one]
	word = switch true
		when str is 0 then zero
		when str is 1 then one
		when str  > 1 then more
	return i18n.translate.call(@, word).replace /%s/g, str


# i18n.translate
# ---------------
# This is the method used as a template local, usually aliased to '_'.

i18n.translate = (str) ->
	# Handle plurals, keep methods in context of this request.
	if not isNaN(str) and arguments.length > 2
		return i18n.plural.apply @, arguments

	if localStrings = i18n.strings[@lang]
		localStrings[str] ?= '' # Add string to translations if missing
		return localStrings[str] or str
	else
		return str or ''


# ### .setLanguage()
# Change language setting for the current user.

i18n.setLanguage = (session, locale) ->
	lang = locale.split('-')[0]

	session?.lang = switch true
		when locale in i18n.languages then locale
		when lang   in i18n.languages then lang
		else i18n.options.default

	_.debug "Language set to #{session?.lang}"


# ### .loadLanguageFiles()
# Load language definitions on startup.

i18n.loadLanguageFiles = ->
	@store.load (err, strings) =>
		_.extend @strings, strings


# ### .getLocale()
# Returns the preferred accepted language for which a translation exists.

i18n.getLocale = (req) ->
	locale = lang for lang in req.acceptedLanguages when i18n.languages[locale]?
	return (locale or i18n.options.default).toLowerCase()

# ### .updateStrings()
# Use in development mode.
# Refreshes string files and adds new strings on every page load.

i18n.updateStrings = (req, res, next) ->
	i18n.store.update(i18n.strings)
	next()


module.exports = i18n
