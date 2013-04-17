part of test_runner;

void runIOTests() {
  group('IO', () {

    test('printDebugInfo', () {
      var output = query(CSS.DEBUG_OUTPUT);
      output.text = "";

      var message = "Hello";
      IO.printDebugInfo(message);
      expect(output.text, equals(message));

      IO.clearDebugInfo();
      expect(output.text, equals(""));
    });

  });
}



