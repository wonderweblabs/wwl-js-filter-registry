module.exports = (require('ampersand-state')).extend

  props:
    id:
      type:       'string'
      required:   true
      setOnce:    true
      allowNull:  false
    data:
      type:       'object'
      required:   true
      allowNull:  false
    filters:
      type:       'array'
      default:    -> []
    options:
      type:       'object'
      default:    -> {}

