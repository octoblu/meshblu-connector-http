HttpManager = require '../src/http-manager.coffee'
shmock = require 'shmock'

describe 'HttpManager', ->

  describe '->formatRequest', ->
    beforeEach ->
      @sut = new HttpManager

    describe 'when called with no arguments', ->
      beforeEach ->
        @result = @sut.formatRequest()

      it 'should return default request options', ->
        expect(@result).to.deep.equal {
          json: true
          headers:
            Accept: 'application/json'
            'User-Agent': 'Octoblu/1.0.0'
            'x-li-format': 'json'
        }

    describe 'when called with some property in requestOptions arguments', ->
      beforeEach ->
        @result = @sut.formatRequest(requestOptions: hello: 'world')

      it 'should add that property to options', ->
        expect(@result).to.contain hello: 'world'

    describe 'when called with some property in header arguments', ->
      beforeEach ->
        @result = @sut.formatRequest(headers: [{name:'head', value:'and shoulders'}])

      it 'should add that property to header options', ->
        expect(@result.headers).to.contain head: 'and shoulders'

    describe 'when called with some property in body arguments', ->
      beforeEach ->
        @result = @sut.formatRequest(body: [{name:'trans', value:'former'}])

      it 'should add that property to json options', ->
        expect(@result.json).to.contain trans: 'former'

    describe 'when called with some property in body arguments and encoding as form/url', ->
      beforeEach ->
        @result = @sut.formatRequest(encoding: 'FORM_URL_ENCODED', body: [{name:'body', value:'builder'}])

      it 'should add that property to form options', ->
        expect(@result.form).to.contain body: 'builder'

    describe 'when called with some property in query string arguments', ->
      beforeEach ->
        @result = @sut.formatRequest(qs: [{name:'string', value:'cheese'}])

      it 'should add that property to qs options', ->
        expect(@result.qs).to.contain string: 'cheese'

  describe '-> sendRequest', ->
    describe 'with a stubbed request module', ->
      beforeEach ->
        @request = sinon.stub().callsArg(1)
        @sut = new HttpManager {}, {@request}

      describe 'when called without any arguments', ->
        beforeEach ->
          @sut.sendRequest()

        it 'should not crash', ->
          expect(@sut).to.exist

      describe 'when called with a callback', ->
        beforeEach (done) ->
          @sut.sendRequest(null,done)

        it 'should not crash', ->
          expect(@sut).to.exist

      describe 'when called with a url and callback', ->
        beforeEach (done) ->
          @sut.sendRequest({uri: 'https://hello-world.org/'}, done)

        it 'should not crash', ->
          expect(@sut).to.exist

    describe 'with actual request module', ->
      beforeEach ->
        minPort = 49152
        maxPort = 65535
        @port = Math.round(Math.random() * (maxPort - minPort) + minPort)

      beforeEach ->
        @sut = new HttpManager

      describe 'when called without any arguments', ->
        beforeEach ->
          @errorMessage = 'undefined is not a valid uri or options object.'
          try
            @sut.sendRequest()
          catch error
            @error = error

        it 'should crash with an appropriate message', ->
          expect(@error.message).to.equal @errorMessage

      describe 'when called with a valid url and callback', ->
        beforeEach (done) ->
          @mock = shmock @port
          @mock.get("/foo").reply(200, "bar")
          options = uri: "http://localhost:#{@port}/foo"
          @sut.sendRequest options, (@error, @result) =>
            done()

        it 'should not error', ->
          expect(@error).to.not.exist

        it 'should have a proper result', ->
          expect(@result).to.deep.equal {
            metadata:
              code: 200
              status: "OK"
            data:
              devices: ["*"]
              topic: "http-response"
              payload:
                statusCode: 200
                body: "bar"
          }

      describe 'when called with a bad url and callback', ->
        beforeEach (done) ->
          @mock = shmock @port
          @mock.get("/foo").reply(500, "oops")
          options = uri: "http://localhost:#{@port}/foo"
          @sut.sendRequest options, (@error, @result) =>
            done()

        it 'should not error', ->
          expect(@error).to.not.exist

        it 'should have a proper result with error code', ->
          expect(@result).to.deep.equal {
            metadata:
              code: 500
              status: "Internal Server Error"
            data:
              devices: ["*"]
              topic: "http-response"
              payload:
                statusCode: 500
                body: "oops"
          }

      describe 'when called with an invalid host and callback', ->
        beforeEach (done) ->
          options = uri: "http://localhost:#{@port}/foo"
          @sut.sendRequest options, (@error, @result) =>
            done()

        it 'should error', ->
          expect(@error).to.exist

        it 'should not have a result', ->
          expect(@result).to.not.exist
