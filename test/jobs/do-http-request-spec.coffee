{job} = require '../../jobs/do-http-request'

describe 'DoHttpRequest', ->
  beforeEach ->
    @connector =
      formatRequest:
        sinon.spy ({requestOptions}) -> requestOptions
      sendRequest:
        sinon.stub().callsArg(1)

    @sut = new job {@connector}

  context 'when given a valid message', ->
    beforeEach (done) ->
      message =
        data:
          requestOptions:
            uri: 'https://hello-world.org/'
      @sut.do message, (@error) =>
        done()

    it 'should not error', ->
      expect(@error).not.to.exist

    it 'should call @connector.formatRequest', ->
      expect(@connector.formatRequest.calledOnce).to.be.true

    it 'should call @connector.sendRequest', ->
      expect(@connector.sendRequest.calledOnce).to.be.true

    it 'should call @connector formatRequest and sendRequest functions in the right order', ->
      expect(@connector.formatRequest.calledBefore @connector.sendRequest).to.be.true

  context 'when given no data in message', ->
    beforeEach (done) ->
      message = {}
      @errorMessage = "data is required"
      @sut.do message, (@error) =>
        done()

    it 'should error', ->
      expect(@error).to.exist

    it "the error message should be accurate", ->
      expect(@error.message).to.equal @errorMessage

  context 'when given an invalid message', ->
    beforeEach (done) ->
      message =
        data:
          requestOptions:
            uri: null
      @errorMessage = "data.requestOptions.uri is required"
      @sut.do message, (@error) =>
        done()

    it 'should error', ->
      expect(@error).to.exist

    it "the error message should be accurate", ->
      expect(@error.message).to.equal @errorMessage
