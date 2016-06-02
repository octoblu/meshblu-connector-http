_               = require 'lodash'
{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-http:index')
request         = require 'request'

class Http extends EventEmitter
  onMessage: (message={}) =>
    requestOptions = @formatRequest message.payload
    debug 'requestOptions', requestOptions
    return unless requestOptions.uri?
    @sendRequest requestOptions

  emitError: (error) =>
    @emit 'message', {
      devices: ['*'],
      topic: 'error',
      payload: {
        error
      }
    }

  sendRequest: (requestOptions) =>
    debug 'requestOptions', requestOptions
    request requestOptions, (error, response, body) =>
      return @emitError error if error?
      debug 'emitting request'
      message =
        devices: ['*']
        topic: 'http-response'
        payload:
          statusCode: response.statusCode
          body: body
      @emit 'message', message

  formatRequest: ({ requestOptions={}, encoding='JSON', headers, qs, body }) =>
    newRequestOptions = {}
    newRequestOptions.headers = _.assign {
      'Accept': 'application/json'
      'User-Agent': 'Octoblu/1.0.0'
      'x-li-format': 'json'
    }, @mapKeyValuePairs(headers)
    newRequestOptions.form = @mapKeyValuePairs body if encoding == 'FORM_URL_ENCODED'
    newRequestOptions.json = @mapKeyValuePairs body if encoding == 'JSON'
    newRequestOptions.qs   = @mapKeyValuePairs qs
    newRequestOptions = JSON.parse JSON.stringify newRequestOptions
    baseOptions = {}
    baseOptions.json = true if encoding == 'JSON'
    return _.assign(baseOptions, requestOptions, newRequestOptions)

  mapKeyValuePairs: (toMap) =>
    return unless toMap?
    mapped = {}
    _.each toMap, (item={}) =>
      mapped[item.name] = item.value
    return mapped

module.exports = Http
