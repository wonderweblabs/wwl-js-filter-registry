# wwl-node-filter-registry

| Current Version |
|-----------------|
| [![npm version](https://badge.fury.io/js/wwl-js-filter-registry.svg)](https://badge.fury.io/js/wwl-js-filter-registry) |

---

The filter registry is a collection wrapper to white- and blacklist it's entries. By calling ```get``` and passing a key, the registry will filter it's entries based on the regular expressions listed in the whitelist and blacklist. Additionally, you can pass filter keys on top.

A whitelist/blacklist for one entry can have multiple regex statements.

## Methods

| method | returns | desc |
| --- | --- | --- |
| register(id, data, filters = null, options = null) | ampersand-state | Register your data entry. ```id``` and ```data``` is required. Additionally you can pass a ```filters array``` and an ```options object```. You can use options to pass meta information for later use. |
| unregister(id)                      | null | Remove entry for id from registry. |
| whitelistEntry: (id, regex = null)  | null | Whitelist entry. If regex is null, /.*/ will be used. |
| blacklistEntry: (id, regex = null)  | null | Blacklist entry. If regex is null, /.*/ will be used. |
| resetEntryWhitelist: (id)           | null | Reset whitelist. |
| resetEntryBlacklist: (id)           | null | Reset blacklist. |
| get: (key, filters = null, useAnd = false) | array[ampersand-state] | Returns an array of ```key``` matching entries. Additionally the list can be filtered by the passed array of strings. (see ```isFilterIncluded```)  |
| isIncluded: (id, key, filters = [], useAnd = false) | boolean | Full passing check for one entry based on the passed key. Additionally you can extend the request by passing an array of filters. (see ```isFilterIncluded```) |
| isWhitelisted: (id, key)            | boolean | Check if an entry is whitelisted based on the passed ```key```. |
| isBlacklisted: (id, key)            | boolean | Check if an entry is blacklisted based on the passed ```key```. |
| isFilterIncluded: (id, filters = [], useAnd = false) | boolean | Check if an entry passes the filters array conditions. By default it will be true if **one** filters string matches (```useAnd = false```). If you set ```useAnd``` to true, the entry needs to have every of the passed filters in it's own filters list. |

## Examples

### Listing

```coffeescript
r = new (require('filter_registry'))()

# register objects
r.register 'test1', { my: 'data' }
r.register 'test2', { my: 'data' }
r.register 'test3', { my: 'data' }
r.register 'test4', { my: 'data' }
r.register 'test5', { my: 'data' }

# define their visibility

r.whitelistEntry('test1') # will always show up
r.blacklistEntry('test2') # will never show up

r.whitelistEntry('test3', /^some\/.*/)
r.whitelistEntry('test4', /.*other$/)

r.whitelistEntry('test5')
r.blacklistEntry('test5', /^some\/.*/)

# get data

r.get('xyz')          # test1, test2, test5
r.get('some')         # test1, test2, test5
r.get('some/other')   # test1, test2, test3, test4

```


### Filtering

```coffeescript
r = new (require('filter_registry'))()

# register objects
r.register 'test1', { my: 'data' }
r.register 'test2', { my: 'data' }, []
r.register 'test3', { my: 'data' }, ['a']
r.register 'test4', { my: 'data' }, ['b']
r.register 'test5', { my: 'data' }, ['a', 'b']

r.whitelistEntry('test1')
r.whitelistEntry('test2')
r.whitelistEntry('test3')
r.whitelistEntry('test4')
r.whitelistEntry('test5')

# Use filters
r.get('xyz')                    # 1, 2, 3, 4, 5
r.get('xyz', [])                # 1, 2, 3, 4, 5
r.get('xyz', ['a'])             # 3, 5
r.get('xyz', ['a'], false)      # 3, 5
r.get('xyz', ['a'], true)       # 3, 5
r.get('xyz', ['a', 'b'])        # 3, 5
r.get('xyz', ['a', 'b'], false) # 3, 5
r.get('xyz', ['a', 'b'], true)  # 5

```
