part of test_runner;

class MockKeyboardEvent extends Mock implements KeyboardEvent {

  KeyboardEvent _real;

  MockKeyboardEvent(String type) {
    _real = new KeyboardEvent(type);
  }

}