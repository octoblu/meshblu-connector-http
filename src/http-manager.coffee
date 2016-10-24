{challengeHeader, responseHeader} = require 'ntlm'
_    = require 'lodash'
http = require 'http'

debug = require('debug')('meshblu-connector-http:http-manager')

class HttpManager
  constructor: (options, {@request}={}) ->
    @request ?= require 'request'

  formatRequest: ({ requestOptions={}, encoding='JSON', headers, qs, body }={}) =>
    debug {requestOptions, encoding, headers, qs, body}
    newRequestOptions = {}
    newRequestOptions.headers = _.assign {
      'Accept': 'application/json'
      'User-Agent': 'Octoblu/1.0.0'
      'x-li-format': 'json'
    }, @_mapKeyValuePairs(headers)
    newRequestOptions.form = @_mapKeyValuePairs body if encoding == 'FORM_URL_ENCODED'
    newRequestOptions.json = @_mapKeyValuePairs body if encoding == 'JSON'
    newRequestOptions.qs   = @_mapKeyValuePairs qs
    newRequestOptions = JSON.parse JSON.stringify newRequestOptions
    baseOptions = {}
    baseOptions.json = true if encoding == 'JSON'
    return _.assign(baseOptions, requestOptions, newRequestOptions)

  sendRequest: (requestOptions, callback=->) =>
    debug 'requestOptions', requestOptions
    @request requestOptions, (error, response, body) =>
      return callback error if error?
      metadata =
        code: response?.statusCode
        status: http.STATUS_CODES[response?.statusCode]
      data = body
      callback null, {metadata, data}

  sendNtlmRequest: ({username, password, hostname}, requestOptions, callback=->) =>
    hostname ?= _.last _.split(username, '@')

    options = {
      uri:    requestOptions.uri
      method: requestOptions.method
      forever: true
      headers:
        'Authorization': challengeHeader('', hostname)
    }

    @request options, (error, response) =>
      return callback error if error?
      return callback @_userError(504, "Expected 401, got: #{response.statusCode}") unless response.statusCode == 401

      headers = {
        'Authorization': responseHeader(response, requestOptions.uri, '', username, password)
      }

      @sendRequest _.defaults({ headers }, options, requestOptions), callback

  _mapKeyValuePairs: (toMap) =>
    return unless toMap?
    mapped = {}
    _.each toMap, (item={}) =>
      mapped[item.name] = item.value
    return mapped

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = HttpManager
