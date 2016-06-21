{job} = require '../../jobs/do-http-request'

describe 'DoHttpRequest', ->
  beforeEach ->
    @connector =
      httpManager:
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

    it 'should call httpManager.formatRequest', ->
      expect(@connector.httpManager.formatRequest.calledOnce).to.be.true

    it 'should call httpManager.sendRequest', ->
      expect(@connector.httpManager.sendRequest.calledOnce).to.be.true

    it 'should call httpManager formatRequest and sendRequest functions in the right order', ->
      expect(@connector.httpManager.formatRequest.calledBefore @connector.httpManager.sendRequest).to.be.true

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
