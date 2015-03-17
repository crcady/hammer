describe("Combinator tests", function()
  local hammer

  setup(function()
    hammer = require("hammer")
  end)

  teardown(function()
    hammer = nil
  end)
  
  describe("Token tests", function()
    local parser = hammer.token("95" .. string.char(0xa2))
    it("parses a token", function()
      local ret = parser:parse("95" .. string.char(0xa2))
      assert.are.same("95" .. string.char(0xa2), ret.ast.bytes)
    end)
    it("does not parse an incomplete token", function()
      local ret = parser:parse("95")
      assert.is_falsy(ret)
    end)
  end)

  describe("Char tests", function()
    local parser = hammer.ch(0xa2)
    it("parses a matching char", function()
      local ret = parser:parse(string.char(0xa2))
      assert.are.same(string.char(0xa2), ret.ast.uint)
    end)
    it("rejects a non-matching char", function()
      local ret = parser:parse(string.char(0xa3))
      assert.is_falsy(ret)
    end)
  end)

  describe("Char range tests", function()
    local parser = hammer.ch_range("a", "c")
    it("parses a char in the range", function()
      local ret = parser:parse("b")
      assert.are.same("b", ret.ast.uint)
    end)
    it("rejects a char outside the range", function()
      local ret = parser:parse("d")
      assert.is_falsy(ret)
    end)
  end)

  describe("Signed 64-bit int tests", function()
    local parser = hammer.int64()
    it("parses a valid 64-bit int", function()
      local ret = parser:parse(string.char(0xff, 0xff, 0xff, 0xfe, 0x00, 0x00, 0x00, 0x00))
      assert.are.same(-0x200000000, ret.ast.sint)
    end)
    it("does not parse an invalid 64-bit int", function()
      local ret = parser:parse(string.char(0xff, 0xff, 0xff, 0xfe, 0x00, 0x00, 0x00))
      assert.is_falsy(ret)
    end)
  end)

  describe("Signed 32-bit int tests", function()
    local parser = hammer.int32()
    it("parses a valid 32-bit int", function()
      local ret = parser:parse(string.char(0xff, 0xfe, 0x00, 0x00))
      assert.are.same(-0x20000, ret.ast.sint)
    end)
    it("does not parse an invalid 32-bit int", function()
      local ret = parser:parse(string.char(0xff, 0xfe, 0x00))
      assert.is_falsy(ret)
    end)
  end)

  describe("Signed 16-bit int tests", function()
    local parser = hammer.int16()
    it("parses a valid 16-bit int", function()
      local ret = parser:parse(string.char(0xfe, 0x00))
      assert.are.same(-0x200, ret.ast.sint)
    end)
    it("does not parse an invalid 16-bit int", function()
      local ret = parser:parse(string.char(0xfe))
      assert.is_falsy(ret)
    end)
  end)

  describe("Signed 8-bit int tests", function()
    local parser = hammer.int8()
    it("parses a valid 8-bit int", function()
      local ret = parser:parse(string.char(0x88))
      assert.are.same(-0x78, ret.ast.sint)
    end)
    it("does not parse an invalid 8-bit int", function()
      local ret = parser:parse("")
      assert.is_falsy(ret)
    end)
  end)

  describe("Unsigned 64-bit int tests", function()
    local parser = hammer.uint64()
    it("parses a valid 64-bit unsigned int", function()
      local ret = parser:parse(string.char(0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00))
      assert.are.same(0x200000000, ret.ast.uint)
    end)
    it("does not parse an invalid 64-bit unsigned int", function()
      local ret = parser:parse(string.char(0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00))
      assert.is_falsy(ret)
    end)
  end)

  describe("Unsigned 32-bit int tests", function()
    local parser = hammer.uint32()
    it("parses a valid 32-bit unsigned int", function()
      local ret = parser:parse(string.char(0x00, 0x02, 0x00, 0x00))
      assert.are.same(0x20000, ret.ast.uint)
    end)
    it("does not parse an invalid 32-bit unsigned int", function()
      local ret = parser:parse(string.char(0x00, 0x02, 0x00))
      assert.is_falsy(ret)
    end)
  end)

  describe("Unsigned 16-bit int tests", function()
    local parser = hammer.uint16()
    it("parses a valid 16-bit unsigned int", function()
      local ret = parser:parse(string.char(0x02, 0x00))
      assert.are.same(0x200, ret.ast.uint)
    end)
    it("does not parse an invalid 16-bit unsigned int", function()
      local ret = parser:parse(string.char(0x02))
      assert.is_falsy(ret)
    end)
  end)

  describe("Unsigned 8-bit int tests", function()
    local parser = hammer.uint8()
    it("parses a valid 8-bit unsigned int", function()
      local ret = parser:parse(string.char(0x78))
      assert.are.same(0x78, ret.ast.uint)
    end)
    it("does not parse an invalid 8=bit unsigned int", function()
      local ret = parser:parse("")
      assert.is_falsy(ret)
    end)
  end)

  describe("Integer range tests", function()
    local parser = hammer.int_range(hammer.uint8(), 3, 10)
    it("parses a value in the range", function()
      local ret = parser:parse(string.char(0x05))
      assert.are.same(5, ret.ast.uint)
    end)
    it("does not parse a value outside the range", function()
      local ret = parser:parse(string.char(0xb))
      assert.is_falsy(ret)
    end)
  end)

  describe("Whitespace tests", function()
    local parser = hammer.whitespace(hammer.ch("a"))
    local parser2 = hammer.whitespace(hammer.end_p())
    it("parses a string with no whitespace", function()
      local ret = parser:parse("a")
      assert.are.same("a", ret.ast.uint)
    end)
    it("parses a string with a leading space", function()
      local ret = parser:parse(" a")
      assert.are.same("a", ret.ast.uint)
    end)
    it("parses a string with leading spaces", function()
      local ret = parser:parse("  a")
      assert.are.same("a", ret.ast.uint)
    end)
    it("parses a string with a leading tab", function()
      local ret = parser:parse("\ta")
      assert.are.same("a", ret.ast.uint)
    end)
    it("does not parse a string with a leading underscore", function()
      local ret = parser:parse("_a")
      assert.is_falsy(ret)
    end)
    it("parses an empty string", function()
      local ret = parser2:parse("")
      assert.are.same(nil, ret.ast)
    end)
    it("parses a whitespace-only string", function()
      local ret = parser2:parse("  ")
      assert.are.same(nil, ret.ast)
    end)
    it("does not parse a string with leading whitespace and a trailing character", function()
      local ret = parser2:parse("  x")
      assert.is_falsy(ret)
    end)
  end)

  describe("Leftmost-parser tests", function()
    local parser = hammer.left(hammer.ch("a"), hammer.ch(" "))
    it("parses the leftmost character", function()
      local ret = parser:parse("a ")
      assert.are.same("a", ret.ast.uint)
    end)
    it("does not parse a string that is too short", function()
      local ret = parser:parse("a")
      assert.is_falsy(ret)
    end)
    it("does not parse a string that starts with the wrong character", function()
      local ret = parser:parse(" ")
      assert.is_falsy(ret)
    end)
    it("does not parse a string with the wrong character in the second place", function()
      local ret = parser:parse("ab")
      assert.is_falsy(ret)
    end)
  end)

  describe("Rightmost-parser tests", function()
    local parser = hammer.right(hammer.ch(" "), hammer.ch("a"))
    it("parses the rightmost character", function()
      local ret = parser:parse(" a")
      assert.are.same("a", ret.ast.uint)
    end)
    it("does not parse a string that starts with the wrong character", function()
      local ret = parser:parse("a")
      assert.is_falsy(ret)
    end)
    it("does not parse a string that is too short", function()
      local ret = parser:parse(" ")
      assert.is_falsy(ret)
    end)
    it("does not parse a string with the characters in the wrong order", function()
      local ret = parser:parse("ba")
      assert.is_falsy(ret)
    end)
  end)

  describe("Middle-parser tests", function()
    local parser = hammer.middle(hammer.ch(" "), hammer.ch("a"), hammer.ch(" "))
    it("parses the middle character", function()
      local ret = parser:parse(" a ")
      assert.are.same("a", ret.ast.uint)
    end)
    it("does not parse a string that is too short", function()
      local ret = parser:parse("a")
      assert.is_falsy(ret)
      ret = parser:parse(" ")
      assert.is_falsy(ret)
      ret = parser:parse(" a")
      assert.is_falsy(ret)
      ret = parser:parse("a ")
      assert.is_falsy(ret)
    end)
    it("does not parse a string with the wrong character in the middle", function()
      ret = parser:parse(" b ")
      assert.is_falsy(ret)
    end)
    it("does not parse a string that starts with the wrong character", function()
      ret = parser:parse("ba ")
      assert.is_falsy(ret)
    end)
    it("does not parse a string that ends with the wrong character", function()
      ret = parser:parse(" ab")
      assert.is_falsy(ret)
    end)
  end)

  describe("Semantic action tests", function()
    local function upcase(result, user_data)
      local chars = result.ast.seq
      local ret = ""
      for i, v in ipairs(chars)
        do ret = ret .. string.char(v.uint):upper()
      end
      return ret
    end
    local parser = hammer.action(hammer.sequence(hammer.choice(hammer.ch("a"), hammer.ch("A")), hammer.choice(hammer.ch("b"), hammer.ch("B"))), upcase, nil)
    it("converts a lowercase 'ab' to uppercase", function()
      local ret = parser:parse("ab")
      assert.are.same({"A", "B"}, ret.ast.seq)
    end)
    it("accepts an uppercase 'AB' unchanged", function()
      local ret = parser:parse("AB")
      assert.are.same({"A", "B"}, ret.ast.seq)
    end)
    it("rejects strings that don't match the underlying parser", function()
      local ret = parser:parse("XX")
      assert.is_falsy(ret)
    end)
  end)

  describe("Character set membership tests", function()
    local parser = hammer.in_({"a", "b", "c"})
    it("parses a character that is in the included set", function()
      local ret = parser:parse("b")
      assert.are.same("b", ret.ast.uint)
    end)
    it("does not parse a character that is not in the included set", function()
      local ret = parser:parse("d")
      assert.is_falsy(ret)
    end)
  end)

  describe("Character set non-membership tests", function()
    local parser = hammer.not_in({"a", "b", "c"})
    it("parses a character that is not in the excluded set", function()
      local ret = parser:parse("d")
      assert.are.same("d", ret.ast.uint)
    end)
    it("does not parse a character that is in the excluded set", function()
      local ret = parser:parse("a")
      assert.is_falsy(ret)
    end)
  end)

  describe("End-of-input tests", function()
    local parser = hammer.sequence(hammer.ch("a"), hammer.end_p())
    it("parses a string that ends where it is expected to", function()
      local ret = parser:parse("a")
      assert.are.same({"a"}, ret.ast.seq)
    end)
    it("does not parse a string that is too long", function()
      local ret = parser:parse("aa")
      assert.is_falsy(ret)
    end)
  end)

  describe("Bottom parser tests", function()
    local parser = hammer.nothing_p()
    it("always fails", function()
      local ret = parser:parse("a")
      assert.is_falsy(ret)
    end)
  end)

  describe("Parser sequence tests", function()
    local parser = hammer.sequence(hammer.ch("a"), hammer.ch("b"))
    local parser2 = hammer.sequence(hammer.ch("a"), hammer.whitespace(hammer.ch("b")))
    it("parses a string matching the sequence", function()
      local ret = parser:parse("ab")
      assert.are.same({"a", "b"}, ret.ast.seq)
    end)
    it("does not parse a string that is too short", function()
      local ret = parser:parse("a")
      assert.is_falsy(ret)
    end)
    it("does not parse a string with the sequence out of order", function()
      local ret = parser:parse("ba")
      assert.is_falsy(ret)
    end)
    it("parses a whitespace-optional string with no whitespace", function()
      local ret = parser2:parse("ab")
      assert.are.same({"a", "b"}, ret.ast.seq)
    end)
    -- it("parses a whitespace-optional string containing whitespace", function()
    --   local ret = parser:parse("a b")
    --   assert.are.same({"a", "b"}, ret.ast.seq) -- this is the line that segfaults
    --   print("in sequence")
    --   ret = parser:parse("a  b")
    --   assert.are.same({"a", "b"}, ret.ast.seq)
    -- end)
  end)

  describe("Choice-of-parsers tests", function()
    local parser = hammer.choice(hammer.ch("a"), hammer.ch("b"))
    it("parses a character in the choice set", function()
      local ret = parser:parse("a")
      assert.are.same("a", ret.ast.uint)
      ret = parser:parse("b")
      assert.are.same("b", ret.ast.uint)
    end)
    it("does not parse a character not in the choice set", function()
      local ret = parser:parse("c")
      assert.is_falsy(ret)
    end)
  end)

  describe("X-but-not-Y tests", function()
    local parser = hammer.butnot(hammer.ch("a"), hammer.token("ab"))
    local parser2 = hammer.butnot(hammer.ch_range("0", "9"), hammer.ch("6"))
    it("succeeds when 'a' matches but 'ab' doesn't", function()
      local ret = parser:parse("a")
      assert.are.same("a", ret.ast.uint)
      ret = parser:parse("aa")
      assert.are.same("a", ret.ast.uint)
    end)
    it("fails when p2's result is longer than p1's", function()
      local ret = parser:parse("ab")
      assert.is_falsy(ret)
    end)
    it("fails when p2's result is the same length as p1's", function()
      local ret = parser2:parse("6")
      assert.is_falsy(ret)
    end)
  end)

  describe("Difference-of-parsers tests", function()
    local parser = hammer.difference(hammer.token("ab"), hammer.ch("a"))
    it("succeeds when 'ab' matches and its result is longer than the result for 'a'", function()
      local ret = parser:parse("ab")
      assert.are.same("ab", ret.ast.bytes)
    end)
    it("fails if 'ab' doesn't match", function()
      local ret = parser:parse("a")
      assert.is_falsy(ret)
    end)
  end)

  describe("XOR-of-parsers tests", function()
    local parser = hammer.xor(hammer.ch_range("0", "6"), hammer.ch_range("5", "9"))
    it("parses a value only in the first range", function()
      local ret = parser:parse("0")
      assert.are.same("0", ret.ast.uint)
    end)
    it("parses a value only in the second range", function()
      local ret = parser:parse("9")
      assert.are.same("9", ret.ast.uint)
    end)
    it("does not parse a value inside both ranges", function()
      local ret = parser:parse("5")
      assert.is_falsy(ret)
    end)
    it("does not parse a value outside the range", function()
      local ret = parser:parse("a")
      assert.is_falsy(ret)
    end)
  end)

  describe("Kleene * tests", function()
    local parser = hammer.many(hammer.choice(hammer.ch("a"), hammer.ch("b")))
    it("parses an empty string", function()
      local ret = parser:parse("")
      assert.are.same({}, ret.ast.seq)
    end)
    it("parses a single repetition of the pattern", function()
      local ret = parser:parse("a")
      assert.are.same({"a"}, ret.ast.seq)
      ret = parser:parse("b")
      assert.are.same({"b"}, ret.ast.seq)
    end)
    it("parses multiple repetitions of the pattern", function()
      local ret = parser:parse("aabbaba")
      assert.are.same({"a", "a", "b", "b", "a", "b", "a"}, ret.ast.seq)
    end)
  end)

  describe("Kleene + tests", function()
    local parser = hammer.many1(hammer.choice(hammer.ch("a"), hammer.ch("b")))
    it("does not parse an empty string", function()
      local ret = parser:parse("")
      assert.is_falsy(ret)
    end)
    it("parses a single repetition of the pattern", function()
      local ret = parser:parse("a")
      assert.are.same({"a"}, ret.ast.seq)
      ret = parser:parse("b")
      assert.are.same({"b"}, ret.ast.seq)
    end)
    it("parses multiple repetitions of the pattern", function()
      local ret = parser:parse("aabbaba")
      assert.are.same({"a", "a", "b", "b", "a", "b", "a"}, ret.ast.seq)
    end)
    it("does not parse a string that does not start with one of the patterns to repeat", function()
      local ret = parser:parse("daabbabadef")
      assert.is_falsy(ret)
    end)
  end)

  describe("Fixed-number-of-repetitions tests", function()
    local parser = hammer.repeat_n(hammer.choice(hammer.ch("a"), hammer.ch("b")), 2)
    it("does not parse a string without enough repetitions", function()
      local ret = parser:parse("adef")
      assert.is_falsy(ret)
    end)
    it("parses a string containing the correct number of repetitions", function()
      local ret = parser:parse("abdef")
      assert.are.same({"a", "b"}, ret.ast.seq)
    end)
    it("does not parse a string that does not start with a character in the repetition set", function()
      local ret = parser:parse("dabdef")
      assert.is_falsy(ret)
    end)
  end)

  describe("Kleene ? tests", function()
    local parser = hammer.sequence(hammer.ch("a"), hammer.optional(hammer.choice(hammer.ch("b"), hammer.ch("c"))), hammer.ch("d"))
    it("parses a string containing either optional character", function()
      local ret = parser:parse("abd")
      assert.are.same({"a", "b", "d"}, ret.ast.seq)
      ret = parser:parse("acd")
      assert.are.same({"a", "c", "d"}, ret.ast.seq)
    end)
    it("parses a string missing one of the optional characters", function()
      local ret = parser:parse("ad")
      assert.are.same({"a", {}, "d"}, ret.ast.seq)
    end)
    it("does not parse a string containing a character not among the optional ones", function()
      local ret = parser:parse("aed")
      assert.is_falsy(ret.ast)
    end)
  end)

  describe("'ignore' decorator tests", function()
    local parser = hammer.sequence(hammer.ch("a"), hammer.ignore(hammer.ch("b")), hammer.ch("c"))
    it("parses a string containing the pattern to ignore, and leaves that pattern out of the result", function()
      local ret = parser:parse("abc")
      assert.are.same({"a", "c"}, ret.ast.seq)
    end)
    it("does not parse a string not containing the pattern to ignore", function()
      local ret = parser:parse("ac")
      assert.is_falsy(ret)
    end)
  end)

  describe("Possibly-empty separated lists", function()
    local parser = hammer.sepBy(hammer.choice(hammer.ch("1"), hammer.ch("2"), hammer.ch("3")), hammer.ch(","))
    it("parses an ordered list", function()
      local ret = parser:parse("1,2,3")
      assert.are.same({"1", "2", "3"}, ret.ast.seq)
    end)
    it("parses an unordered list", function()
      local ret = parser:parse("1,3,2")
      assert.are.same({"1", "3", "2"}, ret.ast.seq)
    end)
    it("parses a list not containing all options", function()
      local ret = parser:parse("1,3")
      assert.are.same({"1", "3"}, ret.ast.seq)
    end)
    it("parses a unary list", function()
      local ret = parser:parse("3")
      assert.are.same({"3"}, ret.ast.seq)
    end)
    it("parses an empty list", function()
      local ret = parser:parse("")
      assert.are.same({}, ret.ast.seq)
    end)
  end)

  describe("Non-empty separated lists", function()
    local parser = hammer.sepBy1(hammer.choice(hammer.ch("1"), hammer.ch("2"), hammer.ch("3")), hammer.ch(","))
    it("parses an ordered list", function()
      local ret = parser:parse("1,2,3")
      assert.are.same({"1", "2", "3"}, ret.ast.seq)
    end)
    it("parses an unordered list", function()
      local ret = parser:parse("1,3,2")
      assert.are.same({"1", "3", "2"}, ret.ast.seq)
    end)
    it("parses a list not containing all options", function()
      local ret = parser:parse("1,3")
      assert.are.same({"1", "3"}, ret.ast.seq)
    end)
    -- it("parses a unary list", function()
    --   local ret = parser:parse("3")
    --   print("in sepBy1")
    --   assert.are.same({"3"}, ret.ast.seq) -- this line also segfaults
    -- end)
    it("does not parse an empty list", function()
      local ret = parser:parse("")
      assert.is_falsy(ret)
    end)
  end)

  describe("Empty string tests", function()
    local parser = hammer.sequence(hammer.ch("a"), hammer.epsilon_p(), hammer.ch("b"))
    local parser2 = hammer.sequence(hammer.epsilon_p(), hammer.ch("a"))
    local parser3 = hammer.sequence(hammer.ch("a"), hammer.epsilon_p())
    it("parses an empty string between two characters", function()
      local ret = parser:parse("ab")
      assert.are.same({"a", "b"}, ret.ast.seq)
    end)
    it("parses an empty string before a character", function()
      local ret = parser2:parse("a")
      assert.are.same({"a"}, ret.ast.seq)
    end)
    it("parses a ", function()
      local ret = parser3:parse("a")
      assert.are.same({"a"}, ret.ast.seq)
    end)
  end)

  describe("Attribute validation tests", function()
    local function equals(result, user_data)
      return result.ast.seq.elements[0].uint == result.ast.seq.elements[1].uint
    end
    local parser = hammer.attr_bool(hammer.many1(hammer.choice(hammer.ch("a"), hammer.ch("b"))), equals)
    it("parses successfully when both characters are the same (i.e., the validation function succeeds)", function()
      local ret = parser:parse("aa")
      assert.are.same({"a", "a"}, ret.ast.seq)
      print("in attr_bool")
      ret = parser:parse("bb")
      assert.are.same({"b", "b"}, ret.ast.seq)
    end)
    it("does not parse successfully when the characters are different (i.e., the validation function fails)", function()
      local ret = parser:parse("ab")
      assert.is_falsy(ret)
    end)
  end)

  describe("Matching lookahead tests", function()
    local parser = hammer.sequence(hammer.and_(hammer.ch("0")), hammer.ch("0"))
    local parser2 = hammer.sequence(hammer.and_(hammer.ch("0")), hammer.ch("1"))
    local parser3 = hammer.sequence(hammer.ch("1"), hammer.and_(hammer.ch("2")))
    it("parses successfully when the lookahead matches the next character to parse", function()
      local ret = parser:parse("0")
      assert.are.same({"0"}, ret.ast.seq)
    end)
    it("does not parse successfully when the lookahead does not match the next character to parse", function()
      local ret = parser2:parse("0")
      assert.is_falsy(ret)
    end)
    it("parses successfully when the lookahead is there", function()
      local ret = parser3:parse("12")
      assert.are.same({"1"}, ret.ast.seq)
    end)
  end)

  describe("Non-matching lookahead tests", function()
    local parser = hammer.sequence(hammer.ch("a"), hammer.choice(hammer.ch("+"), hammer.token("++")), hammer.ch("b"))
    local parser2 = hammer.sequence(hammer.ch("a"), hammer.choice(hammer.sequence(hammer.ch("+"), hammer.not_(hammer.ch("+"))), hammer.token("++")), hammer.ch("b"))
    it("parses a single plus correctly in the 'choice' example", function()
      local ret = parser:parse("a+b")
      assert.are.same({"a", "+", "b"}, ret.ast.seq)
    end)
    it("does not parse a double plus correctly in the 'choice' example", function()
      local ret = parser:parse("a++b")
      assert.is_falsy(ret)
    end)
    it("parses a single plus correctly in the 'not' example", function()
      local ret = parser2:parse("a+b")
      assert.are.same({"a", {"+"}, "b"}, ret.ast.seq)
    end)
    it("parses a double plus correctly in the 'not' example", function()
      local ret = parser2:parse("a++b")
      assert.are.same({"a", "++", "b"}, ret.ast.seq)
    end)
  end)

  describe("Left recursion tests", function()
    local parser = hammer.indirect()
    hammer.bind_indirect(parser, hammer.choice(hammer.sequence(parser, hammer.ch("a")), hammer.ch("a")))
    it("parses the base case", function()
      local ret = parser:parse("a")
      assert.are.same({"a"}, ret.ast.seq)
    end)
    it("parses one level of recursion", function()
      local ret = parser:parse("aa")
      assert.are.same({"a", "a"}, ret.ast.seq)
    end)
    it("parses two levels of recursion", function()
      local ret = parser:parse("aaa")
      assert.are.same({{"a", "a"}, "a"}, ret.ast.seq)
    end)
  end)

  describe("Right recursion tests", function()
    local parser = hammer.indirect()
    hammer.bind_indirect(parser, hammer.choice(hammer.sequence(hammer.ch("a"), parser), hammer.epsilon_p()))
    it("parses the base case", function()
      local ret = parser:parse("a")
      assert.are.same({"a"}, ret.ast.seq)
    end)
    it("parses one level of recursion", function()
      local ret = parser:parse("aa")
      assert.are.same({"a", {"a"}}, ret.ast.seq)
    end)
    it("parses two levels of recursion", function()
      local ret = parser:parse("aaa")
      assert.are.same({"a", {"a", {"a"}}}, ret.ast.seq)
    end)
  end)

  describe("Endianness tests", function()
    local bit = require("bit")
    local u32 = hammer.uint32()
    local u5 = hammer.bits(5, false)
    local bb = bit.bor(hammer.BYTE_BIG_ENDIAN, hammer.BIT_BIG_ENDIAN)
    local bl = bit.bor(hammer.BYTE_BIG_ENDIAN, hammer.BIT_LITTLE_ENDIAN)
    local lb = bit.bor(hammer.BYTE_LITTLE_ENDIAN, hammer.BIT_BIG_ENDIAN)
    local ll = bit.bor(hammer.BYTE_LITTLE_ENDIAN, hammer.BIT_LITTLE_ENDIAN)
    local parser1 = hammer.with_endianness(bb, u32)
    local parser2 = hammer.with_endianness(bb, u5)
    local parser3 = hammer.with_endianness(ll, u32)
    local parser4 = hammer.with_endianness(ll, u5)
    local parser5 = hammer.with_endianness(bl, u32)
    local parser6 = hammer.with_endianness(bl, u5)
    local parser7 = hammer.with_endianness(lb, u32)
    local parser8 = hammer.with_endianness(lb, u5)
    it("parses big-endian cases", function()
      local ret = parser1:parse("abcd")
      assert.are.same(0x61626364, ret.ast.uint)
      ret = parser2:parse("abcd")
      assert.are.same(0xc, ret.ast.uint)
    end)
    it("parses little-endian cases", function()
      local ret = parser3:parse("abcd")
      assert.are.same(0x61626364, ret.ast.uint)
      ret = parser4:parse("abcd")
      assert.are.same(0xc, ret.ast.uint)
    end)
    it("parses mixed-endian cases", function()
      local ret = parser5:parse("abcd")
      assert.are.same(0x61626364, ret.ast.uint)
      ret = parser6:parse("abcd")
      assert.are.same(0x1, ret.ast.uint)
      ret = parser7:parse("abcd")
      assert.are.same(0x64636261, ret.ast.uint)
      ret = parser8:parse("abcd")
      assert.are.same(0xc, ret.ast.uint)
    end)
  end)

  describe("Symbol table tests", function()
    local parser = hammer.sequence(hammer.put_value(hammer.uint8(), "size"), hammer.token("foo"), hammer.length_value(hammer.get_value("size"), hammer.uint8()))
    it("parses a string that has enough bytes for the specified length", function()
      local ret = parser:parse(string.char(0x06) .. "fooabcdef")
      assert.are.same("foo", ret.ast.seq[2])
      assert.are.same({0x61, 0x62, 0x63, 0x64, 0x65, 0x66}, ret.ast.seq[3])
    end)
    it("does not parse a string that does not have enough bytes for the specified length", function()
      local ret = parser:parse(string.char(0x06) .. "fooabcde")
      assert.is_falsy(ret)
    end)
  end)

  describe("Permutation tests", function()
    local parser = hammer.permutation(hammer.ch("a"), hammer.ch("b"), hammer.ch("c"))
    it("parses a permutation of 'abc'", function()
      local ret = parser:parse("abc")
      assert.are.same({"a", "b", "c"}, ret.ast.seq)
      ret = parser:parse("acb")
      assert.are.same({"a", "c", "b"}, ret.ast.seq)
      ret = parser:parse("bac")
      assert.are.same({"b", "a", "c"}, ret.ast.seq)
      ret = parser:parse("bca")
      assert.are.same({"b", "c", "a"}, ret.ast.seq)
      ret = parser:parse("cab")
      assert.are.same({"c", "a", "b"}, ret.ast.seq)
      ret = parser:parse("cba")
      assert.are.same({"c", "b", "a"}, ret.ast.seq)
    end)
    it("does not parse a string that is not a permutation of 'abc'", function()
      local ret = parser:parse("a")
      assert.is_falsy(ret)
      ret = parser:parse("ab")
      assert.is_falsy(ret)
      ret = parser:parse("abb")
      assert.is_falsy(ret)
    end)
    parser = hammer.permutation(hammer.ch("a"), hammer.ch("b"), hammer.optional(hammer.ch("c")))
    it("parses a string that is a permutation of 'ab[c]'", function()
      local ret = parser:parse("abc")
      assert.are.same({"a", "b", "c"}, ret.ast.seq)
      ret = parser:parse("acb")
      assert.are.same({"a", "c", "b"}, ret.ast.seq)
      ret = parser:parse("bac")
      assert.are.same({"b", "a", "c"}, ret.ast.seq)
      ret = parser:parse("bca")
      assert.are.same({"b", "c", "a"}, ret.ast.seq)
      ret = parser:parse("cab")
      assert.are.same({"c", "a", "b"}, ret.ast.seq)
      ret = parser:parse("cba")
      assert.are.same({"c", "b", "a"}, ret.ast.seq)
      ret = parser:parse("ab")
      assert.are.same({"a", "b"}, ret.ast.seq)
      ret = parser:parse("ba")
      assert.are.same({"b", "a"}, ret.ast.seq)
    end)
    it("does not parse a string that is not a permutation of 'ab[c]'", function()
      local ret = parser:parse("a")
      assert.is_falsy(ret)
      ret = parser:parse("b")
      assert.is_falsy(ret)
      ret = parser:parse("c")
      assert.is_falsy(ret)
      ret = parser:parse("ca")
      assert.is_falsy(ret)
      ret = parser:parse("cb")
      assert.is_falsy(ret)
      ret = parser:parse("cc")
      assert.is_falsy(ret)
      ret = parser:parse("ccab")
      assert.is_falsy(ret)
      ret = parser:parse("ccc")
      assert.is_falsy(ret)
    end)
    parser = hammer.permutation(hammer.optional(hammer.ch("c")), hammer.ch("a"), hammer.ch("b"))
    it("parses a string that is a permutation of '[c]ab'", function()
      local ret = parser:parse("abc")
      assert.are.same({"a", "b", "c"}, ret.ast.seq)
      ret = parser:parse("acb")
      assert.are.same({"a", "c", "b"}, ret.ast.seq)
      ret = parser:parse("bac")
      assert.are.same({"b", "a", "c"}, ret.ast.seq)
      ret = parser:parse("bca")
      assert.are.same({"b", "c", "a"}, ret.ast.seq)
      ret = parser:parse("cab")
      assert.are.same({"c", "a", "b"}, ret.ast.seq)
      ret = parser:parse("cba")
      assert.are.same({"c", "b", "a"}, ret.ast.seq)
      ret = parser:parse("ab")
      assert.are.same({"a", "b"}, ret.ast.seq)
      ret = parser:parse("ba")
      assert.are.same({"b", "a"}, ret.ast.seq)
    end)
    it("does not parse a string that is not a permutation of '[c]ab'", function()
      local ret = parser:parse("a")
      assert.is_falsy(ret)
      ret = parser:parse("b")
      assert.is_falsy(ret)
      ret = parser:parse("c")
      assert.is_falsy(ret)
      ret = parser:parse("ca")
      assert.is_falsy(ret)
      ret = parser:parse("cb")
      assert.is_falsy(ret)
      ret = parser:parse("cc")
      assert.is_falsy(ret)
      ret = parser:parse("ccab")
      assert.is_falsy(ret)
      ret = parser:parse("ccc")
      assert.is_falsy(ret)
    end)
  end)

  -- describe("Monadic binding tests", function()
  --   local function continuation(allocator, result, env)
  --     local val = 0
  --     for k, v in result.seq
  --       do val = val*10 + v->uint - 48
  --     end
  --     if val > 26 then
  --       return nil
  --     else
  --       return hammer.ch
  --     end
  --   end
  --   local parser = hammer.bind(hammer.many1(hammer.ch_range("0", "9")), continuation, "a")
  --   it("parses a ", function()
  --     local ret = parser:parse()
  --     assert.are.same(ret.ast., )
  --   end)
  --   it("does not parse a ", function()
  --     local ret = parser:parse()
  --     assert.is_falsy(ret)
  --   end)
  -- end)
end)