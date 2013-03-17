part of sudoku;

/**
 * Utilities for working with keyboard input.
 */
class Keyboard {
  
  static const int HIGHLIGHT_PEERS_KEY = KeyCode.SHIFT;
  
  bool isHighlightPeersKeyPressed = false;
  
  Keyboard() {
    _registerHightlightPeersKeyListeners();
  }

  void _registerHightlightPeersKeyListeners() {
    window
    ..onKeyDown.listen((e) {
      if(isEventForKey(e, Keyboard.HIGHLIGHT_PEERS_KEY)) {
        isHighlightPeersKeyPressed = true;
      }
    })
    ..onKeyUp.listen((e) {
      if(isEventForKey(e, Keyboard.HIGHLIGHT_PEERS_KEY)) {
        isHighlightPeersKeyPressed = false;
      }
    });
  }
  
  /**
   * Returns true if the key represented by the given [KeyboardEvent] matches the [key].
   * Keys can be optained from the [KeyCode] constants class.
   */
  static bool isEventForKey(KeyboardEvent event, int key) {
    return key == event.keyCode;
  }
  
  /**
   * Returns true if the key represented by the given [KeyboardEvent] is
   * an integer between 0 and 9.
   */
  static bool isNumericKey(KeyboardEvent event) {
    return event.keyCode >= KeyCode.ZERO && 
        event.keyCode <= KeyCode.NINE;
  }
  
  /**
   * Returns true if the key represented by the given [KeyboardEvent] is
   * an arrow key (left, up, down, right).
   */
  static bool isArrowKey(KeyboardEvent event) {
    return event.keyCode >= KeyCode.LEFT && 
        event.keyCode <= KeyCode.DOWN;
  }
  
  /**
   * Returns the key represented by the given [KeyboardEvent] as a String.
   */
  static String parseKeyAsString(KeyboardEvent event) {
    return new String.fromCharCode(event.keyCode);
  }
  
  /**
   * Returns the key represented by the given [KeyboardEvent] as an int.
   * This method assumes the key is numeric. 
   */
  static int parseKeyAsInt(KeyboardEvent event) {
    return int.parse(parseKeyAsString(event));
  }
  
}

