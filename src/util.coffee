module.exports = 

    extend: (obj, sources...) ->
        for source in sources
            obj[key] = val for key, val of source
        return obj

    parseJSON: (obj) ->
        try res = JSON.parse obj.toString()
        catch e then res = {}
        return res

    isValidLocale: (locale) ->
        return /^\w\w(-\w\w)?$/.test(locale)