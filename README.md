Polyglot
========

Polyglot is an internationalization library for [express](http://github.com/visionmedia/express). It's template-agnostic, based on JSON files, and less than 200 lines of code. Compatible with express 3+.

## Usage

Install with `npm install polyglot`:

    var i18n = require('polyglot')

    app = express()

    app.use(express.cookieParser())
    app.use(express.cookieSession())
    app.use(i18n())

    # register template locals
    app.locals(i18n.locals)

Check the [example](https://github.com/ricardobeat/node-polyglot/tree/master/example) app.

### Options

    app.use(i18n({
        debug   : false    // enable debug messages
      , default : 'en'     // default language
      , path    : '/lang'  // path for .json language files
    }))

### Language files

Translation files are `.json` files containing the translated strings. The default directory is `/lang`. To add a new language, just create an empty .json file with the language code as it's name (i.e. `de.json`).

See https://github.com/ricardobeat/node-polyglot/blob/master/example/lang/pt.json

String definitions are automatically added to all available languages by adding the `updateStrings` middleware to your express config:

    app.configure('development', function(){
        app.use(i18n.updateStrings)
    })

### Templating / locals

All the following examples are based on [handlebars](http://github.com/donpark/hbs) templates.

Registering `app.locals(i18n.locals)` is simply a shortcut for:

    app.locals({
        __        : i18n.translate
      , _n        : i18n.plural
      , languages : i18n.languages
    })

In addition to that, `i18n()` registers a middleware which sets `req.lang` and `req.locale` containing the user's settings.

See the `/example` folder for an implementation using Handlebars helpers.

#### i18n.translate

Takes a string and returns a translation based on your current session preferences (`req.session.lang`)`.

     {{ __('hello') }}
     // en: 'hello'
     // pt: 'olá'

#### i18n.plural

Takes `[n, singular, plural]` or `[n, zero, singular, plural]` arguments. Using `i18n.translate` with the same arguments will use plural automatically.

    {{ __(1, "%s cat", "%s cats") }}
    // en: '1 cat'
    // pt: '1 gato'

    {{ __(0, "no cats", "%s cat", "%s cats") }}
    // en: 'no cats'
    // pt: 'nenhum gato'

#### i18n.setLanguage

To change the current language call `i18n.setLanguage`, passing the user's session object and desired language code:

    app.get('/lang/:lang', function(req, res){
        i18n.setLanguage(req.session, req.params.lang)
        res.redirect(req.headers.referer || '/')
    })

Accessing http://yourapp/lang/de will set language to `de`, *if* it is defined in the i18n.languages object.

### Source code and tests

Polyglot is written in coffeescript and distributed in js. [Read the annotated source here](http://ricardobeat.github.com/node-polyglot).

Run tests using `mocha` or `npm test`. You need `coffee-script` and `mocha` installed globally on your machine.
