chai = require 'chai'
assert = chai.assert

Encoder = require '../../src/encoder'

describe 'Encoder', () ->

  describe 'with 128 bits', () ->
    buf = new Buffer 16
    buf.writeDoubleBE 0xA5264261F1271335, 0
    buf.writeDoubleBE 0xC64141C613A0C8FF, 8
    encoded = Encoder.encode buf
    describe '#encode', () ->
      it 'should create a hailstone-base85 value from a buffer', () ->
        assert encoded?, 'the encoded value was created'
      it 'should be a string type', () ->
        assert typeof(encoded) is 'string', 'a string was created'
      it 'should be a 20 character long string', () ->
        assert encoded.length is 20, 'the string is 20 characters long'
    describe '#decode', () ->
      decoded = Encoder.decode encoded
      it 'should equal the original value', () ->
        assert buf.equals(decoded), 'the decoded buffer is the original value'

  describe 'with 64 bits', () ->
    buf = new Buffer 8
    buf.writeDoubleBE 0xA5264261F1271335, 0
    encoded = Encoder.encode buf
    describe '#encode', () ->
      it 'should create a hailstone-base85 value from a buffer', () ->
        assert encoded?, 'the encoded value was created'
      it 'should be a string type', () ->
        assert typeof(encoded) is 'string', 'a string was created'
      it 'should be a 10 character long string', () ->
        assert encoded.length is 10, 'the string is 10 characters long'
    describe '#decode', () ->
      decoded = Encoder.decode encoded
      it 'should equal the original value', () ->
        assert buf.equals(decoded), 'the decoded buffer is the original value'