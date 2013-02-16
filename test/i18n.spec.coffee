assert = require 'assert'
polyglot = require '../'

describe 'Parse headers', ->

    it 'should only accept valid locales', ->
        assert.equal yes, polyglot.isValidLocale value for value in ['pt', 'pt-BR', 'en', 'en-US']
        assert.equal no,  polyglot.isValidLocale value for value in ['pt-b', 'pt-', 'p', 'portugues']

    it 'should fail silently for non-strings', ->
        assert.equal no, polyglot.isValidLocale value for value in [null, undefined, 123, {}, []]

describe 'Translations', ->

    polyglot.strings.pt =
        one: 'um'
        two: 'dois'
        three: 'três'
        none: 'nenhum'
        cat: 'gato'
        cats: 'gatos'
        '%s cat': '%s gato'
        '%s cats': '%s gatos'

    polyglot.strings.jp =
        one: '一つ'
        two: '二つ'
        three: '三つ'

    it 'should translate a string to the user language', ->
        mock = { lang: 'pt' }
        assert.equal polyglot.translate.call(mock, "one"), "um"
        assert.equal polyglot.translate.call(mock, "two"), "dois"
        assert.equal polyglot.translate.call(mock, "three"), "três"

    it 'should work with special characters', ->
        mock = { lang: 'jp' }
        assert.equal polyglot.translate.call(mock, "one"), "一つ"
        assert.equal polyglot.translate.call(mock, "two"), "二つ"
        assert.equal polyglot.translate.call(mock, "three"), "三つ"

describe 'Plurals', ->

    mock = { lang: 'pt' }

    it 'should return the correct word given n, singular, plural', ->
        assert.equal polyglot.plural.call(mock, 1, 'cat', 'cats'), 'gato'
        assert.equal polyglot.plural.call(mock, 2, 'cat', 'cats'), 'gatos'
        assert.equal polyglot.plural.call(mock, 0, 'cat', 'cats'), 'gatos'

    it 'should return the correct word given n, zero, singular, plural', ->
        assert.equal polyglot.plural.call(mock, 0, 'none', 'cat', 'cats'), 'nenhum'
        assert.equal polyglot.plural.call(mock, 1, 'none', 'cat', 'cats'), 'gato'
        assert.equal polyglot.plural.call(mock, 2, 'none', 'cat', 'cats'), 'gatos'

    it 'should replace %s with numeral', ->
        assert.equal polyglot.plural.call(mock, 0, '%s cat', '%s cats'), '0 gatos'
        assert.equal polyglot.plural.call(mock, 1, '%s cat', '%s cats'), '1 gato'
        assert.equal polyglot.plural.call(mock, 2, '%s cat', '%s cats'), '2 gatos'
        assert.equal polyglot.plural.call(mock, 0, 'none', '%s cat', '%s cats'), 'nenhum'
        assert.equal polyglot.plural.call(mock, 1, 'none', '%s cat', '%s cats'), '1 gato'
        assert.equal polyglot.plural.call(mock, 2, 'none', '%s cat', '%s cats'), '2 gatos'

describe 'polyglot', ->

    it 'should be a function', ->
        assert.equal typeof polyglot, 'function'

    it 'should return a middleware function', ->
        middleware = polyglot()
        assert.equal typeof middleware, 'function'
        assert.equal middleware.length, 3
