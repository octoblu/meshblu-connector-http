{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-http:index')
HttpManager     = require './http-manager'

class Connector extends EventEmitter
  constructor: ->
    @httpManager = new HttpManager

  sendRequest: (requestOptions, callback) =>
    @httpManager.sendRequest requestOptions, callback

  sendNtlmRequest: (authentication, requestOptions, callback) =>
    @httpManager.sendNtlmRequest authentication, requestOptions, callback

  formatRequest: ({ requestOptions, encoding, headers, qs, body }) =>
    @httpManager.formatRequest { requestOptions, encoding, headers, qs, body }

  isOnline: (callback) =>
    callback null, running: true

  close: (callback) =>
    debug 'on close'
    callback()

  onConfig: (device={}) =>
    { @options } = device
    debug 'on config', @options

  start: (device, callback) =>
    debug 'started'
    @onConfig device
    callback()

module.exports = Connector
