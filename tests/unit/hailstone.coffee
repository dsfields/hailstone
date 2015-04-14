chai = require 'chai'
assert = chai.assert

Identifier = require '../../src/hailstone'
domain = 128
type = 64

describe 'Hailstone', () ->

  describe '#create', () ->
    it 'should create an identifier given a domain and type', () ->
      hailstone = Identifier.create domain, type
      assert hailstone?, 'an identifier was created'

  describe '#constructor', () ->
    it 'should parse given a hailstone-base85 value', () ->
      hailstone = Identifier.create domain, type
      id = new Identifier hailstone
      assert id?, 'the identifier was parsed'
    it 'should extract domain when parsing a hailstone-base85 value', () ->
      hailstone = Identifier.create domain, type
      id = new Identifier hailstone
      assert id.domain is domain, 'the domain was extracted'
    it 'should extract type when parsing a hailstone-base85 value', () ->
      hailstone = Identifier.create domain, type
      id = new Identifier hailstone
      assert id.type is type, 'the type was extracted'

  describe '#toString', () ->
    it 'should create a string', () ->
      hailstone = Identifier.create domain, type
      id = new Identifier hailstone
      string = id.toString()
      assert typeof(string) is 'string', 'string created'
    it 'should create the same string as the originally generated value', () ->
      hailstone = Identifier.create domain, type
      id = new Identifier hailstone
      string = id.toString()
      assert string is hailstone, 'original value created'