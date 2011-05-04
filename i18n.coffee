glob  = require 'glob'
jqtpl = require 'jqtpl'

i18nStrings = {}

module.exports =
	enable: (app, opts) ->
		
		self = this
		
		#default options
		options =
			default: 'en'
			path: '/lang'
			tag: 'e'
			
		self[options.default] = true

		# override defaults
		for own key, val of opts
			options[key] = val
	
		# actual translation
		app.helpers
			_e: (str) ->
				return i18nStrings[this.session?.lang]?[str] or str

		# create custom template tag
		jqtpl.tag[options.tag] =
			open: "if($notnull_1){_.push(_e($1a));}"
		
		for lang in glob.globSync process.cwd() + options.path + "/*.{js,coffee}"
			for code, strings of require(lang)
				i18nStrings[code] = strings
				# signal available translations
				self[code] = true
	
		# sets users language
		app.use (req, res, next) ->
			# insert logic here
			if h = req.header('Accept-Language')
				languages = h.split(/,|;/g).filter (v) ->
					v?.length == 2 and i18nStrings[v] != undefined
				
			if languages.length < 1
				languages.push 'en'
				
			req.session.lang ?= languages.shift()
			next()