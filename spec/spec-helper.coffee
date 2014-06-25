chai = require('chai')

chai.Assertion.addMethod 'cloneOf', (parent) ->
  clone = this._obj
  this.assert(
    clone.__proto__ is parent,
    "expected #{clone} to be clone of #{parent}",
    "expected #{clone} to not be clone of #{parent}",
    clone,
    clone.__proto__
  )
