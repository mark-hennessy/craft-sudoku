part of test_suite;

void runStringUtilsTests() {
  group('StringUtils', () {
    test('splitChars', () {
      var text = "Hello";
      var chars = StringUtils.splitChars(text);
      expect(chars, hasLength(5));
      expect(chars, orderedEquals(["H", "e", "l", "l", "o"]));
    });
  });
}



