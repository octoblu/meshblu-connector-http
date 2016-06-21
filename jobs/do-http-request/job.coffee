http  = require 'http'
debug = require('debug')('meshblu-connector-http:http-request-job')

class HttpRequestJob
  constructor: ({@connector}) ->
    throw new Error 'HttpRequestJob requires connector' unless @connector?

  do: ({data}, callback) =>
    return callback @_userError(422, 'data is required') unless data?
    debug {data}
    requestOptions = @connector.formatRequest data
    debug 'requestOptions', requestOptions
    return callback @_userError(422, 'data.requestOptions.uri is required') unless requestOptions?.uri?
    @connector.sendRequest requestOptions, callback

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = HttpRequestJob
