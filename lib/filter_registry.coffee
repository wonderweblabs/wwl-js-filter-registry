Q       = require 'q'
_       = require 'underscore'

###

###
module.exports = class FilterRegistry

  entries:    null
  whitelist:  null
  blacklist:  null

  constructor: ->
    @entries    = new (require('./collections/entries_collection'))()
    @whitelist  = {}
    @blacklist  = {}

  register: (id, data, filters = null, options = null) ->
    filters = [filters] if !_.isArray(filters) && !_.isNull(filters) && !_.isUndefined(filters)
    filters or= []

    entry = @entries.add({
      id:       id
      data:     data
      filters:  filters
      options:  options
    }, {
      merge: true
    })

    @_ensureListEntries(entry)

    entry

  unregister: (id) ->
    return if !id?

    @resetEntryWhitelist(id)
    @resetEntryBlacklist(id)

    entry = @entries.get(id)
    @entries.remove(entry) if entry

    null

  whitelistEntry: (id, regex = null) ->
    if _.isRegExp(regex) || _.isString(regex)
      @whitelist[id].push(regex)
    else if _.isNull(regex)
      @resetEntryWhitelist(id)
      @whitelist[id].push /(.*)/

  blacklistEntry: (id, regex = null) ->
    if _.isRegExp(regex) || _.isString(regex)
      @blacklist[id].push(regex)
    else if _.isNull(regex)
      @resetEntryBlacklist(id)
      @blacklist[id].push /(.*)/

  resetEntryWhitelist: (id) ->
    @whitelist[id] = []

  resetEntryBlacklist: (id) ->
    @blacklist[id] = []

  get: (key, filters = null, useAnd = false) ->
    @entries.filter (entry) => @isIncluded(entry.id, key, filters, useAnd)

  isIncluded: (id, key, filters = [], useAnd = false) ->
    return false unless @isWhitelisted(id, key)
    return false if @isBlacklisted(id, key)

    @isFilterIncluded(id, filters, useAnd)

  isWhitelisted: (id, key) ->
    _.inject @whitelist[id], (memo, regex) ->
      if memo != true
        regex = new RegExp("^#{regex}$") if _.isString(regex)
        memo  = true if regex.test(key)
      memo
    , false

  isBlacklisted: (id, key) ->
    _.inject @blacklist[id], (memo, regex) ->
      if memo != true
        regex = new RegExp("^#{regex}$") if _.isString(regex)
        memo  = true if regex.test(key)
      memo
    , false

  isFilterIncluded: (id, filters = [], useAnd = false) ->
    entry = @entries.get(id)
    return false unless entry
    return true if !_.any(filters)
    return false if !_.any(entry.filters)

    if useAnd == true
      @_isFilterIncludedAnd(entry, filters)
    else
      @_isFilterIncludedOr(entry, filters)


  # ---------------------------------------------
  # private

  # @nodoc
  _ensureListEntries: (entry) ->
    @resetEntryWhitelist(entry.id) unless _.isArray(@whitelist[entry.id])
    @resetEntryBlacklist(entry.id) unless _.isArray(@blacklist[entry.id])

  # @nodoc
  _isFilterIncludedAnd: (entry, filters) ->
    _.size(_.difference(filters, entry.filters)) <= 0

  # @nodoc
  _isFilterIncludedOr: (entry, filters) ->
    _.size(_.difference(filters, entry.filters)) < _.size(filters)

