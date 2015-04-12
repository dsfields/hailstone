###
  A slightly modified RFC 1924 alphabet, to be a 
  bit more URL-friendly. All values are in ASCII 
  order, which shifts the enc table around a bit 
  compared to standard ASCII base85.
###
_alphabet =
  enc:
    0: '!'
    1: '$'
    2: '%'
    3: '('
    4: ')'
    5: '*'
    6: ','
    7: '-'
    8: '.'
    9: '0'
    10: '1'
    11: '2'
    12: '3'
    13: '4'
    14: '5'
    15: '6'
    16: '7'
    17: '8'
    18: '9'
    19: ';'
    20: '<'
    21: '='
    22: '>'
    23: '@'
    24: 'A'
    25: 'B'
    26: 'C'
    27: 'D'
    28: 'E'
    29: 'F'
    30: 'G'
    31: 'H'
    32: 'I'
    33: 'J'
    34: 'K'
    35: 'L'
    36: 'M'
    37: 'N'
    38: 'O'
    39: 'P'
    40: 'Q'
    41: 'R'
    42: 'S'
    43: 'T'
    44: 'U'
    45: 'V'
    46: 'W'
    47: 'X'
    48: 'Y'
    49: 'Z'
    50: '['
    51: ']'
    52: '^'
    53: '_'
    54: '`'
    55: 'a'
    56: 'b'
    57: 'c'
    58: 'd'
    59: 'e'
    60: 'f'
    61: 'g'
    62: 'h'
    63: 'i'
    64: 'j'
    65: 'k'
    66: 'l'
    67: 'm'
    68: 'n'
    69: 'o'
    70: 'p'
    71: 'q'
    72: 'r'
    73: 's'
    74: 't'
    75: 'u'
    76: 'v'
    77: 'w'
    78: 'x'
    79: 'y'
    80: 'z'
    81: '{'
    82: '|'
    83: '}'
    84: '~'
  dec:
    '!': 0
    '$': 1
    '%': 2
    '(': 3
    ')': 4
    '*': 5
    ',': 6
    '-': 7
    '.': 8
    '0': 9
    '1': 10
    '2': 11
    '3': 12
    '4': 13
    '5': 14
    '6': 15
    '7': 16
    '8': 17
    '9': 18
    ';': 19
    '<': 20
    '=': 21
    '>': 22
    '@': 23
    'A': 24
    'B': 25
    'C': 26
    'D': 27
    'E': 28
    'F': 29
    'G': 30
    'H': 31
    'I': 32
    'J': 33
    'K': 34
    'L': 35
    'M': 36
    'N': 37
    'O': 38
    'P': 39
    'Q': 40
    'R': 41
    'S': 42
    'T': 43
    'U': 44
    'V': 45
    'W': 46
    'X': 47
    'Y': 48
    'Z': 49
    '[': 50
    ']': 51
    '^': 52
    '_': 53
    '`': 54
    'a': 55
    'b': 56
    'c': 57
    'd': 58
    'e': 59
    'f': 60
    'g': 61
    'h': 62
    'i': 63
    'j': 64
    'k': 65
    'l': 66
    'm': 67
    'n': 68
    'o': 69
    'p': 70
    'q': 71
    'r': 72
    's': 73
    't': 74
    'u': 75
    'v': 76
    'w': 77
    'x': 78
    'y': 79
    'z': 80
    '{': 81
    '|': 82
    '}': 83
    '~': 84

module.exports =
  ###
    Convert a Node Buffer to a hailstone-base85 
    string.
  ###
  encode: (buf) ->
    len = buf.length
    pad = if len % 4 is 0 then 0 else 4 - len % 4
    val = ''
    for i = 0; i < len; i += 4
      int = ((buf[i] << 24) >>> 0) +
      (((if i + 1 > len then 0 else buf[i + 1]) << 16) >>> 0) +
      (((if i + 2 > len then 0 else buf[i + 2]) << 8) >>> 0) +
      (((if i + 3 > len then 0 else buf[i + 3]) << 0) >>> 0)
      block = []
      for j in [0..4]
        block.unshift _alphabet.enc[int % 85]
        int = Math.floor(int / 85)
      val += block.join ''
    val.substring 0, val.length - pad


  ###
    Convert a hailstone-base85 string into a Node 
    Buffer.
  ###
  decode: (value) ->
    return (undefined) if typeof(value) isnt 'string'
    val = new Buffer value, 'utf8'
    pad = if val.length % 5 is 0 then 0 else 5 - val.length % 5
    buf = new Buffer 4 * len / 5
    len = val.length
    writeAt = 0
    dec = _alphabet.dec
    for i = 0; i < len;
      int = dec[val[i]] * 0x31C84B1
      i++
      int += (if i >= len then 0x54 else dec[val[i]]) * 0x23E5FD
      i++
      int += (if i >= len then 0x54 else dec[val[i]]) * 0x1C39
      i++
      int += (if i >= len then 0x54 else dec[val[i]]) * 0x55
      throw new Error('Invalid hailstone-base85 value.') if 0xFFFFFFFF < int < 0x0
      buf.writeUInt32BE int, writeAt
      i++
      writeAt += 4
    buf.slice 0, writeAt - pad