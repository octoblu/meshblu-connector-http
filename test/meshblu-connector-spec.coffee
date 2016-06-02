Http = require '../'

describe 'Http', ->
  beforeEach ->
    @sut = new Http

  describe '->onMessage', ->
    it 'should be a method', ->
      expect(@sut.onMessage).to.be.a 'function'

    describe 'when called with a message', ->
      it 'should not throw an error', ->
        expect(=> @sut.onMessage({ topic: 'hello', devices: ['123'] })).to.not.throw(Error)
