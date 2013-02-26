part of test_suite;

void runIOTests() {
  group('IO', () {
    test('printDebugInfo', () {
      var output = query(CSS.DEBUG_OUTPUT_ID);
      expect(output.text, equals(""));
      var message = "Hello";
      IO.printDebugInfo(message);
      expect(output.text, equals(message));
      IO.clearDebugInfo();
      expect(output.text, equals(""));
    });
  });
}



