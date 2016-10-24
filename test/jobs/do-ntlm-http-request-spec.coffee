{beforeEach, context, describe, it} = global
{expect} = require 'chai'
sinon = require 'sinon'

{job} = require '../../jobs/do-ntlm-http-request'

describe 'DoNtlmHttpRequest', ->
  beforeEach ->
    @connector =
      formatRequest:
        sinon.spy ({requestOptions}) -> requestOptions
      sendNtlmRequest:
        sinon.stub().yields()

    @sut = new job {@connector}

  context 'when given a valid message', ->
    beforeEach (done) ->
      message =
        data:
          authentication:
            username: 'beulah'
            password: 'dennis'
          requestOptions:
            uri: 'https://hello-world.org/'
      @sut.do message, done

    it 'should call @connector.formatRequest', ->
      expect(@connector.formatRequest.calledOnce).to.be.true

    it 'should call @connector.sendNtlmRequest with the authentication information', ->
      authentication = { username: 'beulah', password: 'dennis' }
      requestOptions = { uri: 'https://hello-world.org/' }

      expect(@connector.sendNtlmRequest.calledOnce).to.be.true
      expect(@connector.sendNtlmRequest).to.have.been.calledWith authentication, requestOptions

    it 'should call @connector formatRequest and sendNtlmRequest functions in the right order', ->
      expect(@connector.formatRequest.calledBefore @connector.sendNtlmRequest).to.be.true

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

  context 'when given no auth data in the message', ->
    beforeEach (done) ->
      message = {
        data:
          requestOptions:
            uri: 'https://hello-world.org/'
      }
      @sut.do message, (@error) => done()

    it 'should error with a 422 and appropriate error message', ->
      expect(@error).to.exist
      expect(@error.code).to.equal 422
      expect(@error.message).to.deep.equal "data.authentication is required"

  context 'when given an invalid message', ->
    beforeEach (done) ->
      message =
        data:
          authentication:
            username: 'jack'
            password: 'sanchez'
          requestOptions:
            uri: null
      @sut.do message, (@error) => done()

    it "should error with an accurate message", ->
      expect(@error).to.exist
      expect(@error.message).to.equal 'data.requestOptions.uri is required'
