_     = require 'lodash'
http  = require 'http'
debug = require('debug')('meshblu-connector-http:http-manager')

class HttpManager
  constructor: (options, {@request}={}) ->
    @request ?= require 'request'

  sendRequest: (requestOptions, callback=->) =>
    debug 'requestOptions', requestOptions
    @request requestOptions, (error, response, body) =>
      return callback error if error?
      metadata =
        code: response?.statusCode
        status: http.STATUS_CODES[response?.statusCode]
      data = body
      callback null, {metadata, data}

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

  _mapKeyValuePairs: (toMap) =>
    return unless toMap?
    mapped = {}
    _.each toMap, (item={}) =>
      mapped[item.name] = item.value
    return mapped

module.exports = HttpManager
