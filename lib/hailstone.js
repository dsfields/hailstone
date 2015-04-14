
/*
Copyright (c) 2015 Daniel Fields

Permission is hereby granted, free of charge, to
any person obtaining a copy of this software and
associated documentation files (the "Software"),
to deal in the Software without restriction,
including without limitation the rights to use,
copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is
furnished to do so, subject to the following
conditions:

The above copyright notice and this permission
notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT
WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/*
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
 */
var Hailstone, Promise, _createBuffer, _encoder, _readBuffer, _rng, _validateTypeId;

Promise = require('bluebird');


/*
  Moderately fast, and very well distributed RNG.
  More than sufficient for random id generation,
  and is used most Node-based UUID generators.
 */

_rng = require('crypto').randomBytes;


/*
  Native hailstone base85 encoder.
 */

_encoder = require('./encoder');


/*
  Take all of the hailstorm identifier values,
  and stuff them in a Node buffer.
 */

_createBuffer = function(ver, len, dom, et, inst) {
  var buf, header, size;
  size = len / 8;
  header = (ver - 1) | len;
  buf = new Buffer(size);
  buf.writeUInt8(header, 0);
  buf.writeUInt8(dom, 1);
  buf.writeUInt8(et, 2);
  inst.copy(buf, 3, 0, inst.length);
  return buf;
};


/*
  Reads a Node buffer and outputs a JSON object
  containing the identifier's properties
  contained therein.
 */

_readBuffer = function(buf) {
  var buflen, dom, et, identifier, inst, len, meta, size, ver;
  buflen = buf.length;
  if (buflen !== 8 && buflen !== 16) {
    throw new Error('Invalid buffer length');
  }
  meta = buf.readUInt8(0);
  ver = (meta & 0xF) + 1;
  len = meta & 0xC0;
  dom = buf.readUInt8(1);
  et = buf.readUInt8(2);
  size = len === 64 ? 5 : 13;
  inst = new Buffer(size);
  buf.copy(inst, 0, 3, buflen);
  identifier = {
    version: ver,
    length: len,
    domain: dom,
    type: et,
    instance: inst
  };
  console.log(identifier);
  return identifier;
};


/*
  Type ids must be an integer value of a
  particular size.
 */

_validateTypeId = function(value, max, argName) {
  var msg, valid;
  valid = (value != null) && typeof value === 'number' && value % 1 === 0 && (max >= value && value >= 0);
  if (!valid) {
    msg = "Value of " + argName + " must be an integer between 0 and " + max + ", but was " + value + ".";
    throw new Error(msg);
  }
};


/**
  Create an instance of Hailstone. Represents a
  quasi-unique identifier that embeds the domain
  and type information of a target entity
  instance.

  The domain and type identifiers are represented
  as 8-bit, unsigned integer values.  Each value
  is owned by the implementing system.  Thus,
  hailstone identifiers are not intended to be
  globally unique.

  @arg {string|Buffer} - a hailstone-base85
    encoded string or Node Buffer containing a
    serialized hailstorm identifier.
 */

Hailstone = (function() {
  function Hailstone(value) {
    var buffer, ref;
    if (value == null) {
      throw new Error('A value must be provided.');
    }
    if (buffer instanceof Buffer) {
      buffer = value;
    }
    if (buffer == null) {
      buffer = _encoder.decode(value);
    }
    if (buffer == null) {
      throw new Error('The value must a Buffer or string.');
    }
    ref = _readBuffer(buffer), this.version = ref.version, this.length = ref.length, this.domain = ref.domain, this.type = ref.type, this.instance = ref.instance;
  }


  /**
    Converts the identifier into a Node Buffer.
   */

  Hailstone.prototype.toBuffer = function() {
    return _createBuffer(this.version, this.length, this.domain, this.type, this.instance);
  };


  /**
    Converts the identifier into a URL-friendly,
    base85-encoded string.
   */

  Hailstone.prototype.toString = function() {
    var buf, enc;
    buf = this.toBuffer();
    return enc = _encoder.encode(buf);
  };


  /**
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
   */

  Hailstone.create = function(domain, type, options, callback) {
    var buf, cb, dom, enc, et, len, ref, size, val;
    _validateTypeId(domain, 0xFF, 'domain');
    _validateTypeId(type, 0xFF, 'type');
    len = (ref = options != null ? options.length : void 0) != null ? ref : 128;
    if (len !== 64 && len !== 128) {
      throw new Error('Length must be 64 or 128');
    }
    size = len === 64 ? 5 : 13;
    cb = callback;
    dom = domain;
    et = type;
    if (cb != null) {
      _rng(size, function(err, result) {
        var buf, enc;
        if (err) {
          return cb(err);
        } else {
          buf = _createBuffer(1, len, dom, et, result);
          enc = _encoder.encode(buf);
          return cb(null, enc);
        }
      });
    } else {
      val = _rng(size);
      buf = _createBuffer(1, len, dom, et, val);
      enc = _encoder.encode(buf);
    }
    return enc;
  };


  /**
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
   */

  Hailstone.createAsync = function(domain, type, options) {
    var d, et, promise, sm;
    d = domain;
    et = type;
    sm = small;
    return promise = new Promise(function(resolve, reject) {
      var rej, res;
      res = resolve;
      rej = reject;
      return this.create(d, et, sm, function(err, result) {
        if (err != null) {
          return rej(err);
        } else {
          return res(result);
        }
      });
    });
  };

  return Hailstone;

})();

module.exports = Hailstone;

//# sourceMappingURL=maps/hailstone.js.map