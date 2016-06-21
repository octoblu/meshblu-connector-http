{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-http:index')
HttpManager     = require './http-manager'

class Connector extends EventEmitter
  constructor: ->
    @httpManager = new HttpManager

  sendRequest: =>
    @httpManager.sendRequest.apply @httpManager, arguments

  formatRequest: =>
    @httpManager.formatRequest.apply @httpManager, arguments

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
