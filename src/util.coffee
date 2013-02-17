debugMode = off

util = 
    extend: (obj, sources...) ->
        for source in sources
            for key, val of source
                if typeof val is 'object' and typeof obj[key] is 'object'
                    util.extend obj[key], val
                else
                    obj[key] = val
        return obj

    parseJSON: (obj) ->
        try res = JSON.parse obj.toString()
        catch e then res = {}
        return res

    isValidLocale: (locale) ->
        # http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.10
        return /^\w{1,2}(-\w+)*$/.test(locale)

    debug: (str) ->
        debugMode && console.log "[i18n] #{str}"

    toggleDebug: (status) ->
        debugMode = status

module.exports = util