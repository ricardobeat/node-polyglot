path   = require 'path'
fs     = require 'fs'

devStrings = {}
	
debug = (str) ->
	i18n.options.debug && console.log "[i18n] #{str}"

i18n = (opts) ->
		
	#default options
	options = i18n.options =
		default: 'en'
		path: '/lang'
		views: '/views'
		debug: false

	# override defaults
	for own key, val of opts
		options[key] = val
	
	# flag language existence	
	i18n.languages[options.default] = true

	if path.existsSync(process.cwd() + options.path)
		
		files = fs.readdirSync( process.cwd() + options.path ).filter (file) ->
			# accept either pt-BR.json or pt.json
			return /\w{2}(-\w{2})?\.json$/.test file
	
		# load language files
		for file in files
			[country, lang] = file.match /^(\w{2})(-\w{2})?/
			try
				data = JSON.parse fs.readFileSync( process.cwd() + options.path + '/' + file, 'utf8')
				lang = lang.toLowerCase()
				i18n.strings[lang] = data
				if lang != country then i18n.strings[country.toLowerCase()] = data
				i18n.languages[lang] = true
				debug "loaded #{file}"
			catch e
				debug "failed to load language file #{file}"
	else
		debug "path #{options.path} doesn't exist"

	# sets users language
	return (req, res, next) ->
	
		if req.session?.lang?
			debug "current language: #{req.session.lang}"
			next()
			return
	
		acceptHeader = req.header('Accept-Language')

		if acceptHeader
			languages = acceptHeader.split(/,|;/g).filter (v) ->
				/^\w{2}(-\w{2})?$/.test v
				
		debug "accepted languages: "+languages.join(', ')
			
		if not languages or languages.length < 1
			languages = [i18n.options.default]
			debug "empty Accept-Language header, reverting to default"
			
		for lang in languages
			lang = lang.toLowerCase()
			if i18n.languages[lang] and req.session?
				req.session.lang = lang.toLowerCase()
				req.session.langbase = lang.toLowerCase().substring(0,2)
				
		# default to EN
		if req.session? and not req.session.lang?
			req.session.lang = i18n.options.default
			req.session.langbase = i18n.options.default
		
		next()
		
# keep track of active languages
i18n.languages = {}
i18n.strings   = {}

# where the real thing happens
i18n.__ = (str) ->
	return i18n.strings[@session.lang]?[str] or i18n.strings[@session.langbase]?[str] or str
	
n_replace = (str, n) ->
	return str.replace /%s/g, n
	
# ([zero], single, plural, n)
i18n.plural = (zero, single, plural, _n) ->
	if not _n?
		_n = n = plural 
		if n > 1 then n = 1
		else if n < 2 then n = 0
	else
		n = _n
		if n > 2 then n = 2
		else if n < 1 then n = 0
	
	return n_replace arguments[n], _n
	
i18n.setLanguage = (session, lang) ->
	if i18n.languages[lang]
		session.lang = lang
		session.langbase = lang.substring(0,2)
				
collectStrings = (contents, fn) ->
	pattern = new RegExp ///
	#{fn}\(              # opening parenthesis
	(["'])               # opening quote
	((?:(?!\1)[^\\]|\\.)*) # string
	\1                   # closing quote
	\)                   # closing parenthesis
	///g
	
	strings = []
	
	while m = pattern.exec contents
		if m[2] and m[2].length > 1
			strings.push m[2]
	
	return strings

# parse views for __
i18n.updateStrings = (fn) ->

	fn ?= '__'

	viewsPath = process.cwd() + i18n.options.views

	if not path.existsSync(viewsPath)
		debug "no views found in #{viewsPath}"
		return
		
	views = fs.readdirSync(viewsPath).filter (file) ->
		return /\w+.(htm|html|ejs|tpl)$/.test file
	
	for view in views
		debug "collecting strings from #{view}"
		contents = fs.readFileSync("#{viewsPath}/#{view}").toString()
		for string in collectStrings(contents, fn)
			devStrings[string] = 1

	files = fs.readdirSync( process.cwd() + i18n.options.path ).filter (file) ->
		debug "loading language file #{file}"
		# accept either pt-BR.json or pt.json
		return /\w{2}(-\w{2})?\.json$/.test file
		
	for file in files
		
		# TODO: check modification date to avoid unnecessary updates
		filePath = process.cwd() + i18n.options.path + '/' + file
		try
			strings = JSON.parse fs.readFileSync(filePath, 'utf8')
		catch e
			strings = {}
		
		# add new strings
		for s, v of devStrings
			if not strings[s]?
				strings[s] = ""
				
		for string, translation of strings
			if not devStrings[string]
				delete strings[string]
		
		fs.writeFileSync(filePath, JSON.stringify(strings, null, "\t"), 'utf8')
		debug "updated strings in #{file}"

module.exports = i18n
