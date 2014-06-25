global.Promise = require('es6-promise').Promise
chai           = require 'chai'
sinon          = require 'sinon'
expect         = chai.expect

require('blanket')
  pattern: (filename) ->
    !/node_modules/.test(filename);

Chain          = require('../chain.js').Chain

chai.use require('sinon-chai')

log = console.log.bind(console)
lets = (name, fn) ->
  beforeEach ->
    @[name] = fn()
    null

describe 'Chain', ->
  this.timeout 10
  lets 'link', -> Chain.clone

  it "can be called with new", ->
    expect(new Chain).to.equal Chain
    expect(new @link).to.equal @link

  it 'clones with properties', ->
    link = @link.with(a: 1, b: 2).with('c', 3)

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

  describe '#lazy', ->
    it 'only calls passed fn when needed', ->
      @link.lazy 'five', -> throw 5
      expect(@link).to.be.ok

    it 'returns the return value of passed fn', ->
      @link.lazy 'five', -> 5
      expect(@link.five).to.equal 5
      expect(@link.five).to.equal 5

    it 'only calls passed fn once', ->
      count = 0
      @link.lazy 'me', -> count++; this

      expect(@link.me.me.me).to.equal @link
      expect(count).to.equal 1

    it 'applies to the link it was first called on', ->
      @link.lazy 'me', -> this._me = this
      link = @link.clone.clone

      expect(link.me).to.equal link
      expect(link.clone.me).to.equal link
      expect(@link._me).to.equal undefined

  context 'with promise', ->
    lets 'plink', -> Chain.with(a: 1).promise (r) -> r(5)

    describe '#then', ->
      it 'requires a promise', ->
        fn = @link.catch.bind(@link)
        expect(fn).to.throw(Error, 'Nothing has been promised')

      it 'contains a promise', ->
        expect(@plink._promise).to.be.instanceOf(Promise)

      it 'gets called with the result', (done) ->
        @plink.then (val) ->
          expect(val).to.equal 5
          done()

      it 'clones itself with the new promise', (done) ->
        @plink.then(-> 'new').then (val) ->
          expect(val).to.equal 'new'
          done()

    describe '#done', ->
      it 'equals #then', ->
        expect(@link.done).to.equal @link.then

    describe '#catch', ->
      it 'requires a promise', ->
        fn = @link.catch.bind(@link)
        expect(fn).to.throw(Error, 'Nothing has been promised')

      it 'catches rejected promises', (done) ->
        @link.promise((_, rej) -> rej(5)).catch (val) ->
          expect(val).to.equal 5
          done()

    describe '#promise', ->
      it 'resolves a promise', (done) ->
        @plink.then (val) ->
          expect(val).to.equal 5
          done()
