{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-http:index')

class Http extends EventEmitter
  constructor: ->
    debug 'Http constructed'

  isOnline: (callback) =>
    callback null, running: true

  close: (callback) =>
    debug 'on close'
    callback()

  onMessage: (message) =>
    { topic, devices, fromUuid } = message
    return if '*' in devices
    return if fromUuid == @uuid
    debug 'on message', { topic }

  onConfig: (device) =>
    { @options } = device
    debug 'on config', @options

  start: (device) =>
    { @uuid } = device
    debug 'started', @uuid

module.exports = Http
