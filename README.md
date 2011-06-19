Internationalization for express.js
====================================

## Installing

    npm install polyglot

## How to use

Require it in your app:

    var i18n = require('polyglot')

Add to your express config:

    app.use( i18n() )

debug mode:

	app.use( i18n({ debug: true }) )
	
Expose helpers:

    app.helpers({
        __: i18n.translate
      , languages: i18n.languages
      , n: i18n.plural // optional
    })

### Language files

Translation files are simply .json files, where strings are mapped 1 to 1. By default it looks for these files in `/lang`. To add a new language, just create an empty .json file with the language code as it's name (i.e. `de.json`).

### Templating

This example uses [jquery-templates](http://github.com/kof/node-jqtpl), 

    <p>${ __("string to be translated") }</p>

The `translate()` function takes a string and returns a translation based on your current session preferences (`req.session.lang`)`.

### Plurals

You can optionally expose the `i18n.plural` function.

    app.helpers({
        _n: i18n.plural
    })
    
It takes 3 or 4 arguments: `[none], single, plural, n_items`, each a translatable string, and returns the corresponding one:

    <p>${ _n(__("no items"),__("1 item"),__("%s items"), items.length) }</p>
    <p>${ _n(__("%s item"),__("%s items"), number) }</p>

It also works for untranslated strings:

    <p>${ _n("%s item","%s items", 2) }</p>

## Options

    i18n({
        default: 'en'   // default language
      , path:  '/lang'   // path to language files
      , views: '/views' // path to view files (for automatic updates)
      , debug: false    // enable debug mode
    })

## String collection

express-voyage can update your language files automatically, just add this to your app.config (recommended only during development):

    app.configure('development', function(){
       i18n.updateStrings()
    })

(more info about development mode in the [express guide](http://express.js.com/guide))

## Language switching

To change the current language call `i18n.setLanguage`, passing the user's session object and desired language code:

    app.get('/lang/:lang', function(req, res){
        i18n.setLanguage(req.session, req.params.lang)
        res.redirect(req.headers.referer || '/')
    })

Now accessing http://yourapp/lang/de will set language to `de`, in case it exists within the i18n.languages object.


