path = require 'path'
fs   = require 'fs'
_    = require './util'

require 'colors'

# JSON storage
# -------------

class JSONStore

    constructor: (i18n) ->
        return new JSONStore unless this instanceof JSONStore
        @path = path.join process.cwd(), i18n.options.path
        @default = i18n.options.default
        @languages = i18n.languages

    # Update strings with translations loaded from storage.
    update: (strings) ->
        @load (err, stored = {}) =>
            _.extend strings, stored
            @save strings, (err, language) ->
                _.debug "Updated #{language} strings".blue

    # Save updated strings to disk (asynchronously).
    save: (strings, callback) ->
        for language, data of strings
            do (language) =>
                file = path.join @path, "#{language}.json"
                fs.writeFile file, JSON.stringify(data, null, 4), 'utf8', (err) -> callback err, language

    # Load language strings.
    # When updating strings, this could be simplified a lot if we loaded only the current
    # user language, but it facilitates testing - a single reload updates all language definitions.
    load: (callback) ->
        strings = {}
        if not fs.existsSync @path
            _.debug "Path '#{@path}' doesn't exist".red
            return

        files = fs.readdirSync(@path)
            .map((f) -> path.basename f, '.json')
            .filter _.isValidLocale
    
        for locale in files when locale isnt @default
            @languages.push locale unless locale in @languages
            file = path.join @path, "#{locale}.json"
            try
                strings[locale] = JSON.parse fs.readFileSync(file).toString()
                _.debug "Loaded #{locale}.json".blue
            catch e
                strings[locale] = {}
                _.debug "Failed to load file #{locale}.json".red

        callback null, strings


module.exports =
    json: JSONStore
