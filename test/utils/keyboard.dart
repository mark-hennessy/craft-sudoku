part of test_runner;

void runKeyboardTests() {
  group('Keyboard', () {
    MockKeyboardEvent event;

    setUp(() {
      event = new MockKeyboardEvent('keyDown');
    });

    void keyTest(List<int> keys, void test()) {
      for(var key in keys) {
        event.when(callsTo('get keyCode'))
        .alwaysReturn(key);
        test();
        event.reset();
      }
    }

    test('isKey', () {
      keyTest([KeyCode.A], () {
        expect(Keyboard.isEventForKey(event, KeyCode.A), isTrue);
        expect(Keyboard.isEventForKey(event, KeyCode.B), isFalse);
      });
    });

    test('isNumericKey', () {
      keyTest([KeyCode.FIVE, KeyCode.ZERO], () {
        expect(Keyboard.isNumericKey(event), isTrue);
      });

      keyTest([KeyCode.A, KeyCode.SHIFT], () {
        expect(Keyboard.isNumericKey(event), isFalse);
      });
    });

    test('isArrowKey', () {
      keyTest([KeyCode.LEFT, KeyCode.UP, KeyCode.RIGHT, KeyCode.DOWN], () {
        expect(Keyboard.isArrowKey(event), isTrue);
      });
      keyTest([KeyCode.A, KeyCode.SHIFT], () {
        expect(Keyboard.isArrowKey(event), isFalse);
      });
    });

    test('parseKeyAsString', () {
      keyTest([KeyCode.A], () {
        String string = Keyboard.parseKeyAsString(event);
        expect(string, "A");
      });
      keyTest([KeyCode.ZERO], () {
        expect(Keyboard.parseKeyAsString(event), "0");
      });
    });

    test('parseKeyAsInt', () {
      keyTest([KeyCode.ZERO], () {
        expect(Keyboard.parseKeyAsInt(event), 0);
      });
      keyTest([KeyCode.NINE], () {
        expect(Keyboard.parseKeyAsInt(event), 9);
      });
    });

  });
}



