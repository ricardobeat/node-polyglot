path   = require 'path'
fs     = require 'fs'

# Debug helper, enable with option `debug: true` when calling `i18n()`.
debug = (str) ->
	i18n.options.debug && console.log "[i18n] #{str}"

# Main method
# ------------
# Sets options, loads language files and returns an express middleware function.

i18n = (opts) ->
		
	# Options
	options = i18n.options =
		default: 'en'
		path: '/lang'
		debug: false

	for own key, val of opts
		options[key] = val
	
	i18n.languages.push options.default
	i18n.loadLanguageFiles()

	return (req, res, next) ->

		# User doesn't have a language setting yet		
		unless req.session?.lang?
			locale             = i18n.getLocale req, options
			req.session.locale = locale
			req.session.lang   = locale[0..2]
			debug "Language set to #{req.session.lang}"
				
		# Register template locals
		res.locals
			locale : req.session.locale
			lang   : req.session.lang
		
		next()

# Languages list
# ---------------
# List of active languages, excluding `i18n.options.default`.

i18n.languages = []


# Translation strings
# --------------------
# In-memory strings. They are flushed to disk using `i18n.updateStrings`.

i18n.strings = {}


# Default template locals
# ------------------------
# `lang` and `locale` are also set on a per-request basis (see middleware function).

i18n.locals = {
	__        : i18n.translate
	_n        : i18n.plural
	languages : i18n.languages
}

# Language files loader
# ----------------------
# Load `json` language files on startup.

i18n.loadLanguageFiles = ->
	dir = i18n.options.path

	if fs.existsSync(process.cwd() + dir)
		files = fs.readdirSync(process.cwd() + dir)
			.map((f) -> path.basename f, '.json')
			.filter i18n.isValidLocale
	
		for locale in files when locale isnt i18n.options.default
			filePath = path.join process.cwd(), dir, locale + '.json'
			try
				data = JSON.parse fs.readFileSync(filePath).toString()
				i18n.strings[locale] = data
				i18n.languages.push locale
				debug "loaded #{locale}.json"
			catch e
				debug "failed to load language file #{filePath}"
	else
		debug "path #{dir} doesn't exist"

# Locale validation
# ------------------
# Test if a locale is in the format `xx` or `xx-YY`.

i18n.isValidLocale = (locale) ->
	return /^\w\w(-\w\w)?$/.test locale


# Accept-Language
# ----------------
# Parses an `Accept-Language` header, adds values to the `languages` list and
# returns the preferred language.

i18n.getLocale = (req) ->
	languages = []
	acceptHeader = req.header('Accept-Language')
	if acceptHeader then languages = acceptHeader.split(/,|;/g).filter i18n.isValidLocale
			
	debug "Accepted languages: "+languages.join(', ')
		
	if languages.length < 1
		languages.push i18n.options.default
		debug "Empty Accept-Language header, reverting to default"
		
	for locale in languages when i18n.languages[locale]
		locale = locale.toLowerCase() 

	# Fallback to default
	locale or= languages[0]

	return locale


# i18n.plurals
# -------------
# Arguments can be `[n, singular, plural]` or `[n, zero, singular, plural]`.
# Is invoked by `i18n.translate` when given the correct number ofr arguments.

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
	# Handle plurals.
	# Using `apply` and `call` to keep methods in context of this request.
	if not isNaN(str) and arguments.length > 2
		return i18n.plural.apply @, arguments

	localStrings = (i18n.strings[@locale] or i18n.strings[@lang])

	# Add string to translations if missing
	localStrings && localStrings[str] ?= ''

	# Get translation
	return localStrings?[str] or str or ''


# i18n.setLanguage
# -----------------
# Change language setting for the current user.

i18n.setLanguage = (session, lang) ->
	if lang in i18n.languages
		session.lang = lang
		session.langbase = lang.substring(0,2)
		debug "Language set to #{lang}"


# i18n.updateStrings
# -------------------
# Save new strings to language files, use in development mode.

i18n.updateStrings = (req, res, next) ->
	basePath = path.join process.cwd(), i18n.options.path

	for lang, strings of i18n.strings when i18n.isValidLocale lang
		file = "#{lang}.json"
		filePath = path.join(basePath, file)
		# Re-load file and merge in-memory strings
		fs.readFile filePath, (err, res) ->
			try contents = JSON.parse res.toString()
			catch e then contents = {}
			finally
				# Update in-memory translations or add new strings
				for s, t of strings
					if contents[s] then i18n.strings[lang][s] = contents[s]
					else contents[s] = t

			fs.writeFile filePath, JSON.stringify(contents, null, 4), 'utf8'
			debug "Updated strings in #{file}"

	next()


module.exports = i18n
