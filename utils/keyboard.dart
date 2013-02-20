part of sudoku;

/**
 * Helper class for Sudoku keyboard input.
 */
class Keyboard {
  
  static const int HIGHLIGHT_PEERS = KeyCode.SHIFT;
  
  bool isHighlightPeersKeyPressed = false;
  
  Keyboard() {
    window
    ..onKeyDown.listen((e) {
      if(isEventForKey(e, Keyboard.HIGHLIGHT_PEERS)) {
        isHighlightPeersKeyPressed = true;
      }
    })
    ..onKeyUp.listen((e) {
      if(isEventForKey(e, Keyboard.HIGHLIGHT_PEERS)) {
        isHighlightPeersKeyPressed = false;
      }
    });
  }
  
  static bool isEventForKey(KeyboardEvent event, int key) {
    return key == event.keyCode;
  }
  
  static bool isNumericKey(KeyboardEvent event) {
    return event.keyCode >= KeyCode.ZERO && 
        event.keyCode <= KeyCode.NINE;
  }
  
  static bool isArrowKey(KeyboardEvent event) {
    return event.keyCode >= KeyCode.LEFT && 
        event.keyCode <= KeyCode.DOWN;
  }
  
  static String parseKeyAsString(KeyboardEvent event) {
    return new String.fromCharCode(event.keyCode);
  }
  
  static int parseKeyAsInt(KeyboardEvent event) {
    return int.parse(parseKeyAsString(event));
  }
  
}

