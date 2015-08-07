Polyglot
========

Polyglot is an internationalization library for [express](http://github.com/visionmedia/express). It's template-agnostic, based on JSON files, dependency-free and less than 200 lines of code. Compatible with express 3+.

## Usage

Install with `npm install polyglot`:

    var i18n = require('polyglot')

    app = express()

    app.use(express.cookieParser())
    app.use(express.cookieSession())

    app.use(i18n())         # add middleware
    app.locals(i18n.locals) # register template locals

Check the [example](https://github.com/ricardobeat/node-polyglot/tree/master/example) app.

### Options

    app.use(i18n({
        debug   : false    // enable debug messages
      , default : 'en'     // default language
      , path    : '/lang'  // path for .json language files
    }))

### Storage engines and language files

By default polyglot uses a JSON storage backend for translations, saving files to `options.path` (default: /lang). To add a new language, just create an empty .json file with the language code as it's name (e.g. `de.json` or 'en-UK.json'). These files can be sent to apps like [webtranslateit.com](http://webtranslateit.com) for management and collaborative translation efforts.

See [example/lang/pt.json](https://github.com/ricardobeat/node-polyglot/blob/master/example/lang/pt.json) for a sample.

### String collection / auto-updating

String definitions are automatically added to all available languages by using the `updateStrings` middleware:

    app.configure('development', function(){
        app.use(i18n.updateStrings)
    })

Different storage backends (MongoDB, Redis) can be used by adding a constructor to `i18n.store` and setting the `store` option:

    function MongoStore () { ... }

    i18n.store.mongo = MongoStore

    //...
    app.use(i18n({
        store: 'mongo'
    }))

This object must implement the `load`, `save` and `update` methods, and will receive the `i18n` object as first argument on initialization. See the source for the JSON storage engine at [src/store.coffee](https://github.com/ricardobeat/node-polyglot/blob/master/src/store.coffee).

### Templating / locals

Registering `app.locals(i18n.locals)` is a shortcut for:

    app.locals({
        __        : i18n.translate
      , _n        : i18n.plural
      , languages : i18n.languages
    })

In addition to these locals, the `i18n()` middleware sets the `req.lang` and `req.locale` properties containing user settings.

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

When accessing `http://yourapp.com/lang/de` the language will be set to `de`, *if* it's in the available languages (`i18n.languages`) list.

### Source code and tests

Polyglot is written in coffeescript and distributed in js. [Read the annotated source here](http://ricardobeat.github.com/node-polyglot).

Run tests using `mocha` or `npm test`. You need `coffee-script` and `mocha` installed globally on your machine.

### Roadmap

- implement simple default backends for MongoDB/Redis/LevelDB
- example of serving a string map to a client-side app
- tiny library implementing `translate` and `plural` on the client, bundled with the string map and served socket.io-style at `/polyglot/client.js`
- support different pluralization rules
