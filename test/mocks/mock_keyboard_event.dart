part of test_suite;

class MockKeyboardEvent extends Mock implements KeyboardEvent {
  
  KeyboardEvent _real;
  
  MockKeyboardEvent(String type) {
    _real = new KeyboardEvent(type);
  }
  
}