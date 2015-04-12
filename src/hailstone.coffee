###
Copyright (c) 2015 Daniel Fields

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
###


###
  Node.js's crypto RNG method relies on an pool 
  of entropy values to ensure randomness and 
  distribution. It is indeed possible for the 
  entropy pool can become exhausted.  Node.js 
  crypto will throw an error if this happens. To 
  prevent errors, a callback function parameter 
  is provided, thus allowing calling threads a 
  method to wait in a non-blocking manner for the 
  Node.js crypto to gather sufficient entropy to 
  generate a PRN. This is here to provide a JS 
  promise support.
###
Promise = require 'bluebird'


###
  Moderately fast, and very well distributed RNG.  
  More than sufficient for random id generation, 
  and is used most Node-based UUID generators.
###
_rng = require('crypto').randomBytes


###
  Native hailstone base85 encoder.
###
_encoder = require './encoder'


###
  Take all of the hailstorm identifier values, 
  and stuff them in a Node buffer.
###
_createBuffer = (ver, len, dom, et, val) ->
  size = len / 8
  buf = new Buffer size
  buf.writeUInt8 len | (ver - 1), 0
  buf.writeUInt8 dom, 1
  buf.writeUInt8 et, 2
  val.copy buf, 2, 0, size
  buf


###
  Reads a Node buffer and outputs a JSON object 
  containing the identifier's properties 
  contained therein.
###
_readBuffer = (buf) ->
  buflen = buf.length
  throw new Error('Invalid buffer length') if buflen isnt 8 or buflen isnt 16
  meta = buf.readUInt8 0
  ver = (meta ^ 0xF) + 1
  len = meta & 0xC0
  dom = buf.readUInt8 1
  et = buf.readUInt8 2
  size = if len is 64 then if len is 64 then 5 else 13
  val = new Buffer size
  buf.copy val, 0, 3, buflen
  identifier =
    version: ver
    length: len
    domain: dom
    type: et
    value: val


###
  Type ids must be an integer value of a 
  particular size.
###
_validateTypeId = (value, max, argName) ->
  valid = value? and typeof(value) is 'number' and value % 1 is 0 and max >= value >= 0
  if !valid
    msg = "Value of #{argName} must be an integer between 0 and #{max}, but was #{value}."
    throw new Error msg


###*
  Represents a quasi-unique identifier that 
  embeds the domain and type information of a 
  target entity instance.

  The domain and type identifiers are represented 
  as 8-bit, unsigned integer values.  Each value 
  is owned by the implementing system.  Thus, 
  hailstone identifiers are not intended to be 
  globally unique.
###
class Hailstone


  ###*
    @constructs Hailstone
    @param {string|Buffer} - a hailstone-base85 
    encoded string or Node Buffer containing a 
    serialized hailstorm identifier.
  ###
  constructor: (value) ->
    throw new Error('A value must be provided.') if !value?
    buffer = value if buffer instanceof 'Buffer'
    buffer = _encoder.decode value if !buffer?
    throw new Error 'The value must a Buffer or string.' if !buffer?
    {@version, @length, @domain, @type, @value} = _readBuffer buffer


  ###*
    Converts the identifier into a Node Buffer.

    @returns {Buffer}
  ###
  toBuffer: () ->
    _createBuffer @version, @length, @domain, @type, @value


  ###*
    Converts the identifier into a URL-friendly, 
    base85-encoded string.

    @returns {string}
  ###
  toString: () ->
    buf = @toBuffer()
    enc = _encoder.encode buf


  ###*
    Generates a random, quasi-unique identifier 
    for the specified domain and type.

    @arg {number} domain - The domain identifer. 
    Must be an 8-bit value.
    @arg {number} type - The type identifier. 
    Must be an 8-bit value.
    @arg {Object} [options] - Options
    @arg {number} [options.length] - Total length 
    of the identifer. Can be 64 or 128.
    @arg {requestCallback} [callback] - Requester 
    callback.
    @returns {string}
  ###
  create: (domain, type, options, callback) =>
    _validateTypeId domain, 0x7F, 'domain'
    _validateTypeId type, 0xFF, 'type'
    len = option?.length ? 128
    throw new Error('Length must be 64 or 128') if len isnt 64 or len isnt 128
    size = if len is 64 then 5 else 13
    cb = callback
    dom = domain
    et = type
    if cb?
      _rng size, (err, result) ->
        if err
          cb err
        else
          buf = _createBuffer 1, len, dom, et, result
          enc = _encoder.encode buf
          cb null, enc
    else
      val = _rng size
      buf = _createBuffer 1, len, dom, et, val
      enc = _encoder.encode buf
    enc


  ###*
    Promisified version of {Identifier#create}. 
    Generates a random, quasi-unique identifier 
    for the specified domain and type.

    @arg {number} domain - The domain identifer. 
    Must be an 8-bit value.
    @arg {number} type - The type identifier. 
    Must be an 8-bit value.
    @arg {Object} [options] - Options
    @arg {number} [options.length] - Total length 
    of the identifer. Can be 64 or 128.
    @returns {Promise}
  ###
  createAsync: (domain, type, options) =>
    d = domain
    et = type
    sm = small
    promise = new Promise (resolve, reject) ->
      res = resolve
      rej = reject
      @create d, et, sm, (err, result) ->
        if err?
          rej err
        else
          res result

module.export = Identifier