class HttpRequestJob
  constructor: ({@connector}) ->
    throw new Error 'HttpRequestJob requires connector' unless @connector?

  do: ({data}, callback) =>
    return callback @_userError(422, 'data is required') unless data?
    {authentication} = data
    requestOptions = @connector.formatRequest data

    return callback @_userError(422, 'data.authentication is required') unless authentication?
    return callback @_userError(422, 'data.requestOptions.uri is required') unless requestOptions?.uri?
    @connector.sendNtlmRequest authentication, requestOptions, callback

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = HttpRequestJob
