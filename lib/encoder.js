
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
This code is based on Alexander Olsson's
(https://github.com/noseglid) base85 encoder
module (https://github.com/noseglid/base85).
Some key differences are:
* The code has been optimized for the hailstone
use case.
* Uses a modified, non-canon alphabet.
 */

/*
  A slightly modified RFC 1924 alphabet, to be a
  bit more URL-friendly. All values are in ASCII
  order, which shifts the enc table around a bit
  compared to standard ASCII base85.
 */
var _alphabet, bignum;

_alphabet = {
  enc: {
    0: '!',
    1: '$',
    2: '%',
    3: '(',
    4: ')',
    5: '*',
    6: ',',
    7: '-',
    8: '.',
    9: '0',
    10: '1',
    11: '2',
    12: '3',
    13: '4',
    14: '5',
    15: '6',
    16: '7',
    17: '8',
    18: '9',
    19: ';',
    20: '<',
    21: '=',
    22: '>',
    23: '@',
    24: 'A',
    25: 'B',
    26: 'C',
    27: 'D',
    28: 'E',
    29: 'F',
    30: 'G',
    31: 'H',
    32: 'I',
    33: 'J',
    34: 'K',
    35: 'L',
    36: 'M',
    37: 'N',
    38: 'O',
    39: 'P',
    40: 'Q',
    41: 'R',
    42: 'S',
    43: 'T',
    44: 'U',
    45: 'V',
    46: 'W',
    47: 'X',
    48: 'Y',
    49: 'Z',
    50: '[',
    51: ']',
    52: '^',
    53: '_',
    54: '`',
    55: 'a',
    56: 'b',
    57: 'c',
    58: 'd',
    59: 'e',
    60: 'f',
    61: 'g',
    62: 'h',
    63: 'i',
    64: 'j',
    65: 'k',
    66: 'l',
    67: 'm',
    68: 'n',
    69: 'o',
    70: 'p',
    71: 'q',
    72: 'r',
    73: 's',
    74: 't',
    75: 'u',
    76: 'v',
    77: 'w',
    78: 'x',
    79: 'y',
    80: 'z',
    81: '{',
    82: '|',
    83: '}',
    84: '~'
  }
};

(function() {
  var _, decKeys, decValues;
  _ = require('lodash');
  decKeys = _.map(_.values(_alphabet.enc), function(v) {
    return v.charCodeAt(0);
  });
  decValues = _.map(_.keys(_alphabet.enc), function(v) {
    return parseInt(v);
  });
  return _alphabet.dec = _.zipObject(decKeys, decValues);
})();

bignum = require('bignum');

module.exports = {

  /*
    Convert a Node Buffer to a hailstone-base85
    string.
   */
  encode: function(buf) {
    var enc, i, len, num, val;
    if (!(buf instanceof Buffer)) {
      return void 0;
    }
    num = bignum.fromBuffer(buf);
    len = Math.floor(buf.length / 4) * 5;
    enc = _alphabet.enc;
    val = [];
    i = 0;
    while (i < len) {
      val.push(enc[num.mod(0x55).toNumber()]);
      num = num.div(0x55);
      i++;
    }
    return val.reverse().join('');
  },

  /*
    Convert a hailstone-base85 string into a Node
    Buffer.
   */
  decode: function(val) {
    var dec, i, num, reduce;
    if (typeof val !== 'string') {
      return void 0;
    }
    dec = _alphabet.dec;
    i = 0;
    reduce = function(memo, el) {
      var char, contrib, fact;
      char = bignum(dec[el.charCodeAt(0)]);
      fact = bignum(0x55).pow(i++);
      contrib = char.mul(fact);
      return memo.add(contrib);
    };
    num = val.split('').reduceRight(reduce, bignum(0));
    return num.toBuffer();
  }
};

//# sourceMappingURL=maps/encoder.js.map