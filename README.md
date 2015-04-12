# hailstone

A simple, lightweight, stateless utility for generating quasi-unique, variable length identifiers with embedded type information.  Hailstone is intended as a method of providing unique identifiers within a system

A hailstone identifier is a 64 or 128 bit value encoded using RFC 1924 base85 encoding with a slightly modified, more URL-friendly alphabet.  This results in either a fairly compact 8 or 16 character value respectively.

## Structure
A hailstone identifier consists of:

* (8-bit) header value which contains version and size information.
* (8-bit) domain identifier.
* (8-bit) type identifier.
* (40-bit) or (104-bit) instance idenfier.

The internal structure looks like this:

```
 header | domain | type   | instance
-------------------------------------------------------------
 8F     | FF     | FF     | 1FFFFFFFFFF ...or...
        |        |        | FFFFFFFFFFFFFFFFFFFFFFFFFF000000
```

### Header
The header value consists of two piece of information:

* Version: the algorithm version for the hailstone identifier.  This value takes up the first 4 bits of the header byte, which provides a maximum of 16 algorithm version (though there is currently only one.)
* Size: can be either 64 or 128, which means size only needs to utilize the 7 or 8 bit position on the header byte.

These to values are bitwise `OR`ed together for encoding, and bitwise `AND`ed when decoded.

### Domain & Type Identifiers
The domain and type identifier portions are intended to provide some additional system-specific information about entity instances the hailstone value is identifying.  Each domain identifier is specific to a system implementing hailstone, and each type identifier is specific to that domain.  All identifiers must be an unsigned integer from 0 to 255.

### Instance Identifier
A randomly selected value, which can be either 40 or 104 bits.  Hailstone uses the Node.js 'crypto.randomBytes' methods for generating random numbers.  This method is cryptographically secured, and, so, has a very low probability of collision.

## Usage
Hailstone identifiers are simple to generate...

```js
var Identifier = require('hailstone');

var domain = 42;
var type = 84;

var id = Identifier.create(domain, type);

console.log(id);
```

Each identifier can then be parsed to extract domain and type information...

```js
var Identifier = require('hailstone');

var id = new Identifier(identifierString);

console.log(id.domain);
console.log(id.type);
```

### API Documentation
* `new Hailstone(value)`: parses a hailstone value so that the version, size, domain, and type information can be extracted.
  * Parameters:
    * `value`: a hailstone-base85 string or a Node.js `Buffer` containing a hailstone identifer.

* `Hailstone.create(domain, type, [options, callback])`: creates a new hailstone identifier for the specified domain and type.
  * Parameters:
    * `domain`: an unsigned intenger value 0-255.  Each domain identifier should be unique to given a domain, microservice, namespace, etc within a single system.
    * `type`: an unsigned intenger value 0-255.  Each type identifier should be unique to a given entity type within the domain.
    * `options`: optional values for controlling behavior.
      * `length`: the total number of bits of the hailstone identifier.  Can be 64 or 128.  The default is 128.
    * `callback`: A standard EventLoop callback function pointer.  Node.js's crypto RNG method relies on an pool of entropy values to ensure randomness and distribution. It is indeed possible for the entropy pool can become exhausted.  Node.js crypto will throw an error if this happens. To prevent errors, a callback function parameter is provided, thus allowing calling threads a method to wait in a non-blocking manner for the Node.js crypto to gather sufficient entropy to generate a PRN.

* `Hailstone.createAsync(domain, type, options)`: The same as the aforementioned `create()` method, but returns a then-able promise.

* `id.toBuffer()`: converts an instance of `Hailstone` to a Node.js `Buffer`.

* `id.toString()`: converts an instance of `Hailstone` to a hailstone-base85 encoded string.

* `id.domain`: the domain identifier of the `Hailstone` instance.

* `id.type`: the entity type identifier of the `Hailstone` instance.

## Chances of Collision
The probability of id collisions within a single system are negligable.  The pseudo-random number portion of each Hailstone identifier is generated using the Node.js cryptographic PRNG, which has more than adequate distribution to avoid collisions.  The 64-bit version utilizes 40 bits for the PRN, which translates into a 1 in 2,199,023,255,551 chance of collision per domain and entity pairing.  The 128 bit version utilies 104 bits for the PRN, which translates into a 1 in 340,282,366,920,938,463,463,374,607,431,751,434,240 chance of collision per domain and type pariing.