{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-http:index')
_               = require 'lodash'
request         = require 'request'

class Http extends EventEmitter
  constructor: ->
    debug 'Http constructed'

  onMessage: (message) =>
    { req } = message.payload
    return unless req?
    req = formatRequest req
    debug 'got valid message', request
    
    request req, (err, response, body) =>
      return @emit 'error', err if err?
      message =
        devices: ['*']
        topic: 'http-response'
        payload:
          statusCode: response.statusCode
          body: body
      @emit 'message', message

  formatRequest: (req) =>
    { headers, body, qs, encoding, uri, method, redirect } = req

    config =
      headers:
        'Accept': 'application/json'
        'User-Agent': 'Octoblu/1.0.0'
        'x-li-format': 'json'
      uri: uri
      method: method
      followAllRedirects: redirect

    config.headers = _.extend(config.headers, mapKeyValuePairs headers) if headers?
    config.form = mapKeyValuePairs body unless encoding == 'JSON' && !body?
    config.json = mapKeyValuePairs body if body?
    config.qs = mapKeyValuePairs qs if qs?
    return config


  mapKeyValuePairs: (toMap) =>
    return unless toMap?
    mapped = {}
    _.forEach toMap, (item) =>
      mapped[item.name] = item.value

  onConfig: (device) =>
    { @options } = device
    debug 'on config', @options

  start: (device) =>
    { @uuid } = device
    debug 'started', @uuid

module.exports = Http
