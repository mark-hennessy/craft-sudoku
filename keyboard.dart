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
      if(isKey(Keyboard.HIGHLIGHT_PEERS, e)) {
        isHighlightPeersKeyPressed = true;
      }
    })
    ..onKeyUp.listen((e) {
      if(isKey(Keyboard.HIGHLIGHT_PEERS, e)) {
        isHighlightPeersKeyPressed = false;
      }
    });
  }
  
  static bool isKey(int key, KeyboardEvent event) {
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

