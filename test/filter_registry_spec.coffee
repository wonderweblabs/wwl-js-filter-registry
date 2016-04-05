expect  = require('chai').expect
jsdom   = require('mocha-jsdom')

describe 'filter_registry', ->

  Registry = require('../lib/filter_registry')

  # ------------------------------------------------------------------
  describe '#get', ->

    r = null

    beforeEach ->
      r = new Registry()
      r.register 'test1', { test: 1 }, null, { a: 1 }
      r.register 'test2', { test: 2 }, null, { a: 1 }
      r.register 'test3', { test: 3 }, null, { a: 2 }
      r.whitelistEntry 'test1'
      r.whitelistEntry 'test2'
      r.whitelistEntry 'test3'

    it 'should return array entries', ->
      arr = r.get('something')
      expect(arr.length).to.eql(3)

    it 'should return array with entry data for each', ->
      arr = r.get('something')
      expect(arr[0].data.test).to.eql(1)
      expect(arr[1].data.test).to.eql(2)
      expect(arr[2].data.test).to.eql(3)

    it 'should return array with filter data for each', ->
      arr = r.get('something')
      expect(arr[0].filters).to.eql([])
      expect(arr[1].filters).to.eql([])
      expect(arr[2].filters).to.eql([])

    it 'should return array with options data for each', ->
      arr = r.get('something')
      expect(arr[0].options.a).to.eql(1)
      expect(arr[1].options.a).to.eql(1)
      expect(arr[2].options.a).to.eql(2)

  # ------------------------------------------------------------------
  describe '#register', ->

    r = null

    beforeEach ->
      r = new Registry()

    it 'should add entry', ->
      expect(r.get('something').length).to.eql(0)
      r.register('test1', { test: 1 })
      r.whitelistEntry 'test1'
      expect(r.get('something').length).to.eql(1)

    it 'should update entry for adding twice', ->
      expect(r.get('something').length).to.eql(0)
      r.register('test1', { test: 1 })
      r.register('test1', { test: 2 })
      r.whitelistEntry 'test1'
      expect(r.get('something').length).to.eql(1)
      expect(r.get('something')[0].data.test).to.eql(2)

    it 'should not whitelist by default', ->
      expect(r.get('something').length).to.eql(0)
      r.register('test1', { test: 1 })
      expect(r.get('something').length).to.eql(0)

  # ------------------------------------------------------------------
  describe '#unregister', ->

    r = null

    beforeEach ->
      r = new Registry()

    it 'should not fail for not existing entry', ->
      expect(-> r.unregister('test1')).to.not.throw()

    it 'should remove entry', ->
      expect(r.get('something').length).to.eql(0)
      r.register('test1', { test: 1 })
      r.whitelistEntry 'test1'
      expect(r.get('something').length).to.eql(1)
      r.unregister('test1')
      expect(r.get('something').length).to.eql(0)

  # ------------------------------------------------------------------
  describe '#isWhitelisted', ->

    r = null

    beforeEach ->
      r = new Registry()

      r.register('test1', { })
      r.register('test2', { })
      r.register('test3', { })
      r.register('test4', { })
      r.register('test5', { })
      r.register('test6', { })

      r.whitelistEntry 'test1'
      r.whitelistEntry 'test2', 'some'
      r.whitelistEntry 'test3', 'some/scope'
      r.whitelistEntry 'test4', /^some\/.*/
      r.whitelistEntry 'test5', /^some$/

    describe 'for test1 *', ->
      it 'should pass all tests with true', ->
        expect(r.isWhitelisted('test1', '')).to.be.true
        expect(r.isWhitelisted('test1', 's')).to.be.true
        expect(r.isWhitelisted('test1', 'some')).to.be.true
        expect(r.isWhitelisted('test1', 'some/')).to.be.true
        expect(r.isWhitelisted('test1', 'some/scope')).to.be.true
        expect(r.isWhitelisted('test1', 'other')).to.be.true

    describe 'for test2 some', ->
      it 'should pass all tests with true', ->
        expect(r.isWhitelisted('test2', 'some')).to.be.true
      it 'should pass all tests with false', ->
        expect(r.isWhitelisted('test2', '')).to.be.false
        expect(r.isWhitelisted('test2', 's')).to.be.false
        expect(r.isWhitelisted('test2', 'some/')).to.be.false
        expect(r.isWhitelisted('test2', 'some/scope')).to.be.false
        expect(r.isWhitelisted('test2', 'other')).to.be.false

    describe 'for test3 some/scope', ->
      it 'should pass all tests with true', ->
        expect(r.isWhitelisted('test3', 'some/scope')).to.be.true
      it 'should pass all tests with false', ->
        expect(r.isWhitelisted('test3', '')).to.be.false
        expect(r.isWhitelisted('test3', 's')).to.be.false
        expect(r.isWhitelisted('test3', 'some/')).to.be.false
        expect(r.isWhitelisted('test3', 'some')).to.be.false
        expect(r.isWhitelisted('test3', 'other')).to.be.false

    describe 'for test4 /^some\\/.*/', ->
      it 'should pass all tests with true', ->
        expect(r.isWhitelisted('test4', 'some/')).to.be.true
        expect(r.isWhitelisted('test4', 'some/scope')).to.be.true
      it 'should pass all tests with false', ->
        expect(r.isWhitelisted('test4', '')).to.be.false
        expect(r.isWhitelisted('test4', 's')).to.be.false
        expect(r.isWhitelisted('test4', 'some')).to.be.false
        expect(r.isWhitelisted('test4', 'other')).to.be.false

    describe 'for test5 /^some$/', ->
      it 'should pass all tests with true', ->
        expect(r.isWhitelisted('test5', 'some')).to.be.true
      it 'should pass all tests with false', ->
        expect(r.isWhitelisted('test5', '')).to.be.false
        expect(r.isWhitelisted('test5', 's')).to.be.false
        expect(r.isWhitelisted('test5', 'some/')).to.be.false
        expect(r.isWhitelisted('test5', 'some/scope')).to.be.false
        expect(r.isWhitelisted('test5', 'other')).to.be.false


  # ------------------------------------------------------------------
  describe '#isBlacklisted', ->

    r = null

    beforeEach ->
      r = new Registry()

      r.register('test1', { })
      r.register('test2', { })
      r.register('test3', { })
      r.register('test4', { })
      r.register('test5', { })
      r.register('test6', { })

      r.blacklistEntry 'test1'
      r.blacklistEntry 'test2', 'some'
      r.blacklistEntry 'test3', 'some/scope'
      r.blacklistEntry 'test4', /^some\/.*/
      r.blacklistEntry 'test5', /^some$/

    describe 'for test1 *', ->
      it 'should pass all tests with true', ->
        expect(r.isBlacklisted('test1', '')).to.be.true
        expect(r.isBlacklisted('test1', 's')).to.be.true
        expect(r.isBlacklisted('test1', 'some')).to.be.true
        expect(r.isBlacklisted('test1', 'some/')).to.be.true
        expect(r.isBlacklisted('test1', 'some/scope')).to.be.true
        expect(r.isBlacklisted('test1', 'other')).to.be.true

    describe 'for test2 some', ->
      it 'should pass all tests with true', ->
        expect(r.isBlacklisted('test2', 'some')).to.be.true
      it 'should pass all tests with false', ->
        expect(r.isBlacklisted('test2', '')).to.be.false
        expect(r.isBlacklisted('test2', 's')).to.be.false
        expect(r.isBlacklisted('test2', 'some/')).to.be.false
        expect(r.isBlacklisted('test2', 'some/scope')).to.be.false
        expect(r.isBlacklisted('test2', 'other')).to.be.false

    describe 'for test3 some/scope', ->
      it 'should pass all tests with true', ->
        expect(r.isBlacklisted('test3', 'some/scope')).to.be.true
      it 'should pass all tests with false', ->
        expect(r.isBlacklisted('test3', '')).to.be.false
        expect(r.isBlacklisted('test3', 's')).to.be.false
        expect(r.isBlacklisted('test3', 'some/')).to.be.false
        expect(r.isBlacklisted('test3', 'some')).to.be.false
        expect(r.isBlacklisted('test3', 'other')).to.be.false

    describe 'for test4 /^some\\/.*/', ->
      it 'should pass all tests with true', ->
        expect(r.isBlacklisted('test4', 'some/')).to.be.true
        expect(r.isBlacklisted('test4', 'some/scope')).to.be.true
      it 'should pass all tests with false', ->
        expect(r.isBlacklisted('test4', '')).to.be.false
        expect(r.isBlacklisted('test4', 's')).to.be.false
        expect(r.isBlacklisted('test4', 'some')).to.be.false
        expect(r.isBlacklisted('test4', 'other')).to.be.false

    describe 'for test5 /^some$/', ->
      it 'should pass all tests with true', ->
        expect(r.isBlacklisted('test5', 'some')).to.be.true
      it 'should pass all tests with false', ->
        expect(r.isBlacklisted('test5', '')).to.be.false
        expect(r.isBlacklisted('test5', 's')).to.be.false
        expect(r.isBlacklisted('test5', 'some/')).to.be.false
        expect(r.isBlacklisted('test5', 'some/scope')).to.be.false
        expect(r.isBlacklisted('test5', 'other')).to.be.false

  # ------------------------------------------------------------------
  describe '#isFilterIncluded', ->

    r = null

    beforeEach ->
      r = new Registry()

      r.register('test1', { })
      r.register('test2', { }, [])
      r.register('test3', { }, ['a'])
      r.register('test4', { }, ['b'])
      r.register('test5', { }, ['a', 'b'])

      r.whitelistEntry 'test1'
      r.whitelistEntry 'test2'
      r.whitelistEntry 'test3'
      r.whitelistEntry 'test4'
      r.whitelistEntry 'test5'

    describe 'for test1 null', ->
      it 'should pass all tests with true', ->
        expect(r.isFilterIncluded('test1')).to.be.true
        expect(r.isFilterIncluded('test1', [], true)).to.be.true
        expect(r.isFilterIncluded('test1', [], false)).to.be.true
      it 'should pass all tests with false', ->
        expect(r.isFilterIncluded('test1', ['a'], true)).to.be.false
        expect(r.isFilterIncluded('test1', ['a'], false)).to.be.false
        expect(r.isFilterIncluded('test1', ['b'], true)).to.be.false
        expect(r.isFilterIncluded('test1', ['b'], false)).to.be.false
        expect(r.isFilterIncluded('test1', ['c'], true)).to.be.false
        expect(r.isFilterIncluded('test1', ['c'], false)).to.be.false
        expect(r.isFilterIncluded('test1', ['a', 'b'], false)).to.be.false
        expect(r.isFilterIncluded('test1', ['a', 'b'], true)).to.be.false
        expect(r.isFilterIncluded('test1', ['a', 'c'], false)).to.be.false
        expect(r.isFilterIncluded('test1', ['a', 'c'], true)).to.be.false
        expect(r.isFilterIncluded('test1', ['b', 'c'], false)).to.be.false
        expect(r.isFilterIncluded('test1', ['b', 'c'], true)).to.be.false
        expect(r.isFilterIncluded('test1', ['a', 'b', 'c'], false)).to.be.false
        expect(r.isFilterIncluded('test1', ['a', 'b', 'c'], true)).to.be.false

    describe 'for test2 []', ->
      it 'should pass all tests with true', ->
        expect(r.isFilterIncluded('test2')).to.be.true
        expect(r.isFilterIncluded('test2', [], true)).to.be.true
        expect(r.isFilterIncluded('test2', [], false)).to.be.true
      it 'should pass all tests with false', ->
        expect(r.isFilterIncluded('test2', ['a'], true)).to.be.false
        expect(r.isFilterIncluded('test2', ['a'], false)).to.be.false
        expect(r.isFilterIncluded('test2', ['b'], true)).to.be.false
        expect(r.isFilterIncluded('test2', ['b'], false)).to.be.false
        expect(r.isFilterIncluded('test2', ['c'], true)).to.be.false
        expect(r.isFilterIncluded('test2', ['c'], false)).to.be.false
        expect(r.isFilterIncluded('test2', ['a', 'b'], false)).to.be.false
        expect(r.isFilterIncluded('test2', ['a', 'b'], true)).to.be.false
        expect(r.isFilterIncluded('test2', ['a', 'c'], false)).to.be.false
        expect(r.isFilterIncluded('test2', ['a', 'c'], true)).to.be.false
        expect(r.isFilterIncluded('test2', ['b', 'c'], false)).to.be.false
        expect(r.isFilterIncluded('test2', ['b', 'c'], true)).to.be.false
        expect(r.isFilterIncluded('test2', ['a', 'b', 'c'], false)).to.be.false
        expect(r.isFilterIncluded('test2', ['a', 'b', 'c'], true)).to.be.false

    describe 'for test3 ["a"]', ->
      it 'should pass all tests with true', ->
        expect(r.isFilterIncluded('test3')).to.be.true
        expect(r.isFilterIncluded('test3', [], true)).to.be.true
        expect(r.isFilterIncluded('test3', [], false)).to.be.true
        expect(r.isFilterIncluded('test3', ['a'], true)).to.be.true
        expect(r.isFilterIncluded('test3', ['a'], false)).to.be.true
        expect(r.isFilterIncluded('test3', ['a', 'b'], false)).to.be.true
        expect(r.isFilterIncluded('test3', ['a', 'c'], false)).to.be.true
        expect(r.isFilterIncluded('test3', ['a', 'b', 'c'], false)).to.be.true
      it 'should pass all tests with false', ->
        expect(r.isFilterIncluded('test3', ['b'], true)).to.be.false
        expect(r.isFilterIncluded('test3', ['b'], false)).to.be.false
        expect(r.isFilterIncluded('test3', ['c'], true)).to.be.false
        expect(r.isFilterIncluded('test3', ['c'], false)).to.be.false
        expect(r.isFilterIncluded('test3', ['a', 'b'], true)).to.be.false
        expect(r.isFilterIncluded('test3', ['a', 'c'], true)).to.be.false
        expect(r.isFilterIncluded('test3', ['b', 'c'], false)).to.be.false
        expect(r.isFilterIncluded('test3', ['b', 'c'], true)).to.be.false
        expect(r.isFilterIncluded('test3', ['a', 'b', 'c'], true)).to.be.false

    describe 'for test4 ["b"]', ->
      it 'should pass all tests with true', ->
        expect(r.isFilterIncluded('test4')).to.be.true
        expect(r.isFilterIncluded('test4', [], true)).to.be.true
        expect(r.isFilterIncluded('test4', [], false)).to.be.true
        expect(r.isFilterIncluded('test4', ['b'], true)).to.be.true
        expect(r.isFilterIncluded('test4', ['b'], false)).to.be.true
        expect(r.isFilterIncluded('test4', ['a', 'b'], false)).to.be.true
        expect(r.isFilterIncluded('test4', ['b', 'c'], false)).to.be.true
        expect(r.isFilterIncluded('test4', ['a', 'b', 'c'], false)).to.be.true
      it 'should pass all tests with false', ->
        expect(r.isFilterIncluded('test4', ['a'], true)).to.be.false
        expect(r.isFilterIncluded('test4', ['a'], false)).to.be.false
        expect(r.isFilterIncluded('test4', ['c'], true)).to.be.false
        expect(r.isFilterIncluded('test4', ['c'], false)).to.be.false
        expect(r.isFilterIncluded('test4', ['a', 'b'], true)).to.be.false
        expect(r.isFilterIncluded('test4', ['a', 'c'], false)).to.be.false
        expect(r.isFilterIncluded('test4', ['a', 'c'], true)).to.be.false
        expect(r.isFilterIncluded('test4', ['b', 'c'], true)).to.be.false
        expect(r.isFilterIncluded('test4', ['a', 'b', 'c'], true)).to.be.false

    describe 'for test5 ["a", "b"]', ->
      it 'should pass all tests with true', ->
        expect(r.isFilterIncluded('test5')).to.be.true
        expect(r.isFilterIncluded('test5', [], true)).to.be.true
        expect(r.isFilterIncluded('test5', [], false)).to.be.true
        expect(r.isFilterIncluded('test5', ['a'], true)).to.be.true
        expect(r.isFilterIncluded('test5', ['a'], false)).to.be.true
        expect(r.isFilterIncluded('test5', ['b'], true)).to.be.true
        expect(r.isFilterIncluded('test5', ['b'], false)).to.be.true
        expect(r.isFilterIncluded('test5', ['a', 'b'], false)).to.be.true
        expect(r.isFilterIncluded('test5', ['a', 'b'], true)).to.be.true
        expect(r.isFilterIncluded('test5', ['a', 'c'], false)).to.be.true
        expect(r.isFilterIncluded('test5', ['b', 'c'], false)).to.be.true
        expect(r.isFilterIncluded('test5', ['a', 'b', 'c'], false)).to.be.true
      it 'should pass all tests with false', ->
        expect(r.isFilterIncluded('test5', ['c'], true)).to.be.false
        expect(r.isFilterIncluded('test5', ['c'], false)).to.be.false
        expect(r.isFilterIncluded('test5', ['a', 'c'], true)).to.be.false
        expect(r.isFilterIncluded('test5', ['b', 'c'], true)).to.be.false
        expect(r.isFilterIncluded('test5', ['a', 'b', 'c'], true)).to.be.false

  # ------------------------------------------------------------------
  describe '#isIncluded', ->
    # (id, key, filters = [])

    r = null

    beforeEach ->
      r = new Registry()

    it 'should pass for case 1', ->
      r.register('test', { }, ['a'])
      r.whitelistEntry 'test'

      expect(r.isIncluded('test', '')).to.be.true
      expect(r.isIncluded('test', 'a')).to.be.true
      expect(r.isIncluded('test', 'some')).to.be.true
      expect(r.isIncluded('test', 'some/other')).to.be.true
      expect(r.isIncluded('test', 'other')).to.be.true
      expect(r.isIncluded('test', '', ['a'])).to.be.true
      expect(r.isIncluded('test', 'a', ['a'])).to.be.true
      expect(r.isIncluded('test', 'some', ['a'])).to.be.true
      expect(r.isIncluded('test', 'some/other', ['a'])).to.be.true
      expect(r.isIncluded('test', 'other', ['a'])).to.be.true
      expect(r.isIncluded('test', '', ['b'])).to.be.false
      expect(r.isIncluded('test', 'a', ['b'])).to.be.false
      expect(r.isIncluded('test', 'some', ['b'])).to.be.false
      expect(r.isIncluded('test', 'some/other', ['b'])).to.be.false
      expect(r.isIncluded('test', 'other', ['b'])).to.be.false

    it 'should pass for case 2', ->
      r.register('test', { }, ['a'])
      r.whitelistEntry 'test', /^some.*/

      expect(r.isIncluded('test', '')).to.be.false
      expect(r.isIncluded('test', 'a')).to.be.false
      expect(r.isIncluded('test', 'some')).to.be.true
      expect(r.isIncluded('test', 'some/other')).to.be.true
      expect(r.isIncluded('test', 'other')).to.be.false
      expect(r.isIncluded('test', '', ['a'])).to.be.false
      expect(r.isIncluded('test', 'a', ['a'])).to.be.false
      expect(r.isIncluded('test', 'some', ['a'])).to.be.true
      expect(r.isIncluded('test', 'some/other', ['a'])).to.be.true
      expect(r.isIncluded('test', 'other', ['a'])).to.be.false
      expect(r.isIncluded('test', '', ['b'])).to.be.false
      expect(r.isIncluded('test', 'a', ['b'])).to.be.false
      expect(r.isIncluded('test', 'some', ['b'])).to.be.false
      expect(r.isIncluded('test', 'some/other', ['b'])).to.be.false
      expect(r.isIncluded('test', 'other', ['b'])).to.be.false


