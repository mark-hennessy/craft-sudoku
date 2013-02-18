part of sudoku;

/**
 * Utilities for working with DOM elements.
 */
class DomUtils {
  
  /**
   * Makes the given [Element] focusable.
   */
  static void makeFocusable(Element element) {
    if(element.tabIndex == null || element.tabIndex < 0) {
      element.tabIndex = 0;
    }
  }
  
  /**
   * Returns true if the key represented by the given [keyCode] is 0-9.
   */
  static bool isNumericKeyCode(int keyCode) {
    return keyCode >= KeyCode.ZERO && keyCode <= KeyCode.NINE;
  }
  
  /**
   * Returns the key represented by the given [keyCode] as a [String].
   */
  static String parseKeyCodeAsString(int keyCode) {
    return new String.fromCharCode(keyCode);
  }
  
  /**
   * Returns the key represented by the given [keyCode] as an [int].
   */
  static int parseKeyCodeAsInt(int keyCode) {
    return int.parse(parseKeyCodeAsString(keyCode));
  }
}

