global.Promise = require('es6-promise').Promise
Chain          = require('../chain.js').Chain
chai           = require 'chai'
sinon          = require 'sinon'
expect         = chai.expect

chai.use require('sinon-chai')

lets = (name, fn) ->
  beforeEach ->
    @[name] = fn()
    null

describe 'Chain', ->
  this.timeout(10);
  lets 'link', -> Chain.clone

  it "can be called with new", ->
    expect(new Chain).to.equal Chain
    expect(new @link).to.equal @link

  it 'sets properties', ->
    link = @link.with(a: 1, b: 2).set('c', 3)

    expect(link.a).to.equal 1
    expect(link.b).to.equal 2
    expect(link.c).to.equal 3

    expect(@link.a).to.equal undefined
    expect(@link.b).to.equal undefined
    expect(@link.c).to.equal undefined

  it "can be called with no consequence", ->
    expect(Chain).to.equal Chain()

  it 'clones itself', ->
    ln = @link.clone.clone().clone.clone
    expect(ln.clone.__proto__).to.equal ln
    expect(ln.clone.prototype).to.equal ln

  it "creates callable clones", ->
    link = Chain.clone.clone
    expect(link()).to.equal link

  it 'creates a copy', ->
    @link.getter 'context', -> this
    link = @link.clone

    expect(@link.context).to.equal @link
    expect(link.context).to.equal link

  it 'has non-enumerable methods', ->
    expect(Object.keys(Chain).length).to.equal(0)
    for i in @link
      expect(true).to.equal false


  describe '#tap', ->
    it 'passes a clone as this', ->
      parent = @link.with(a: 1)
      parent.tap ->
        expect(this.__proto__).to.equal parent
        expect(this.a).to.equal 1
      null

    it 'passes a clone as the first argument', ->
      parent = @link.with(a: 1)
      parent.tap (link) ->
        expect(link.__proto__).to.equal parent
        expect(link.a).to.equal 1
      null

    it 'returns self', ->
      expect(@link.tap(-> 1)).to.equal @link
      expect(@link.tap(->)  ).to.equal @link

  describe '#flag', ->
    beforeEach ->
      @link.flag('ab', a: 1, b: 2)
      null

    it 'sets attributes', ->

      expect(@link.ab.a).to.equal 1
      expect(@link.ab.b).to.equal 2

    it 'creates a clone', ->
      expect(@link.ab.__proto__).to.equal @link

  context 'with promise', ->
    lets 'plink', -> Chain.with(a: 1).resolve(5)

    describe '#then', ->
      it 'requires a promise', ->
        expect(@link.then).to.throw(Error, 'Nothing has been promised')
        null

      it 'contains a promise', ->
        expect(@plink._promise).to.be.instanceOf(Promise)

      it 'gets called with the result', (done) ->
        @plink.then (val) ->
          try
            expect(val).to.equal 5
          catch e
            return done(e)
          done()

      it 'clones itself with the new promise', (done) ->
        @plink.then(-> 'new').then (val) ->
          try
            expect(val).to.equal 'new'
          catch e
            return done(e)
          done()

    describe '#done', ->
      it 'equals #then', ->
        expect(@link.done).to.equal @link.then

    describe '#catch', ->
      it 'requires a promise', ->
        expect(@link.catch).to.throw(Error, 'Nothing has been promised')
        null

      it 'catches rejected promises', (done) ->
        @link.reject(new Error).catch (err) ->
          try
            expect(err).to.be.instanceOf Error
          catch e
            return done(e)

          done()

    describe '#promise', ->
      it 'resolves a promise', (done) ->
        @link.promise((res) -> res(5)).then (val) ->
          try
            expect(val).to.equal 5
          catch e
            return done(e)
          done()

      it 'rejects a promise', (done) ->
        @link.promise((res, rej) -> rej(5)).catch (val) ->
          try
            expect(val).to.equal 5
          catch e
            return done(e)
          done()
